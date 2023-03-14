defmodule SmartFarm.ExtensionServices do
  use SmartFarm.Context
  require Logger

  def get_request_status(%ExtensionServiceRequest{} = request) do
    case request do
      %{date_accepted: nil, date_cancelled: nil} ->
        :pending

      %{date_accepted: %DateTime{}, date_cancelled: nil} ->
        :accepted

      %{date_cancelled: %DateTime{}, date_accepted: nil} ->
        :cancelled

      %{date_accepted: %DateTime{}, date_cancelled: %DateTime{}} ->
        :cancelled
    end
  end

  def get_extension_service_request(_id, actor: nil), do: {:error, :unauthenticated}

  def get_extension_service_request(request_id, actor: %User{}) do
    Repo.fetch(ExtensionServiceRequest, request_id)
  end

  def request_farm_visit(_params, actor: nil), do: {:error, :unauthenticated}

  def request_farm_visit(params, actor: %User{} = user) do
    Multi.new()
    |> Multi.insert(:extension_service, fn _changes ->
      %ExtensionServiceRequest{}
      |> ExtensionServiceRequest.changeset(params)
      |> Ecto.Changeset.put_assoc(:requester, user)
    end)
    |> Multi.insert(:farm_visit, fn %{extension_service: service} ->
      service = Repo.preload(service, [:farm, :requester])

      %FarmVisitRequest{extension_service_id: service.id}
      |> FarmVisitRequest.changeset(params)
      |> put_description(service)
    end)
    |> Repo.transact()
    |> case do
      {:ok, %{extension_service: extension_service}} ->
        {:ok, extension_service}

      {:error, %{value: value}} ->
        {:error, value}
    end
  end

  defp put_description(changeset, %{farm: %{address: address} = farm, requester: requester}) do
    if changeset.valid? do
      date =
        changeset
        |> Ecto.Changeset.get_change(:visit_date)
        |> Timex.format!("{WDfull}, {D} {Mfull} {YYYY}")

      description =
        "#{requester.first_name} #{requester.last_name} would like you to visit #{farm.name} #{stringify_address(address)} on #{date}"

      Ecto.Changeset.put_change(changeset, :description, description)
    else
      changeset
    end
  end

  defp stringify_address(address) do
    if address do
      "in #{address.county}, #{address.subcounty}, #{address.ward}"
    else
      ""
    end
  end

  def request_medical_visit(_params, actor: nil), do: {:error, :unauthenticated}

  def request_medical_visit(params, actor: %User{} = user) do
    Multi.new()
    |> Multi.run(:batch, fn _repo, _changes ->
      batch_id = params[:batch_id] || params["batch_id"]
      Repo.fetch(Batch, batch_id)
    end)
    |> Multi.one(:bird_count, fn %{batch: batch} ->
      from b in Batch,
        left_join: r in assoc(b, :reports),
        left_join: c in assoc(r, :bird_counts),
        group_by: b.id,
        select: coalesce(b.bird_count - sum(coalesce(c.quantity, 0)), 0),
        where: b.id == ^batch.id
    end)
    |> Multi.insert(:extension_service, fn %{batch: batch} ->
      %ExtensionServiceRequest{farm_id: batch.farm_id}
      |> ExtensionServiceRequest.changeset(%{})
      |> Ecto.Changeset.put_assoc(:requester, user)
    end)
    |> Multi.insert(:medical_visit, fn
      %{
        extension_service: service,
        batch: batch,
        bird_count: bird_count
      } ->
        params =
          Map.merge(params, %{
            bird_age: Batches.current_age(batch),
            age_type: "days",
            bird_type: to_string(batch.bird_type),
            bird_count: bird_count
          })

        %MedicalVisitRequest{extension_service_id: service.id}
        |> MedicalVisitRequest.changeset(params)
    end)
    |> Multi.run(:files, fn _repo, %{extension_service: service} ->
      if params.attachments do
        storage_path = Path.join(["uploads", "extension_services", "#{service.id}"])
        working_dir = Path.join([System.tmp_dir!(), storage_path])
        Logger.info("Creating working directory #{working_dir}")
        File.mkdir_p!(working_dir)

        files =
          Enum.map(params.attachments, fn upload ->
            dest = Path.join([working_dir, upload.filename])
            File.cp!(upload.path, dest)
            {:ok, %File.Stat{size: size}} = File.stat(upload.path)
            ext = Path.extname(upload.filename)

            %{
              source_path: dest,
              original_name: upload.filename,
              storage_path: storage_path,
              unique_name: "#{Ecto.UUID.generate()}#{ext}",
              size: size
            }
          end)

        service
        |> Repo.preload([:attachments])
        |> Ecto.Changeset.change(%{attachments: files})
        |> Ecto.Changeset.cast_assoc(:attachments)
        |> Repo.update()
      else
        {:ok, Repo.preload(service, [:attachments])}
      end
    end)
    |> Oban.insert_all(:jobs, fn %{files: service} ->
      Enum.map(
        service.attachments,
        &Workers.Uploader.new(%{file_id: &1.id, source_path: &1.source_path})
      )
    end)
    |> Repo.transact()
    |> case do
      {:ok, %{extension_service: extension_service}} ->
        {:ok, extension_service}

      {:error, %{value: value}} ->
        {:error, value}
    end
  end

  def list_extension_service_requests(_params, actor: nil), do: {:error, :unauthenticated}

  def list_extension_service_requests(params, actor: %User{} = user) do
    user = Repo.preload(user, [:farmer, :vet_officer, :extension_officer])

    base_query =
      from e in ExtensionServiceRequest,
        left_join: m in assoc(e, :medical_visit),
        left_join: f in assoc(e, :farm_visit),
        order_by: [desc: e.created_at]

    base_query
    |> filter_extension_services_query_by_params(params)
    |> filter_extension_services_query_by_role(user, params[:status])
    |> Repo.all()
  end

  defp filter_extension_services_query_by_params(base, params) do
    params
    |> Enum.reject(fn {_key, val} -> is_nil(val) end)
    |> Enum.reduce(base, fn
      {:farm_id, value}, base ->
        from e in base, where: e.farm_id == ^value

      {:status, :pending}, base ->
        from e in base, where: is_nil(e.date_accepted)

      {:status, :accepted}, base ->
        from e in base, where: not is_nil(e.date_accepted)

      _other, base ->
        base
    end)
  end

  defp filter_extension_services_query_by_role(base, user, status) do
    user_role = Accounts.get_user_role(user)

    case user_role do
      :farm_manager ->
        from e in base,
          join: fm in FarmManager,
          on: fm.farm_id == e.farm_id and fm.user_id == ^user.id

      :farmer ->
        from e in base, join: f in assoc(e, :farm), on: f.owner_id == ^user.id

      :admin ->
        base

      role when role in [:vet_officer, :extension_officer] ->
        officer = user.extension_officer || user.vet_officer

        if officer.date_approved do
          from e in base,
            join: assoc(e, :farm),
            as: :farm,
            where: is_nil(e.date_accepted) or e.acceptor_id == ^user.id,
            where: ^maybe_filter_by_location(user, status)
        else
          from e in base, where: is_nil(e.id)
        end
    end
  end

  defp maybe_filter_by_location(user, status) do
    officer = user.extension_officer || user.vet_officer
    address = officer.address

    if address && status == :pending do
      dynamic([farm: f], ilike(json_extract_path(f.address, ["county"]), ^address.county))
    else
      true
    end
  end

  def accept_extension_request(_request_id, actor: nil), do: {:error, :unauthenticated}

  def accept_extension_request(request_id, actor: %User{} = user) do
    user_role = Accounts.get_user_role(user)

    if user_role in [:vet_officer, :extension_officer] do
      extension_service = Repo.get!(ExtensionServiceRequest, request_id)

      case extension_service do
        %{date_accepted: nil, date_cancelled: nil} ->
          extension_service
          |> ExtensionServiceRequest.changeset(%{
            date_accepted: DateTime.utc_now() |> DateTime.truncate(:second),
            acceptor_id: user.id
          })
          |> Repo.update()

        %{date_cancelled: %DateTime{}} ->
          {:error, :request_cancelled}

        %{date_accepted: %DateTime{}} ->
          {:error, :request_already_accepted}
      end
    else
      {:error, :unauthorized}
    end
  end

  def cancel_extension_request(_request_id, actor: nil), do: {:error, :unauthenticated}

  def cancel_extension_request(request_id, actor: %User{id: user_id}) do
    extension_service = Repo.get!(ExtensionServiceRequest, request_id)

    case extension_service do
      %{date_cancelled: nil, requester_id: ^user_id} ->
        extension_service
        |> ExtensionServiceRequest.changeset(%{
          date_cancelled: DateTime.utc_now() |> DateTime.truncate(:second)
        })
        |> Repo.update()

      %{date_cancelled: %DateTime{}} ->
        {:error, :request_already_cancelled}

      _other ->
        {:error, :unauthorized}
    end
  end

  def create_farm_visit_report(_attrs, actor: nil), do: {:error, :unauthenticated}

  def create_farm_visit_report(attrs, actor: %User{id: user_id}) do
    Multi.new()
    |> Multi.run(:extension_service, fn _repo, _changes ->
      if id = attrs[:extension_service_id] || attrs["extension_service_id"] do
        Repo.fetch(ExtensionServiceRequest, id)
      else
        {:error, "extension_service_id is missing"}
      end
    end)
    |> Multi.run(:auth, fn _repo, %{extension_service: extension_service} ->
      if extension_service.acceptor_id == user_id do
        {:ok, nil}
      else
        {:error, :unauthorized}
      end
    end)
    |> Multi.insert(:report, fn %{extension_service: extension_service} ->
      FarmVisitReport.changeset(
        %FarmVisitReport{extension_service_id: extension_service.id},
        attrs
      )
    end)
    |> Repo.transact()
    |> case do
      {:ok, %{report: report}} ->
        {:ok, report}

      {:error, %{value: error}} ->
        {:error, error}
    end
  end
end

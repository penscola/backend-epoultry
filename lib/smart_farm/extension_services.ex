defmodule SmartFarm.ExtensionServices do
  use SmartFarm.Context

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

  def request_farm_visit(_params, actor: nil), do: {:error, :unauthenticated}

  def request_farm_visit(params, actor: %User{} = user) do
    Multi.new()
    |> Multi.insert(:extension_service, fn _changes ->
      %ExtensionServiceRequest{}
      |> ExtensionServiceRequest.changeset(params)
      |> Ecto.Changeset.put_assoc(:requester, user)
    end)
    |> Multi.insert(:farm_visit, fn %{extension_service: service} ->
      %FarmVisitRequest{extension_service_id: service.id}
      |> FarmVisitRequest.changeset(params)
    end)
    |> Repo.transact()
    |> case do
      {:ok, %{extension_service: extension_service}} ->
        {:ok, extension_service}

      {:error, %{value: value}} ->
        {:error, value}
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
            bird_age: current_age(batch),
            age_type: "days",
            bird_type: to_string(batch.bird_type),
            bird_count: bird_count
          })

        %MedicalVisitRequest{extension_service_id: service.id}
        |> MedicalVisitRequest.changeset(params)
    end)
    |> Repo.transact()
    |> case do
      {:ok, %{extension_service: extension_service}} ->
        {:ok, extension_service}

      {:error, %{value: value}} ->
        {:error, value}
    end
  end

  defp current_age(batch) do
    start_age_days = batch.bird_age * days_count(batch.age_type)
    days_elapsed = Date.diff(Date.utc_today(), batch.created_at)
    start_age_days + days_elapsed
  end

  defp days_count(age_type) do
    case age_type do
      :weeks ->
        7

      :months ->
        30

      _other ->
        1
    end
  end

  def list_extension_service_requests(_params, actor: nil), do: {:error, :unauthenticated}

  def list_extension_service_requests(params, actor: %User{} = user) do
    base_query =
      from e in ExtensionServiceRequest,
        left_join: m in assoc(e, :medical_visit),
        left_join: f in assoc(e, :farm_visit),
        order_by: [desc: e.created_at]

    base_query
    |> filter_extension_services_query_by_params(params)
    |> filter_extension_services_query_by_role(user)
    |> Repo.all()
  end

  defp filter_extension_services_query_by_params(base, params) do
    Enum.reduce(params, base, fn
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

  defp filter_extension_services_query_by_role(base, user) do
    user_role = Accounts.get_user_role(user)

    case user_role do
      :farm_manager ->
        from e in base,
          join: fm in FarmManager,
          on: fm.farm_id == e.farm_id and fm.user_id == ^user.id

      :farmer ->
        from e in base, join: f in assoc(e, :farm), on: f.owner_id == ^user.id

      role when role in [:admin, :vet_officer, :extension_officer] ->
        base
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
            date_accepted: DateTime.utc_now() |> DateTime.truncate(:second)
          })
          |> Ecto.Changeset.put_assoc(:acceptor, user)
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

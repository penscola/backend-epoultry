defmodule SmartFarm.Farms do
  @moduledoc """
  The Farms context.
  """

  use SmartFarm.Context
  import SmartFarm.Farms.FarmAuthorizer

  @doc """
  Gets a single farm.

  Raises `Ecto.NoResultsError` if the Farm does not exist.

  ## Examples

      iex> get_farm!(123)
      %Farm{}

      iex> get_farm!(456)
      ** (Ecto.NoResultsError)

  """
  def get_farm!(id), do: Repo.get!(Farm, id)
  def get_farm(id), do: Repo.fetch(Farm, id)

  def get_farm(farm_id, actor: %User{} = user) do
    with {:ok, farm} <- get_farm(farm_id), :ok <- authorize(user, :get, farm) do
      {:ok, farm}
    end
  end

  @doc """
  Creates a farm.

  ## Examples

      iex> create_farm(%{field: value})
      {:ok, %Farm{}}

      iex> create_farm(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_farm(attrs, actor: %User{} = owner) do
    Multi.new()
    |> Multi.run(:farmer, fn _repo, _changes ->
      owner = Repo.preload(owner, [:farmer])

      if owner.farmer do
        {:ok, owner}
      else
        Accounts.create_farmer(owner, %{})
      end
    end)
    |> Multi.insert(:farm, Farm.changeset(%Farm{owner_id: owner.id}, attrs))
    |> Multi.run(:contractor, fn _repo, %{farm: farm} ->
      if attrs[:contractor_id] do
        %FarmContractor{farm_id: farm.id, contractor_id: attrs[:contractor_id]}
        |> FarmContractor.changeset(%{})
        |> Repo.insert()
      else
        {:ok, nil}
      end
    end)
    |> Repo.transaction()
    |> case do
      {:ok, %{farm: farm}} ->
        {:ok, farm}

      {:error, _operation, changeset, _changes} ->
        {:error, changeset}
    end
  end

  @doc """
  Updates a farm.

  ## Examples

      iex> update_farm(farm, %{field: new_value})
      {:ok, %Farm{}}

      iex> update_farm(farm, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_farm(%Farm{} = farm, attrs) do
    farm
    |> Farm.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a farm.

  ## Examples

      iex> delete_farm(farm)
      {:ok, %Farm{}}

      iex> delete_farm(farm)
      {:error, %Ecto.Changeset{}}

  """
  def delete_farm(%Farm{} = farm) do
    Repo.delete(farm)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking farm changes.

  ## Examples

      iex> change_farm(farm)
      %Ecto.Changeset{data: %Farm{}}

  """
  def change_farm(%Farm{} = farm, attrs \\ %{}) do
    Farm.changeset(farm, attrs)
  end

  def get_bird_count(%Farm{} = farm) do
    query =
      from b in Batch,
        left_join: r in assoc(b, :reports),
        left_join: c in assoc(r, :bird_counts),
        group_by: b.id,
        select: coalesce(b.bird_count - sum(coalesce(c.quantity, 0)), 0),
        where: b.farm_id == ^farm.id

    query
    |> Repo.all()
    |> Enum.sum()
  end

  def get_egg_count(%Farm{} = farm) do
    query =
      from ec in EggCollectionReport,
        join: r in assoc(ec, :report),
        join: b in assoc(r, :batch),
        where: b.farm_id == ^farm.id

    Repo.aggregate(query, :sum, :good_count)
  end

  def get_feeds_usage(%Farm{} = farm) do
    query =
      from si in StoreItem,
        where: si.farm_id == ^farm.id,
        where: si.item_type == ^:feed

    Repo.aggregate(query, :sum, :quantity_used)
  end

  def get_feeds_remaining(%Farm{} = farm) do
    query =
      from si in StoreItem,
        where: si.farm_id == ^farm.id,
        where: si.item_type == ^:feed,
        select: %{
          used: sum(si.quantity_used),
          received: sum(si.quantity_received),
          started: sum(si.starting_quantity)
        }

    if result = Repo.one(query) do
      result.started + result.received - result.used
    else
      0.0
    end
  end

  def get_valid_invite(invite_code) do
    now = DateTime.utc_now() |> DateTime.truncate(:second)
    query = from i in FarmInvite, where: i.expiry > ^now and not i.is_used

    case Repo.fetch_by(query, invite_code: invite_code) do
      {:ok, invite} ->
        {:ok, invite}

      _error ->
        {:error, :invalid_code}
    end
  end

  @spec join_farm(String.t(), %User{}) ::
          {:ok, %Farm{}} | {:error, Ecto.Changeset.t()} | {:error, any()}
  def join_farm(invite_code, user) do
    with {:ok, invite} <- get_valid_invite(invite_code) do
      Multi.new()
      |> Multi.insert(
        :farm_manager,
        FarmManager.changeset(%FarmManager{}, %{farm_id: invite.farm_id, user_id: user.id})
      )
      |> Multi.update(
        :invite,
        fn _changes ->
          if Application.get_env(:smart_farm, :env) == :staging and invite_code == "0000" do
            FarmInvite.changeset(invite, %{})
          else
            FarmInvite.changeset(invite, %{is_used: true, receiver_user_id: user.id})
          end
        end
      )
      |> Repo.transaction()
      |> case do
        {:ok, _changes} ->
          get_farm(invite.farm_id)

        {:error, _failed_op, changeset, _changes} ->
          {:error, changeset}
      end
    end
  end

  @spec create_farm_invite(Ecto.UUID.t(), actor: %User{} | nil) ::
          {:ok, %FarmInvite{}} | {:error, :unauthorized | :unauthenticated | Ecto.Changeset.t()}
  def create_farm_invite(_farm_id, actor: nil), do: {:error, :unauthenticated}

  def create_farm_invite(farm_id, actor: %User{} = user) do
    with {:ok, farm} <- get_farm(farm_id),
         :ok <- authorize(user, :create, %FarmInvite{farm_id: farm.id}) do
      create_invite(farm)
    end
  end

  defp create_invite(%Farm{} = farm, attrs \\ %{}) when is_map(attrs) do
    try do
      %FarmInvite{farm_id: farm.id}
      |> FarmInvite.changeset(attrs)
      |> Repo.insert()
    rescue
      Ecto.ConstraintError ->
        create_invite(farm, attrs)
    end
  end

  def batch_by_batches(_opts, farm_ids) do
    Batch.todays_submission_query()
    |> where([b], b.farm_id in ^Enum.uniq(farm_ids))
    |> Repo.all()
    |> Enum.group_by(& &1.farm_id)
  end

  def list_farm_reports(_args, actor: nil), do: {:error, :unauthenticated}

  # NOTE(frank): this is duplicate code. Fix me ASAP!
  def list_farm_reports(args, actor: %User{role: :admin}) do
    query =
      from r in Report,
        join: b in assoc(r, :batch),
        as: :batch,
        join: f in assoc(b, :farm),
        as: :farm,
        left_join: m in assoc(f, :managers),
        as: :manager,
        group_by: [r.report_date, f.id],
        order_by: [desc: r.report_date, asc: f.name],
        select: %{farm_id: f.id, report_date: r.report_date, farm_name: f.name}

    query = filter_reports_query(query, args)

    {:ok, Repo.all(query)}
  end

  def list_farm_reports(args, actor: %User{} = user) do
    query =
      from r in Report,
        join: assoc(r, :reporter),
        as: :reporter,
        join: b in assoc(r, :batch),
        as: :batch,
        join: f in assoc(b, :farm),
        as: :farm,
        left_join: m in assoc(f, :managers),
        as: :manager,
        where: m.id == ^user.id or f.owner_id == ^user.id,
        group_by: [r.report_date, f.id],
        order_by: [desc: r.report_date],
        select: %{farm_id: f.id, report_date: r.report_date}

    query = filter_reports_query(query, args)

    {:ok, Repo.all(query)}
  end

  defp filter_reports_query(query, args) do
    args
    |> Enum.reject(fn {_key, val} -> is_nil(val) or val == "" end)
    |> Enum.reduce(query, fn
      {:limit, value}, base ->
        from q in base, limit: ^value

      {:farm_id, value}, base ->
        from [farm: f] in base, where: f.id == ^value

      {:start_date, value}, base ->
        from q in base, where: q.report_date >= ^value

      {:end_date, value}, base ->
        from q in base, where: q.report_date <= ^value

      {:name, value}, base ->
        value = String.trim(value)

        base_query =
          from [batch: b, manager: m] in base,
            where: ilike(b.name, ^"%#{value}%"),
            or_where: ilike(m.first_name, ^"#{value}%"),
            or_where: ilike(m.last_name, ^"#{value}%")

        maybe_filter_by_report_date(base_query, value)

      _other, base ->
        base
    end)
  end

  defp maybe_filter_by_report_date(query, value) do
    if Regex.match?(~r/^[0-9]{2}$/, value) do
      from q in query,
        or_where: fragment("DATE_PART('day', ?)", q.report_date) == type(^value, :integer)
    else
      query
    end
  end

  def get_farm_report(_farm_id, _date, actor: nil), do: {:error, :unauthenticated}
  # NOTE(frank): this is duplicate code. Fix me ASAP!
  def get_farm_report(farm_id, report_date, actor: %User{role: :admin}) do
    bird_count_query =
      from b in Batch,
        join: r in assoc(b, :reports),
        on: r.report_date <= ^report_date,
        join: bcr in assoc(r, :bird_counts),
        where: b.farm_id == ^farm_id,
        group_by: b.id,
        select: %{batch_id: b.id, current_quantity: b.bird_count - sum(bcr.quantity)}

    bird_reports_query =
      from b in Batch,
        join: f in assoc(b, :farm),
        left_join: m in assoc(f, :managers),
        join: bcq in subquery(bird_count_query),
        on: bcq.batch_id == b.id,
        left_join: r in assoc(b, :reports),
        on: r.report_date == ^report_date,
        left_join: bcr in assoc(r, :bird_counts),
        group_by: b.bird_type,
        select: %{
          bird_type: b.bird_type,
          current_quantity: type(avg(bcq.current_quantity), :integer),
          reports: fragment("ARRAY_AGG(?)", type(r.id, :string)),
          reasons:
            fragment(
              "ARRAY_AGG(JSONB_BUILD_OBJECT('reason', ?, 'quantity', ?))",
              bcr.reason,
              bcr.quantity
            )
        }

    feeds_received_to_date =
      from s in StoreItem,
        left_join: r in assoc(s, :restocks),
        on: r.date_restocked <= ^report_date,
        where: s.item_type == ^:feed and s.farm_id == ^farm_id,
        group_by: s.id,
        select: %{id: s.id, quantity_received: coalesce(sum(r.quantity), 0.0)}

    feeds_used_to_date =
      from s in StoreItem,
        left_join: sr in assoc(s, :store_reports),
        left_join: r in assoc(sr, :report),
        on: r.report_date <= ^report_date,
        where: s.item_type == ^:feed and s.farm_id == ^farm_id,
        group_by: s.id,
        select: %{id: s.id, quantity_used: coalesce(sum(sr.quantity), 0.0)}

    feeds_usage_query =
      from s in StoreItem,
        join: f in assoc(s, :farm),
        on: f.id == ^farm_id,
        join: sr in assoc(s, :store_reports),
        join: r in assoc(sr, :report),
        on: r.report_date == ^report_date,
        left_join: m in assoc(f, :managers),
        left_join: frd in subquery(feeds_received_to_date),
        on: frd.id == s.id,
        left_join: fud in subquery(feeds_used_to_date),
        on: fud.id == s.id,
        where: s.item_type == ^"feed",
        group_by: [s.id, r.report_date],
        select: %{
          report_date: r.report_date,
          feed_type: s.name,
          used_quantity: avg(sr.quantity),
          reports: fragment("ARRAY_AGG(?)", type(r.id, :string)),
          current_quantity:
            s.starting_quantity + avg(frd.quantity_received) - avg(fud.quantity_used)
        }

    egg_collection_query =
      from ecr in EggCollectionReport,
        join: r in assoc(ecr, :report),
        on: r.report_date == ^report_date,
        join: b in assoc(r, :batch),
        on: b.farm_id == ^farm_id,
        join: f in assoc(b, :farm),
        left_join: m in assoc(f, :managers),
        group_by: b.farm_id,
        select: %{
          reports: fragment("ARRAY_AGG(?)", type(r.id, :string)),
          good_count: sum(ecr.good_count),
          deformed_count:
            sum(fragment("(? ->> ?)::integer", ecr.bad_count_classification, "deformed")),
          broken_count:
            sum(fragment("(? ->> ?)::integer", ecr.bad_count_classification, "broken"))
        }

    bird_reports = Repo.all(bird_reports_query)
    feeds_reports = Repo.all(feeds_usage_query)
    egg_report = Repo.one(egg_collection_query)
    batch_reports = batch_reports_from_reports([egg_report] ++ feeds_reports ++ bird_reports)

    if length(batch_reports) > 0 do
      latest_report = hd(batch_reports)

      {:ok,
       %{
         report_date: latest_report.report_date,
         report_time:
           latest_report.created_at
           |> DateTime.shift_zone!("Africa/Nairobi")
           |> DateTime.to_time(),
         farm_id: farm_id,
         feeds_usage:
           Enum.map(feeds_reports, fn report -> matching_batch_reports(report, batch_reports) end),
         egg_collection: matching_batch_reports(egg_report, batch_reports),
         bird_counts: format_bird_reports(bird_reports, batch_reports)
       }}
    else
      {:error, :not_found}
    end
  end

  def get_farm_report(farm_id, report_date, actor: %User{} = user) do
    bird_count_query =
      from b in Batch,
        join: r in assoc(b, :reports),
        on: r.report_date <= ^report_date,
        join: bcr in assoc(r, :bird_counts),
        where: b.farm_id == ^farm_id,
        group_by: b.id,
        select: %{batch_id: b.id, current_quantity: b.bird_count - sum(bcr.quantity)}

    bird_reports_query =
      from b in Batch,
        join: f in assoc(b, :farm),
        left_join: m in assoc(f, :managers),
        join: bcq in subquery(bird_count_query),
        on: bcq.batch_id == b.id,
        left_join: r in assoc(b, :reports),
        on: r.report_date == ^report_date,
        left_join: bcr in assoc(r, :bird_counts),
        where: m.id == ^user.id or f.owner_id == ^user.id,
        group_by: b.bird_type,
        select: %{
          bird_type: b.bird_type,
          current_quantity: type(avg(bcq.current_quantity), :integer),
          reports: fragment("ARRAY_AGG(?)", type(r.id, :string)),
          reasons:
            fragment(
              "ARRAY_AGG(JSONB_BUILD_OBJECT('reason', ?, 'quantity', ?))",
              bcr.reason,
              bcr.quantity
            )
        }

    feeds_received_to_date =
      from s in StoreItem,
        left_join: r in assoc(s, :restocks),
        on: r.date_restocked <= ^report_date,
        where: s.item_type == ^:feed and s.farm_id == ^farm_id,
        group_by: s.id,
        select: %{id: s.id, quantity_received: coalesce(sum(r.quantity), 0.0)}

    feeds_used_to_date =
      from s in StoreItem,
        left_join: sr in assoc(s, :store_reports),
        left_join: r in assoc(sr, :report),
        on: r.report_date <= ^report_date,
        where: s.item_type == ^:feed and s.farm_id == ^farm_id,
        group_by: s.id,
        select: %{id: s.id, quantity_used: coalesce(sum(sr.quantity), 0.0)}

    feeds_usage_query =
      from s in StoreItem,
        join: f in assoc(s, :farm),
        on: f.id == ^farm_id,
        join: sr in assoc(s, :store_reports),
        join: r in assoc(sr, :report),
        on: r.report_date == ^report_date,
        left_join: m in assoc(f, :managers),
        left_join: frd in subquery(feeds_received_to_date),
        on: frd.id == s.id,
        left_join: fud in subquery(feeds_used_to_date),
        on: fud.id == s.id,
        where: m.id == ^user.id or f.owner_id == ^user.id,
        where: s.item_type == ^"feed",
        group_by: [s.id, r.report_date],
        select: %{
          report_date: r.report_date,
          feed_type: s.name,
          used_quantity: avg(sr.quantity),
          reports: fragment("ARRAY_AGG(?)", type(r.id, :string)),
          current_quantity:
            s.starting_quantity + avg(frd.quantity_received) - avg(fud.quantity_used)
        }

    egg_collection_query =
      from ecr in EggCollectionReport,
        join: r in assoc(ecr, :report),
        on: r.report_date == ^report_date,
        join: b in assoc(r, :batch),
        on: b.farm_id == ^farm_id,
        join: f in assoc(b, :farm),
        left_join: m in assoc(f, :managers),
        where: m.id == ^user.id or f.owner_id == ^user.id,
        group_by: b.farm_id,
        select: %{
          reports: fragment("ARRAY_AGG(?)", type(r.id, :string)),
          good_count: sum(ecr.good_count),
          deformed_count:
            sum(fragment("(? ->> ?)::integer", ecr.bad_count_classification, "deformed")),
          broken_count:
            sum(fragment("(? ->> ?)::integer", ecr.bad_count_classification, "broken"))
        }

    bird_reports = Repo.all(bird_reports_query)
    feeds_reports = Repo.all(feeds_usage_query)
    egg_report = Repo.one(egg_collection_query)
    batch_reports = batch_reports_from_reports([egg_report] ++ feeds_reports ++ bird_reports)

    if length(batch_reports) > 0 do
      latest_report = hd(batch_reports)

      {:ok,
       %{
         report_date: latest_report.report_date,
         report_time:
           latest_report.created_at
           |> DateTime.shift_zone!("Africa/Nairobi")
           |> DateTime.to_time(),
         farm_id: farm_id,
         feeds_usage:
           Enum.map(feeds_reports, fn report -> matching_batch_reports(report, batch_reports) end),
         egg_collection: matching_batch_reports(egg_report, batch_reports),
         bird_counts: format_bird_reports(bird_reports, batch_reports)
       }}
    else
      {:error, :not_found}
    end
  end

  defp format_bird_reports(farm_reports, batch_reports) do
    Enum.map(farm_reports, fn report ->
      report = matching_batch_reports(report, batch_reports)

      reasons =
        report.reasons
        |> Enum.reject(fn reason -> is_nil(reason["quantity"]) or reason["quantity"] == 0 end)
        |> Enum.group_by(& &1["reason"])
        |> Enum.map(fn {reason, values} ->
          %{
            reason: reason,
            quantity: Enum.reduce(values, 0, fn x, acc -> acc + x["quantity"] end)
          }
        end)

      %{report | reasons: reasons}
    end)
  end

  defp matching_batch_reports(nil, _reports), do: nil

  defp matching_batch_reports(farm_report, batch_reports) do
    reports = Enum.filter(batch_reports, &(&1.id in farm_report.reports))
    %{farm_report | reports: reports}
  end

  defp batch_reports_from_reports(reports) do
    report_ids =
      reports |> Enum.reject(&is_nil/1) |> Enum.map(& &1.reports) |> List.flatten() |> Enum.uniq()

    Report
    |> Report.by_id(report_ids)
    |> join(:inner, [r], b in assoc(r, :batch))
    |> order_by([r], desc: r.created_at)
    |> preload([r, b], batch: b)
    |> Repo.all()
  end
end

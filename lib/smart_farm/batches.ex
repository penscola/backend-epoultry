defmodule SmartFarm.Batches do
  @moduledoc """
  The Batches context.
  """

  use SmartFarm.Context

  @doc """
  Returns the list of batches.

  ## Examples

      iex> list_batches()
      [%Batch{}, ...]

  """
  def list_batches do
    Repo.all(Batch)
  end

  @doc """
  Gets a single batch.

  Raises `Ecto.NoResultsError` if the Batch does not exist.

  ## Examples

      iex> get_batch!(123)
      %Batch{}

      iex> get_batch!(456)
      ** (Ecto.NoResultsError)

  """
  def get_batch!(id), do: Repo.get!(Batch.todays_submission_query(), id)
  def get_batch(id), do: Repo.fetch(Batch.todays_submission_query(), id)

  def current_age(%Batch{} = batch) do
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

  @doc """
  Creates a batch.

  ## Examples

      iex> create_batch(%{field: value})
      {:ok, %Batch{}}

      iex> create_batch(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_batch(attrs \\ %{}) do
    Multi.new()
    |> Multi.insert(:batch, Batch.changeset(%Batch{}, attrs))
    |> Oban.insert(:job, fn %{batch: batch} ->
      Workers.VaccinationSchedule.new(%{batch_id: batch.id})
    end)
    |> Repo.transact()
    |> case do
      {:ok, %{batch: batch}} ->
        {:ok, batch}

      {:error, %{value: value}} ->
        {:error, value}
    end
  end

  @doc """
  Updates a batch.

  ## Examples

      iex> update_batch(batch, %{field: new_value})
      {:ok, %Batch{}}

      iex> update_batch(batch, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_batch(%Batch{} = batch, attrs) do
    batch
    |> Batch.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a batch.

  ## Examples

      iex> delete_batch(batch)
      {:ok, %Batch{}}

      iex> delete_batch(batch)
      {:error, %Ecto.Changeset{}}

  """
  def delete_batch(%Batch{} = batch) do
    Repo.delete(batch)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking batch changes.

  ## Examples

      iex> change_batch(batch)
      %Ecto.Changeset{data: %Batch{}}

  """
  def change_batch(%Batch{} = batch, attrs \\ %{}) do
    Batch.changeset(batch, attrs)
  end

  @doc """
  Gets a single bird_count_report.

  Raises `Ecto.NoResultsError` if the Birds count report does not exist.

  ## Examples

      iex> get_bird_count_report!(123)
      %BirdCountReport{}

      iex> get_bird_count_report!(456)
      ** (Ecto.NoResultsError)

  """
  def get_bird_count_report!(id), do: Repo.get!(BirdCountReport, id)

  @doc """
  Creates a bird_count_report.

  ## Examples

      iex> create_bird_count_report(%{field: value})
      {:ok, %BirdCountReport{}}

      iex> create_bird_count_report(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_bird_count_report(attrs \\ %{}) do
    %BirdCountReport{}
    |> BirdCountReport.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a bird_count_report.

  ## Examples

      iex> update_bird_count_report(bird_count_report, %{field: new_value})
      {:ok, %BirdCountReport{}}

      iex> update_bird_count_report(bird_count_report, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_bird_count_report(%BirdCountReport{} = bird_count_report, attrs) do
    bird_count_report
    |> BirdCountReport.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Gets a single egg_collection_report.

  Raises `Ecto.NoResultsError` if the Egg collection report does not exist.

  ## Examples

      iex> get_egg_collection_report!(123)
      %EggCollectionReport{}

      iex> get_egg_collection_report!(456)
      ** (Ecto.NoResultsError)

  """
  def get_egg_collection_report!(id), do: Repo.get!(EggCollectionReport, id)

  @doc """
  Creates a egg_collection_report.

  ## Examples

      iex> create_egg_collection_report(%{field: value})
      {:ok, %EggCollectionReport{}}

      iex> create_egg_collection_report(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_egg_collection_report(attrs \\ %{}) do
    %EggCollectionReport{}
    |> EggCollectionReport.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a egg_collection_report.

  ## Examples

      iex> update_egg_collection_report(egg_collection_report, %{field: new_value})
      {:ok, %EggCollectionReport{}}

      iex> update_egg_collection_report(egg_collection_report, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_egg_collection_report(%EggCollectionReport{} = egg_collection_report, attrs) do
    egg_collection_report
    |> EggCollectionReport.changeset(attrs)
    |> Repo.update()
  end

  @spec create_report(map()) :: {:ok, %Report{}} | {:error, Ecto.Changeset.t()}
  def create_report(args) do
    Multi.new()
    |> Multi.run(:batch, fn _repo, _changes ->
      get_batch(args.batch_id)
    end)
    |> Multi.insert(:report, Report.changeset(%Report{}, args))
    |> Multi.run(:egg_collection, fn repo, %{report: report, batch: batch} ->
      if batch.bird_type != :broilers && args[:egg_collection] do
        %{
          egg_count: total,
          broken_count: broken,
          deformed_count: deformed,
          small_count: small,
          large_count: large
        } = args.egg_collection

        egg_collection =
          Map.merge(args.egg_collection, %{
            good_count: total - broken - deformed,
            bad_count: broken + deformed,
            bad_count_classification: %{
              broken: broken,
              deformed: deformed
            },
            good_count_classification: %{
              small: small,
              large: large
            }
          })

        report
        |> Ecto.build_assoc(:egg_collection)
        |> EggCollectionReport.changeset(egg_collection)
        |> repo.insert()
      else
        {:ok, nil}
      end
    end)
    |> Multi.insert_all(:bird_counts, BirdCountReport, fn %{report: report} ->
      timestamp = DateTime.utc_now() |> DateTime.truncate(:second)
      bird_counts = Enum.filter(args[:bird_counts] || [], &(&1.quantity > 0))

      Enum.map(
        bird_counts,
        &Map.merge(&1, %{report_id: report.id, created_at: timestamp, updated_at: timestamp})
      )
    end)
    |> Multi.run(:weight_report, fn repo, %{batch: batch, report: report} ->
      if batch.bird_type == :broilers and is_float(args[:weight_report][:average_weight]) and
           args[:weight_report][:average_weight] > 0.0 do
        %WeightReport{report_id: report.id}
        |> WeightReport.changeset(args.weight_report)
        |> repo.insert()
      else
        {:ok, nil}
      end
    end)
    |> Multi.insert_all(
      :feeds_in_store,
      StoreItem,
      fn %{batch: batch} ->
        feed_store_items_params(args[:feeds_report][:in_store] || [], batch)
      end,
      on_conflict: :nothing
    )
    |> Multi.run(:feeds_received, fn _repo, %{batch: batch, report: report} ->
      received_feeds = feed_store_items_params(args[:feeds_report][:received] || [], batch)

      Multi.new()
      |> received_store_items_multi(received_feeds, batch, report)
      |> Repo.transact()
    end)
    |> Multi.run(:feeds_used, fn _repo, %{batch: batch, report: report} ->
      used_feeds = Enum.filter(args[:feeds_report][:used] || [], &(&1.quantity > 0))

      used_feeds =
        Enum.map(used_feeds, fn feed -> Map.merge(feed, %{name: to_string(feed.feed_type)}) end)

      Multi.new()
      |> used_store_items_multi(used_feeds, batch, report)
      |> Repo.transact()
    end)
    |> Multi.insert_all(
      :medication_in_store,
      StoreItem,
      fn %{batch: batch} ->
        medication_store_items_params(args[:medications_report][:in_store] || [], batch)
      end,
      on_conflict: :nothing
    )
    |> Multi.run(:medication_received, fn _repo, %{batch: batch, report: report} ->
      received_meds =
        medication_store_items_params(args[:medications_report][:received] || [], batch)

      Multi.new()
      |> received_store_items_multi(received_meds, batch, report)
      |> Repo.transact()
    end)
    |> Multi.run(:medication_used, fn _repo, %{batch: batch, report: report} ->
      used_meds = Enum.filter(args[:medications_report][:used] || [], &(&1.quantity > 0))

      used_meds = Enum.map(used_meds, fn med -> Map.merge(med, %{name: med.name}) end)

      Multi.new()
      |> used_store_items_multi(used_meds, batch, report)
      |> Repo.transact()
    end)
    |> Multi.insert_all(
      :sawdust_in_store,
      StoreItem,
      fn %{batch: batch} ->
        sawdust_store_items_params(args[:sawdust_report][:in_store], batch)
      end,
      on_conflict: :nothing
    )
    |> Multi.run(:sawdust_received, fn _repo, %{batch: batch, report: report} ->
      received_sawdust = sawdust_store_items_params(args[:sawdust_report][:received] || [], batch)

      Multi.new()
      |> received_store_items_multi(received_sawdust, batch, report)
      |> Repo.transact()
    end)
    |> Multi.run(:sawdust_used, fn _repo, %{batch: batch, report: report} ->
      used_sawdust = sawdust_store_items_params(args[:sawdust_report][:used], batch)

      used_sawdust =
        Enum.map(used_sawdust, fn sawdust ->
          Map.merge(sawdust, %{quantity: sawdust.starting_quantity})
        end)

      Multi.new()
      |> used_store_items_multi(used_sawdust, batch, report)
      |> Repo.transact()
    end)
    |> Multi.insert_all(
      :briquettes_in_store,
      StoreItem,
      fn %{batch: batch} ->
        briquettes_store_items_params(args[:briquettes_report][:in_store], batch)
      end,
      on_conflict: :nothing
    )
    |> Multi.run(:briquettes_received, fn _repo, %{batch: batch, report: report} ->
      received_briquettes =
        briquettes_store_items_params(args[:briquettes_report][:received] || [], batch)

      Multi.new()
      |> received_store_items_multi(received_briquettes, batch, report)
      |> Repo.transact()
    end)
    |> Multi.run(:briquettes_used, fn _repo, %{batch: batch, report: report} ->
      used_briquettes = briquettes_store_items_params(args[:briquettes_report][:used], batch)

      used_briquettes =
        Enum.map(used_briquettes, fn briquettes ->
          Map.merge(briquettes, %{quantity: briquettes.starting_quantity})
        end)

      Multi.new()
      |> used_store_items_multi(used_briquettes, batch, report)
      |> Repo.transact()
    end)
    |> Repo.transaction()
    |> case do
      {:ok, %{report: report}} ->
        {:ok, report}

      {:error, _failed_key, changeset, _changes} ->
        {:error, changeset}
    end
  end

  defp received_store_items_multi(multi, items, batch, report) do
    items
    |> Enum.reduce(multi, fn item, multi ->
      if store_item = Repo.get_by(StoreItem, farm_id: batch.farm_id, name: item.name) do
        Multi.insert(multi, "restock_#{store_item.id}", fn _changes ->
          store_item
          |> Ecto.build_assoc(:restocks)
          |> Restock.changeset(
            Map.merge(item, %{
              date_restocked: report.report_date,
              quantity: item.starting_quantity
            })
          )
        end)
      else
        Multi.insert_all(multi, "item_#{item.name}", StoreItem, [item])
      end
    end)
  end

  defp used_store_items_multi(multi, items, batch, report) do
    items
    |> Enum.reduce(multi, fn item, multi ->
      if store_item =
           Repo.get_by(StoreItem, farm_id: batch.farm_id, name: item.name) do
        Multi.insert(multi, item.name, fn _changes ->
          StoreItemUsageReport.changeset(
            %StoreItemUsageReport{report_id: report.id},
            batch,
            store_item,
            item
          )
        end)
      else
        Multi.error(multi, item.name, "#{item.name} not in store")
      end
    end)
  end

  defp feed_store_items_params(feeds, batch) do
    timestamp = DateTime.utc_now() |> DateTime.truncate(:second)

    feeds
    |> Enum.filter(&(&1.quantity > 0))
    |> Enum.map(fn item ->
      %{
        name: to_string(item.feed_type),
        starting_quantity: item.quantity,
        measurement_unit: item.measurement_unit,
        item_type: :feed,
        farm_id: batch.farm_id,
        created_at: timestamp,
        updated_at: timestamp
      }
    end)
  end

  defp medication_store_items_params(meds, batch) do
    timestamp = DateTime.utc_now() |> DateTime.truncate(:second)

    meds
    |> Enum.filter(&(&1.quantity > 0))
    |> Enum.map(fn item ->
      %{
        name: to_string(item.name),
        starting_quantity: item.quantity,
        measurement_unit: item.measurement_unit,
        item_type: :medication,
        farm_id: batch.farm_id,
        created_at: timestamp,
        updated_at: timestamp
      }
    end)
  end

  defp sawdust_store_items_params(sawdust, batch) when is_map(sawdust) do
    if sawdust.quantity > 0 do
      timestamp = DateTime.utc_now() |> DateTime.truncate(:second)

      [
        %{
          name: "sawdust",
          starting_quantity: sawdust.quantity,
          measurement_unit: sawdust.measurement_unit,
          item_type: :sawdust,
          farm_id: batch.farm_id,
          created_at: timestamp,
          updated_at: timestamp
        }
      ]
    else
      []
    end
  end

  defp sawdust_store_items_params(_sawdust, _batch), do: []

  defp briquettes_store_items_params(briquette, batch) when is_map(briquette) do
    if briquette.quantity > 0 do
      timestamp = DateTime.utc_now() |> DateTime.truncate(:second)

      [
        %{
          name: "briquettes",
          starting_quantity: briquette.quantity,
          measurement_unit: briquette.measurement_unit,
          item_type: :briquettes,
          farm_id: batch.farm_id,
          created_at: timestamp,
          updated_at: timestamp
        }
      ]
    else
      []
    end
  end

  defp briquettes_store_items_params(_briquette, _batch), do: []
end

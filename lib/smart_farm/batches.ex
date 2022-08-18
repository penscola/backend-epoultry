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
  def get_batch!(id), do: Repo.get!(Batch, id)
  def get_batch(id), do: Repo.fetch(Batch, id)

  @doc """
  Creates a batch.

  ## Examples

      iex> create_batch(%{field: value})
      {:ok, %Batch{}}

      iex> create_batch(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_batch(attrs \\ %{}) do
    %Batch{}
    |> Batch.changeset(attrs)
    |> Repo.insert()
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
    |> Multi.run(:egg_collection, fn repo, %{report: report} ->
      if args[:egg_collection] do
        report
        |> Ecto.build_assoc(:egg_collection)
        |> EggCollectionReport.changeset(args.egg_collection)
        |> repo.insert()
      else
        {:ok, nil}
      end
    end)
    |> Multi.insert_all(:bird_counts, BirdCountReport, fn %{report: report} ->
      timestamp = DateTime.utc_now() |> DateTime.truncate(:second)

      Enum.map(
        args.bird_counts,
        &Map.merge(&1, %{report_id: report.id, created_at: timestamp, updated_at: timestamp})
      )
    end)
    |> Multi.merge(fn %{batch: batch, report: report} ->
      args.feeds_usage_reports
      |> Enum.reduce(Multi.new(), fn feeds_usage, multi ->
        changeset =
          FeedsUsageReport.changeset(
            %FeedsUsageReport{bird_type: batch.bird_type, report_id: report.id},
            feeds_usage
          )

        Multi.insert(multi, feeds_usage.feed_type, changeset)
      end)
    end)
    |> Repo.transaction()
    |> case do
      {:ok, %{report: report}} ->
        {:ok, report}

      {:error, _failed_key, changeset, _changes} ->
        {:error, changeset}
    end
  end
end

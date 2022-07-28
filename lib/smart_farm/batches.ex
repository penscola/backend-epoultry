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

  def current_bird_count(%Batch{} = batch) do
    query = from r in BirdCountReport, where: r.batch_id == ^batch.id, select: r.quantity
    removed_quantity = Repo.aggregate(query, :count) || 0
    batch.bird_count - removed_quantity
  end

  @doc """
  Returns the list of bird_count_reports.

  ## Examples

      iex> list_bird_count_reports()
      [%BirdCountReport{}, ...]

  """
  def list_bird_count_reports do
    Repo.all(BirdCountReport)
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
  Deletes a bird_count_report.

  ## Examples

      iex> delete_bird_count_report(bird_count_report)
      {:ok, %BirdCountReport{}}

      iex> delete_bird_count_report(bird_count_report)
      {:error, %Ecto.Changeset{}}

  """
  def delete_bird_count_report(%BirdCountReport{} = bird_count_report) do
    Repo.delete(bird_count_report)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking bird_count_report changes.

  ## Examples

      iex> change_bird_count_report(bird_count_report)
      %Ecto.Changeset{data: %BirdCountReport{}}

  """
  def change_bird_count_report(%BirdCountReport{} = bird_count_report, attrs \\ %{}) do
    BirdCountReport.changeset(bird_count_report, attrs)
  end
end

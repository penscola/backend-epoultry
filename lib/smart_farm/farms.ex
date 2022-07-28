defmodule SmartFarm.Farms do
  @moduledoc """
  The Farms context.
  """

  use SmartFarm.Context

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

  @doc """
  Creates a farm.

  ## Examples

      iex> create_farm(%{field: value})
      {:ok, %Farm{}}

      iex> create_farm(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_farm(attrs \\ %{}) do
    %Farm{}
    |> Farm.changeset(attrs)
    |> Repo.insert()
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
        join: r in assoc(b, :reports),
        join: c in assoc(r, :bird_counts),
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
end

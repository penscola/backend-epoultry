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
      from fu in FeedsUsageReport,
        join: r in assoc(fu, :report),
        join: b in assoc(r, :batch),
        where: b.farm_id == ^farm.id

    Repo.aggregate(query, :sum, :quantity)
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
end

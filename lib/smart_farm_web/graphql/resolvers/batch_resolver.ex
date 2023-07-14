defmodule SmartFarmWeb.Resolvers.Batch do
  use SmartFarm.Shared
  import Absinthe.Resolution.Helpers, only: [batch: 3]

  @spec create_batch(map(), %{context: %{current_user: %User{}}}) ::
          {:ok, %Batch{}} | {:error, Ecto.Changeset.t()}
  def create_batch(args, %{context: %{current_user: user}}) do
    args.data
    |> Map.merge(%{creator_id: user.id})
    |> Batches.create_batch()
  end

  @spec get_batch(map(), %{context: %{current_user: %User{}}}) ::
          {:ok, %Batch{}} | {:error, :not_found}
  def get_batch(%{batch_id: batch_id}, %{context: %{current_user: _user}}) do
    Batches.get_batch(batch_id)
  end

  @spec create_batch_report(map(), %{context: %{current_user: %User{}}}) ::
          {:ok, %Report{}} | {:error, Ecto.Changeset.t()}
  def create_batch_report(%{data: data} = _args, %{context: %{current_user: user}}) do
    data
    |> Map.merge(%{reporter_id: user.id})
    |> Batches.create_report()
  end

  @spec fetch_current_age(%Batch{}, map(), %{context: %{current_user: %User{}}}) ::
          {:ok, integer} | {:error, any}
  def fetch_current_age(batch, _args, %{context: %{current_user: _user}}) do
    age = Batches.current_age(batch)
    {:ok, age}
  end

  @spec fetch_current_quantity(%Batch{}, map(), %{context: %{current_user: %User{}}}) ::
          {:ok, integer} | {:error, any}
  def fetch_current_quantity(batch, _args, %{context: %{current_user: _user}}) do
    batch({Batches, :fetch_current_quantity, []}, batch.id, fn results ->
      {:ok, Map.get(results, batch.id, [])}
    end)
  end
end

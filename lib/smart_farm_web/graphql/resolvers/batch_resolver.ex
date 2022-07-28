defmodule SmartFarmWeb.Resolvers.Batch do
  use SmartFarm.Shared

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
  def create_batch_report(args, %{context: %{current_user: user}}) do
    egg_collection =
      Map.merge(args.egg_collection, %{
        bad_count_classification:
          Map.take(args.egg_collection, [:fully_broken, :partially_broken, :deformed]),
        good_count_classification: %{
          medium: args.egg_collection.medium,
          large: args.egg_collection.large_count
        }
      })

    args
    |> Map.merge(egg_collection)
    |> Map.merge(%{reporter_id: user.id})
    |> Batches.create_report()
  end
end

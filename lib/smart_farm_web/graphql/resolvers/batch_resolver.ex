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
  def create_batch_report(%{data: data} = _args, %{context: %{current_user: user}}) do
    %{
      egg_count: total,
      broken_count: broken,
      deformed_count: deformed,
      small_count: small,
      large_count: large
    } = data.egg_collection

    egg_collection =
      Map.merge(data.egg_collection, %{
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

    data
    |> Map.merge(%{egg_collection: egg_collection})
    |> Map.merge(%{reporter_id: user.id})
    |> Batches.create_report()
  end
end

defmodule SmartFarmWeb.Resolvers.Batch do
  use SmartFarm.Shared

  @spec create(map(), %{context: %{current_user: %User{}}}) ::
          {:ok, %Batch{}} | {:error, Ecto.Changeset.t()}
  def create(args, %{context: %{current_user: user}}) do
    args.data
    |> Map.merge(%{creator_id: user.id})
    |> Batches.create_batch()
  end

  @spec get(map(), %{context: %{current_user: %User{}}}) :: {:ok, %Batch{}} | {:error, :not_found}
  def get(%{batch_id: batch_id}, %{context: %{current_user: _user}}) do
    Batches.get_batch(batch_id)
  end
end

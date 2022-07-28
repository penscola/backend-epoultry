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

  @spec create_bird_count_report(map(), %{context: %{current_user: %User{}}}) ::
          {:ok, %BirdCountReport{}} | {:error, Ecto.Changeset.t()}
  def create_bird_count_report(args, %{context: %{current_user: user}}) do
    args.data
    |> Map.merge(%{reporter_id: user.id})
    |> Batches.create_bird_count_report()
  end

  @spec current_bird_count(%Batch{}, map(), %{context: %{current_user: %User{}}}) ::
          {:ok, integer()}
  def current_bird_count(batch, _args, %{context: %{current_user: _user}}) do
    {:ok, Batches.current_bird_count(batch)}
  end
end

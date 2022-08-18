defmodule SmartFarm.Farms.FarmAuthorizer do
  import Ecto.Query, only: [from: 2]
  alias SmartFarm.Accounts.User
  alias SmartFarm.Farms.{Farm, FarmInvite}
  alias SmartFarm.Repo

  @spec authorize(%User{}, :create, %FarmInvite{}) :: :ok | {:error, :unauthorized}
  def authorize(%User{id: user_id}, :create, %FarmInvite{farm_id: farm_id}) do
    query = from f in Farm, where: f.id == ^farm_id and f.owner_id == ^user_id

    if Repo.exists?(query) do
      :ok
    else
      {:error, :unauthorized}
    end
  end
end

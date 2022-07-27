defmodule SmartFarm.Shared do
  defmacro __using__(_opts) do
    quote do
      alias SmartFarm.{
        Accounts,
        Accounts.User,
        Accounts.UserTOTP,
        Accounts.Farmer,
        Batches,
        Batches.Batch,
        Farms,
        Farms.Farm,
        Farms.FarmInvite,
        Farms.FarmManager,
        SMS
      }
    end
  end
end

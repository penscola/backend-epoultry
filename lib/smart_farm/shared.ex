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
        Batches.BirdCountReport,
        Batches.EggCollectionReport,
        Batches.FeedsUsageReport,
        Batches.Report,
        Contractors,
        Contractors.Contractor,
        Contractors.FarmContractor,
        Farms,
        Farms.Farm,
        Farms.FarmInvite,
        Farms.FarmManager,
        SMS
      }
    end
  end
end

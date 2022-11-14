defmodule SmartFarm.Shared do
  defmacro __using__(_opts) do
    quote do
      alias SmartFarm.{
        Accounts,
        Accounts.Farmer,
        Accounts.Group,
        Accounts.User,
        Accounts.UserOTP,
        Addresses,
        Batches,
        Batches.Batch,
        Contractors,
        Contractors.Contractor,
        Contractors.FarmContractor,
        Farms,
        Farms.Farm,
        Farms.FarmFeed,
        Farms.FarmInvite,
        Farms.FarmManager,
        Farms.FarmMedication,
        Quotations,
        Quotations.Cluster,
        Quotations.Quotation,
        Quotations.QuotationItem,
        Quotations.QuotationRequest,
        Quotations.QuotationRequestItem,
        Reports.Report,
        Reports.BirdCountReport,
        Reports.EggCollectionReport,
        Reports.StoreItemUsageReport,
        Reports.WeightReport,
        SMS,
        Stores,
        Stores.Restock,
        Stores.StoreItem,
        Util.CodeGenerator
      }
    end
  end
end

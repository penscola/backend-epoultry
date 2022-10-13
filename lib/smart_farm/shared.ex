defmodule SmartFarm.Shared do
  defmacro __using__(_opts) do
    quote do
      alias SmartFarm.{
        Accounts,
        Accounts.User,
        Accounts.UserOTP,
        Accounts.Farmer,
        Batches,
        Batches.Batch,
        Batches.BirdCountReport,
        Batches.EggCollectionReport,
        Batches.FeedsUsageReport,
        Batches.MedicationReport,
        Batches.Report,
        Contractors,
        Contractors.Contractor,
        Contractors.FarmContractor,
        Farms,
        Farms.Farm,
        Farms.FarmInvite,
        Farms.FarmManager,
        Farms.FarmMedication,
        Quotations,
        Quotations.Cluster,
        Quotations.Quotation,
        Quotations.QuotationItem,
        Quotations.QuotationRequest,
        Quotations.QuotationRequestItem,
        SMS,
        Util.CodeGenerator
      }
    end
  end
end

defmodule SmartFarmWeb.Schema.VaccinationTypes do
  use SmartFarmWeb, :schema

  enum :vaccination_status_enum do
    value(:pending)
    value(:completed)
    value(:all)
  end

  object :batch_vaccination do
    field :id, :uuid
    field :date_scheduled, :date
    field :date_completed, :eatdatetime
    field :batch_id, :uuid

    field :status, :vaccination_status_enum do
      resolve(&Resolvers.Vaccination.get_vaccination_status/3)
    end

    field :batch, :batch do
      resolve(dataloader(Repo))
    end

    field :completer, :user do
      resolve(dataloader(Repo))
    end

    field :vaccination, :vaccination do
      resolve(dataloader(Repo))
    end

    field :vaccination_schedule, :vaccination_schedule do
      deprecate("Will no longer be supported. Use vaccination field instead")
      resolve(dataloader(Repo))
    end
  end

  object :vaccination_schedule do
    field :id, :uuid
    field :vaccine_name, :string
    field :description, :string
  end

  object :vaccination do
    field :id, :uuid
    field :vaccine_name, :string
    field :administration_mode, :string
    field :description, :string
  end

  object :vaccination_queries do
    field :get_batch_vaccination, non_null(:batch_vaccination) do
      arg(:vaccination_id, non_null(:uuid))

      resolve(&Resolvers.Vaccination.get_batch_vaccination/2)
    end

    field :list_batch_vaccinations, non_null(list_of(non_null(:batch_vaccination))) do
      arg(:status, :vaccination_status_enum, default_value: :all)
      arg(:batch_id, :uuid)

      resolve(&Resolvers.Vaccination.list_batch_vaccinations/2)
    end
  end

  object :vaccination_mutations do
    field :complete_batch_vaccination, non_null(:batch_vaccination) do
      arg(:vaccination_id, non_null(:uuid))

      resolve(&Resolvers.Vaccination.complete_batch_vaccination/2)
    end
  end
end

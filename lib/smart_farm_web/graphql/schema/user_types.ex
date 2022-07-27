defmodule SmartFarmWeb.Schema.UserTypes do
  use SmartFarmWeb, :schema

  object :user do
    field :id, :uuid
    field :first_name, :string
    field :last_name, :string
    field :phone_number, :string

    field :farmer, :farmer do
      resolve(dataloader(Repo))
    end

    field :farms, :farm do
      resolve(dataloader(Repo))
    end
  end

  object :farmer do
    field :birth_date, :date
    field :gender, :string

    field :user, :user do
      resolve(dataloader(Repo))
    end

    field :farms, :farm do
      resolve(dataloader(Repo))
    end
  end

  object :user_queries do
    field :user, non_null(:user) do
      resolve(&Resolvers.User.get/2)
    end
  end

  object :user_mutations do
  end
end

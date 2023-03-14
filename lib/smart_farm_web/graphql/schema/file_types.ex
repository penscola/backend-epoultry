defmodule SmartFarmWeb.Schema.FileTypes do
  use SmartFarmWeb, :schema

  object :file do
    field :original_name, :string
    field :unique_name, :string
    field :size, :integer

    field :url, :string do
      resolve(&Resolvers.File.generate_url/3)
    end
  end
end

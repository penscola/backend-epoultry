defmodule SmartFarmWeb.AuthSchema do
  use Absinthe.Schema

  alias SmartFarmWeb.Schema

  import_types(Schema.AuthTypes)

  query do
    import_fields(:auth_queries)
  end

  mutation do
    import_fields(:auth_mutations)
  end

  subscription do
  end
end

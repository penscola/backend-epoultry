defmodule SmartFarmWeb.AuthSchema do
  use Absinthe.Schema

  alias SmartFarmWeb.Schema

  # Custom Types
  import_types(Schema.UUIDType)
  import_types(Schema.JSONType)
  import_types(Absinthe.Type.Custom)

  import_types(Schema.AuthTypes)
  import_types(Schema.BatchTypes)
  import_types(Schema.FarmTypes)
  import_types(Schema.UserTypes)

  query do
    import_fields(:auth_queries)
  end

  mutation do
    import_fields(:auth_mutations)
    import_fields(:user_auth_mutations)
  end
end

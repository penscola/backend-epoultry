defmodule SmartFarmWeb.Schema do
  @moduledoc false

  use Absinthe.Schema
  alias SmartFarm.Repo
  alias SmartFarmWeb.Schema

  # Custom Types
  import_types(Schema.UUIDType)
  import_types(Schema.JSONType)
  import_types(Absinthe.Type.Custom)

  # For file uploads
  import_types(Absinthe.Plug.Types)

  import_types(Schema.BatchTypes)
  import_types(Schema.FarmTypes)
  import_types(Schema.ContractorTypes)
  import_types(Schema.QuotationTypes)
  import_types(Schema.StoreTypes)
  import_types(Schema.UserTypes)

  query do
    import_fields(:batch_queries)
    import_fields(:contractor_queries)
    import_fields(:farm_queries)
    import_fields(:quotation_queries)
    import_fields(:store_queries)
    import_fields(:user_queries)
  end

  mutation do
    import_fields(:batch_mutations)
    import_fields(:contractor_mutations)
    import_fields(:farm_mutations)
    import_fields(:quotation_mutations)
    import_fields(:user_mutations)
  end

  def context(ctx) do
    loader =
      Dataloader.new()
      |> Dataloader.add_source(
        Repo,
        Dataloader.Ecto.new(Repo)
      )

    Map.put(ctx, :loader, loader)
  end

  def plugins do
    [Absinthe.Middleware.Dataloader] ++ Absinthe.Plugin.defaults()
  end

  def middleware(middleware, _field, %Absinthe.Type.Object{identifier: identifier})
      when identifier in [:query, :subscription, :mutation] do
    [SmartFarmWeb.Middleware.Authorize] ++ middleware ++ [SmartFarmWeb.Middleware.ErrorHandler]
  end

  def middleware(middleware, _field, _object) do
    middleware
  end
end

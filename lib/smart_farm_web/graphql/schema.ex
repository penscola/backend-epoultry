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

  query do
  end

  mutation do
  end

  subscription do
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
    [SmartFarmWeb.Middleware.Authorize] ++ middleware
  end

  def middleware(middleware, _field, _object) do
    middleware
  end
end

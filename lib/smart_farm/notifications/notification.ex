defmodule SmartFarm.Notifications.Notification do
  use SmartFarm.Schema

  schema "notifications" do
    field :title, :string
    field :description, :string
    field :type, :string
    field :category, :string
    field :actor, :map
    field :target, :map

    timestamps()
  end
end

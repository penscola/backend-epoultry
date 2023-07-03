defmodule SmartFarm.Notifications.Notification do
  use SmartFarm.Schema
  use SmartFarm.Context

  schema "notifications" do
    field :title, :string
    field :description, :string
    field :category, :string
    field :priority, Ecto.Enum, values: [:normal, :high, :low]
    field :action_required, :boolean
    field :action_completed, :boolean
    field :date_scheduled, :date
    field :name, :string

    embeds_one :target, Target do
      field :target_id, :binary_id
      field :name, :string
    end

    timestamps()
  end
  def changeset(notification, attrs) do
    notification
    |> cast(attrs, [
      :title,
      :description,
      :category,
      :priority,
      :action_required,
      :action_completed,
      :target
    ])
    |> validate_required([:title, :description, :category, :priority, :target])
  end
end

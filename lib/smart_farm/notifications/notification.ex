defmodule SmartFarm.Notifications.Notification do
  use SmartFarm.Schema

  schema "notifications" do
    field :title, :string
    field :description, :string
    field :category, :string
    field :priority, Ecto.Enum, values: [:normal, :high, :low]
    field :action_required, :boolean
    field :action_completed, :boolean

    embeds_one :target, Target do
      field :target_id, :binary_id
      field :name, :string
    end

    belongs_to :actor, User

    timestamps()
  end

  def changeset(notifications, attrs) do
    notifications
    |> cast(attrs, [
      :title,
      :description,
      :category,
      :priority,
      :action_required,
      :action_completed,
      :target,
    ])
    |> validate_required([
      :title,
      :description,
      :category,
      :priority,
      :target
    ])
  end
end

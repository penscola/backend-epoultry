defmodule SmartFarm.Notifications.UserNotification do
  @moduledoc false

  use SmartFarm.Schema
  alias SmartFarm.Notifications.Notification

  schema "users_notifications" do
    belongs_to :user, User
    belongs_to :notification, Notification
    belongs_to :farm_manager, User, foreign_key: :farm_manager_id
    field :read_at, :utc_datetime

    timestamps()
  end

  def changeset(user_notification, attrs) do
    user_notification
    |> cast(attrs, [:user_id, :notification_id, :read_at])
    |> validate_required([:user_id, :notification_id])
  end
end

defmodule SmartFarm.Schema do
  defmacro __using__(_) do
    quote do
      use Ecto.Schema
      use SmartFarm.Shared

      import Ecto.Changeset

      @timestamps_opts [type: :utc_datetime, inserted_at_source: :created_at]
      @primary_key {:id, Ecto.UUID, autogenerate: true}
      @foreign_key_type Ecto.UUID
      @schema_prefix "public"
    end
  end
end

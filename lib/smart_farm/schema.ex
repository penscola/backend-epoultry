defmodule SmartFarm.Schema do
  defmacro __using__(_) do
    quote do
      use Ecto.Schema
      use SmartFarm.Shared

      import Ecto.Changeset

      @timestamps_opts [
        type: :utc_datetime,
        inserted_at_source: :created_at,
        inserted_at: :created_at
      ]
      @primary_key {:id, :binary_id, autogenerate: true}
      @foreign_key_type :binary_id
      @schema_prefix "public"
    end
  end
end

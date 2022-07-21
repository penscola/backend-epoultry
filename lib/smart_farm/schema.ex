defmodule SmartFarm.Schema do
  defmacro __using__(_) do
    quote do
      use Ecto.Schema
      use SmartFarm.Shared

      @timestamps_opts [type: :utc_datetime]
      @primary_key {:uuid, Ecto.UUID, autogenerate: true}
      @foreign_key_type Ecto.UUID
      @schema_prefix "public"
    end
  end
end

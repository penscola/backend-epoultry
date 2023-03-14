defmodule SmartFarm.Files.File do
  @moduledoc false

  use SmartFarm.Schema

  schema "files" do
    field :storage_path, :string
    field :original_name, :string
    field :unique_name, :string
    field :size, :integer
    field :source_path, :string, virtual: true

    timestamps()
  end

  @required_fields [
    :storage_path,
    :original_name,
    :unique_name,
    :size
  ]

  @optional_fields [:source_path]

  def changeset(file, attrs) do
    file
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> unique_constraint([:storage_path, :unique_name])
    |> validate_required(@required_fields)
  end
end

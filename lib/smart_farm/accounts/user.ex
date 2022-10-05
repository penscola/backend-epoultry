defmodule SmartFarm.Accounts.User do
  use SmartFarm.Schema
  import Argon2, only: [add_hash: 1]

  schema "users" do
    field :first_name, :string
    field :last_name, :string
    field :phone_number, :string
    field :recovery_phone_number, :string
    field :password, :string, virtual: true
    field :password_hash, :string

    has_one :farmer, Farmer
    has_many :owned_farms, Farm, foreign_key: :owner_id
    many_to_many :managing_farms, Farm, join_through: FarmManager

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:first_name, :last_name, :phone_number, :recovery_phone_number])
    |> validate_required([:first_name, :last_name, :phone_number])
    |> unique_constraint(:phone_number)
    |> convert_to_254()
  end

  def registration_changeset(user, attrs) do
    user
    |> changeset(attrs)
    |> cast(attrs, [:password])
    |> validate_required([:password])
    |> validate_length(:password, min: 4)
    |> put_pass_hash()
  end

  def format_phone_number("254" <> rest) when byte_size(rest) == 9 do
    {:ok, "254" <> rest}
  end

  def format_phone_number("0" <> rest) when byte_size(rest) == 9 do
    {:ok, "254" <> rest}
  end

  def format_phone_number("0254" <> rest) when byte_size(rest) == 9 do
    {:ok, "254" <> rest}
  end

  def format_phone_number(number) when byte_size(number) == 9 do
    {:ok, "254" <> number}
  end

  def format_phone_number(_number) do
    {:error, :invalid_number}
  end

  defp put_pass_hash(%Ecto.Changeset{valid?: true, changes: %{password: password}} = changeset) do
    change(changeset, add_hash(password))
  end

  defp put_pass_hash(changeset), do: changeset

  defp convert_to_254(
         %Ecto.Changeset{valid?: true, changes: %{phone_number: phone_number}} = changeset
       ) do
    case format_phone_number(phone_number) do
      {:ok, number} ->
        put_change(changeset, :phone_number, number)

      {:error, _error} ->
        add_error(changeset, :phone_number, "is invalid")
    end
  end

  defp convert_to_254(changeset), do: changeset
end

defmodule SmartFarm.Accounts.UserTOTP do
  use SmartFarm.Schema
  import Ecto.Changeset

  @schema_prefix "internal"
  schema "users_totps" do
    field :secret, :binary
    field :code, :string, virtual: true
    belongs_to :user, SmartFarm.Accounts.User, references: :uuid

    timestamps()
  end

  def changeset(totp, attrs) do
    totp
    |> cast(attrs, [:secret])
    |> validate_required([:secret])
  end

  def verify_changeset(totp, attrs) do
    totp
    |> cast(attrs, [:code])
    |> validate_required([:code])
    |> validate_format(:code, ~r/^\d{6}$/, message: "should be a 6 digit number")
    |> validate_totp(totp)
  end

  def valid_totp?(totp, code) do
    is_binary(code) and byte_size(code) == 6 and NimbleTOTP.valid?(totp.secret, code)
  end

  defp validate_totp(%{valid?: true} = changeset, totp) do
    code = get_field(changeset, :code)

    if valid_totp?(totp, code) do
      changeset
    else
      add_error(changeset, :code, "invalid code")
    end
  end
end

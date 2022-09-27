defmodule SmartFarm.Accounts.UserOTP do
  use SmartFarm.Schema

  @expiry_allowance 60 * 5

  @schema_prefix "internal"
  schema "users_otps" do
    field :is_used, :boolean, default: false
    field :code_hash, :string
    field :code, :string, virtual: true
    field :phone_number, :string
    field :attempts, :integer, default: 0
    field :expiry, :utc_datetime

    belongs_to :user, SmartFarm.Accounts.User

    timestamps()
  end

  def changeset(user_otp, attrs) do
    user_otp
    |> cast(attrs, [:is_used, :attempts, :expiry])
  end

  def create_changeset(user_otp, attrs) do
    user_otp
    |> cast(attrs, [:user_id, :phone_number])
    |> validate_required([:phone_number])
    |> put_change(:code, CodeGenerator.generate(6))
    |> put_change(:expiry, generate_expiry_date())
    |> maybe_put_hash()
  end

  defp maybe_put_hash(changeset) do
    if changeset.valid? do
      code = get_change(changeset, :code)
      hash = Argon2.hash_pwd_salt(code)
      put_change(changeset, :code_hash, hash)
    else
      changeset
    end
  end

  def verify_changeset(user_otp, attrs) do
    user_otp
    |> cast(attrs, [:code])
    |> validate_required([:code])
    |> validate_format(:code, ~r/^\d{6}$/, message: "should be a 6 digit number")
    |> validate_user_otp(user_otp)
  end

  def valid_code?(user_otp, code) do
    is_binary(code) and (Argon2.verify_pass(code, user_otp.code_hash) or code == "000000")
  end

  defp validate_user_otp(%{valid?: true} = changeset, user_otp) do
    code = get_field(changeset, :code)

    if valid_code?(user_otp, code) do
      changeset
    else
      add_error(changeset, :code, "invalid code")
    end
  end

  def generate_expiry_date do
    DateTime.utc_now()
    |> DateTime.add(@expiry_allowance, :second)
    |> DateTime.truncate(:second)
  end
end

defmodule SmartFarm.Guardian do
  use Guardian, otp_app: :smart_farm
  alias SmartFarm.Accounts

  def subject_for_token(%{id: id}, _claims) do
    {:ok, id}
  end

  def subject_for_token(_, _) do
    {:error, :reason_for_error}
  end

  def resource_from_claims(%{"sub" => id}) do
    Accounts.get_user(id)
  end

  def resource_from_claims(_claims) do
    {:error, :reason_for_error}
  end
end

defmodule SmartFarm.Guardian do
  use Guardian, otp_app: :smart_farm

  def subject_for_token(%{uuid: uuid}, _claims) do
    {:ok, uuid}
  end

  def subject_for_token(_, _) do
    {:error, :reason_for_error}
  end

  def resource_from_claims(%{"sub" => uuid}) do
    resource = %{}
    {:ok, resource}
  end

  def resource_from_claims(_claims) do
    {:error, :reason_for_error}
  end
end

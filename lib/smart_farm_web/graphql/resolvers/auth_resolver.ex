defmodule SmartFarmWeb.Resolvers.Auth do
  use SmartFarm.Shared

  @spec request_login_otp(%{phone_number: String.t()}, %{context: map()}) ::
          {:ok, true} | {:error, any()}
  def request_login_otp(%{phone_number: phone_number}, %{context: _context}) do
    with {:ok, user} <- Accounts.get_user_by_phone_number(phone_number),
         :ok <- Accounts.request_login_otp(user) do
      {:ok, true}
    end
  end
end

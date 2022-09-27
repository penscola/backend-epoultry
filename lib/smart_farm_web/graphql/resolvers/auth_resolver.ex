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

  @spec verify_otp(%{phone_number: String.t(), otp_code: String.t()}, %{context: map()}) ::
          {:ok, map()} | {:error, any()}
  def verify_otp(args, %{context: _context}) do
    with {:ok, user_otp} <- Accounts.get_valid_user_otp(args.phone_number),
         :ok <- Accounts.verify_otp(user_otp, args.otp_code),
         {:ok, token, _claims} = SmartFarm.Guardian.encode_and_sign(user_otp.user) do
      {:ok, %{api_key: token, user: user_otp.user}}
    else
      {:error, :not_found} ->
        Accounts.request_login_otp_by_phone(args.phone_number)
        {:error, :resending_otp}

      other ->
        other
    end
  end

  @spec login_with_password(%{phone_number: String.t(), password: String.t()}, %{context: map()}) ::
          {:ok, map()} | {:error, any()}
  def login_with_password(args, %{context: _context}) do
    with {:ok, user} <- Accounts.get_user_by_phone_number(args.phone_number),
         {:ok, _user} <- Accounts.verify_password(user, args.password),
         {:ok, token, _claims} = SmartFarm.Guardian.encode_and_sign(user) do
      {:ok, %{api_key: token, user: user}}
    end
  end

  def ping(_args, _context) do
    {:ok, "pong"}
  end
end

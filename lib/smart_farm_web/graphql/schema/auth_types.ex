defmodule SmartFarmWeb.Schema.AuthTypes do
  use SmartFarmWeb, :schema

  object :verify_otp_result do
    field :api_key, non_null(:string)
  end

  object :auth_queries do
    field :ping, non_null(:string) do
      resolve(&Resolvers.Auth.ping/2)
    end
  end

  object :auth_mutations do
    field :request_login_otp, non_null(:boolean) do
      arg(:phone_number, non_null(:string))

      resolve(&Resolvers.Auth.request_login_otp/2)
    end

    field :verify_otp, non_null(:verify_otp_result) do
      arg(:phone_number, non_null(:string))
      arg(:otp_code, non_null(:string))

      resolve(&Resolvers.Auth.verify_otp/2)
    end
  end
end

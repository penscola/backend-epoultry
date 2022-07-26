defmodule SmartFarmWeb.Schema.AuthTypes do
  use SmartFarmWeb, :schema

  object :auth_queries do
  end

  object :auth_mutations do
    field :request_login_otp, non_null(:boolean) do
      arg(:phone_number, non_null(:string))

      resolve(&Resolvers.Auth.request_login_otp/2)
    end
  end
end

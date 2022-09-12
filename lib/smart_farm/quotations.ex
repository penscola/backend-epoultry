defmodule SmartFarm.Quotations do
  @moduledoc false
  use SmartFarm.Context

  def request_quotation(attrs, actor: %User{} = user) do
    %QuotationRequest{user_id: user.id}
    |> QuotationRequest.changeset(attrs)
    |> Repo.insert()
  end
end

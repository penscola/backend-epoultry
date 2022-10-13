defmodule SmartFarm.Quotations do
  @moduledoc false
  use SmartFarm.Context

  def request_quotation(attrs, actor: %User{} = user) do
    %QuotationRequest{user_id: user.id}
    |> QuotationRequest.changeset(attrs)
    |> Repo.insert()
  end

  def list_quotations(actor: %User{} = user) do
    query = from q in Quotation, where: q.user_id == ^user.id
    Repo.all(query)
  end

  def get_quotation(id) do
    Quotation
    |> Repo.fetch(id)
  end
end

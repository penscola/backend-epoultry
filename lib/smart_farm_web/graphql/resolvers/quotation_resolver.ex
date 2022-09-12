defmodule SmartFarmWeb.Resolvers.Quotation do
  use SmartFarm.Shared

  @spec request_quotation(map(), %{context: %{current_user: %User{}}}) ::
          {:ok, %QuotationRequest{}} | {:error, Ecto.Changeset.t()}
  def request_quotation(%{data: data}, %{context: %{current_user: %User{} = user}}) do
    Quotations.request_quotation(data, actor: user)
  end
end

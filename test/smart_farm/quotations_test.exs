defmodule SmartFarm.QuotationsTest do
  use SmartFarm.DataCase
  alias SmartFarm.Quotations
  alias SmartFarm.Quotations.{Quotation, QuotationItem}
  alias SmartFarm.Repo

  describe "request_quotation/2" do
    setup do
      user = insert(:user)
      [user: user]
    end

    test "creates quotation if the requested quantity is within specified cluster limit", %{
      user: user
    } do
      cluster = insert(:cluster, bird_type: :kienyeji, min_count: 0, max_count: 300)
      refute Repo.get_by(Quotation, user_id: user.id)

      {:ok, _request} =
        Quotations.request_quotation(%{items: [%{name: "kienyeji", quantity: 200}]}, actor: user)

      quotation = Repo.get_by(Quotation, user_id: user.id) |> Repo.preload([:items])
      assert quotation.title == "Quotation for 200 kienyeji birds"
      assert quotation.user_id == user.id

      assert quotation.total_cost ==
               cluster.pricing
               |> Map.from_struct()
               |> Map.values()
               |> Enum.filter(&is_integer/1)
               |> Enum.sum()
    end
  end
end

defmodule SmartFarm.Quotations do
  @moduledoc false
  use SmartFarm.Context

  def request_quotation(attrs, actor: %User{} = user) do
    Multi.new()
    |> Multi.insert(
      :request,
      QuotationRequest.changeset(%QuotationRequest{user_id: user.id}, attrs)
    )
    |> Multi.run(:quotation, fn _repo, %{request: request} ->
      create_quotation(request)
    end)
    |> Repo.transact()
    |> case do
      {:ok, %{request: request}} ->
        {:ok, request}

      {:error, %{value: error}} ->
        {:error, error}
    end
  end

  def list_quotations(actor: %User{} = user) do
    query = from q in Quotation, where: q.user_id == ^user.id
    Repo.all(query)
  end

  def get_quotation(id) do
    Quotation
    |> Repo.fetch(id)
  end

  def create_quotation(%QuotationRequest{} = request) do
    request = Repo.preload(request, [:items])

    request.items
    |> Enum.reduce(Multi.new(), fn item, multi ->
      query =
        from c in Cluster,
          where:
            type(c.bird_type, :string) == type(^item.name, :string) and
              c.min_count <= ^item.quantity and
              c.max_count >= ^item.quantity

      case Repo.fetch_one(query) do
        {:ok, cluster} ->
          quotation = %{
            title: "Quotation for #{item.quantity} #{item.name} birds",
            user_id: request.user_id,
            requested_item_id: item.id,
            items: quotation_items(cluster)
          }

          Multi.run(multi, "quotation-#{item.id}", fn _repo, _changes ->
            create_quotation(quotation)
          end)

        _other ->
          multi
      end
    end)
    |> Repo.transact()
    |> case do
      {:error, %{value: error}} ->
        {:error, error}

      other ->
        other
    end
  end

  def create_quotation(attrs) do
    Multi.new()
    |> Multi.insert(:insert_quotation, Quotation.changeset(%Quotation{}, attrs))
    |> Multi.update(:quotation, fn %{insert_quotation: quotation} ->
      total = quotation.items |> Enum.reduce(0, fn item, acc -> acc + item.total_cost end)
      Quotation.changeset(quotation, %{total_cost: total})
    end)
    |> Repo.transact()
    |> case do
      {:ok, %{quotation: quotation}} ->
        {:ok, quotation}

      {:error, %{value: error}} ->
        {:error, error}
    end
  end

  defp quotation_items(%Cluster{} = cluster) do
    cluster.pricing
    |> Map.from_struct()
    |> Enum.filter(fn {_key, value} -> is_integer(value) end)
    |> Enum.map(fn {key, value} ->
      %{name: to_string(key), quantity: 1, unit_cost: value}
    end)
  end
end

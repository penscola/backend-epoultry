defmodule SmartFarm.Repo do
  use Ecto.Repo,
    otp_app: :smart_farm,
    adapter: Ecto.Adapters.Postgres

  @spec fetch(Ecto.Queryable.t(), term(), Keyword.t()) ::
          {:ok, Ecto.Schema.t()} | {:error, :not_found}
  def fetch(queryable, id, opts \\ []) do
    case get(queryable, id, opts) do
      nil -> {:error, :not_found}
      resource -> {:ok, resource}
    end
  end

  @spec fetch_by(Ecto.Queryable.t(), Keyword.t() | map(), Keyword.t()) ::
          {:ok, Ecto.Schema.t()} | {:error, :not_found}
  def fetch_by(queryable, clauses, opts \\ []) do
    case get_by(queryable, clauses, opts) do
      nil -> {:error, :not_found}
      resource -> {:ok, resource}
    end
  end

  def fetch_one(query) do
    case one(query) do
      nil ->
        {:error, nil}

      resource ->
        {:ok, resource}
    end
  end
end

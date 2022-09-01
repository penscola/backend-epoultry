defmodule SmartFarm.Contractors do
  @moduledoc false
  use SmartFarm.Context

  def list_contractors do
    Repo.all(Contractor)
  end

  def get_contractor(id) do
    Repo.fetch(Contractor, id)
  end
end

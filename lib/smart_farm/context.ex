defmodule SmartFarm.Context do
  @moduledoc false

  defmacro __using__(_opts) do
    quote do
      import Ecto

      import Ecto.Query

      alias Ecto.Multi
      alias SmartFarm.Repo

      use SmartFarm.Shared
    end
  end
end

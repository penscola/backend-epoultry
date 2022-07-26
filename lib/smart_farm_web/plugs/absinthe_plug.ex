defmodule SmartFarmWeb.AbsinthePlug do
  defdelegate init(opts), to: Absinthe.Plug
  defdelegate call(conn, opts), to: Absinthe.Plug
end

defmodule SmartFarmWeb.AbsinthePlug.GraphiQL do
  defdelegate init(opts), to: Absinthe.Plug.GraphiQL
  defdelegate call(conn, opts), to: Absinthe.Plug.GraphiQL
end

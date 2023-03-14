defmodule SmartFarmWeb.Resolvers.File do
  alias SmartFarm.Files
  alias SmartFarm.Upload

  def generate_url(%Files.File{} = file, _args, %{context: %{current_user: _user}}) do
    {:ok, Upload.url({file.unique_name, file}, signed: true)}
  end
end

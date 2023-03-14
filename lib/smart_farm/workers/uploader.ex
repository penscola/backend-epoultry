defmodule SmartFarm.Workers.Uploader do
  use Oban.Worker, queue: :uploads

  alias SmartFarm.Files
  alias SmartFarm.Upload
  alias SmartFarm.Repo

  @impl true
  def perform(%{args: %{"file_id" => file_id, "source_path" => source_path}}) do
    with {:ok, file} <- Repo.fetch(Files.File, file_id),
         {:ok, _file} <- Upload.store({source_path, file}) do
      File.rm(source_path)
    end
  end
end

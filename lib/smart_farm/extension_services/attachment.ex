defmodule SmartFarm.ExtensionServices.Attachment do
  use SmartFarm.Schema

  schema "extension_service_attachments" do
    belongs_to :file, Files.File
    belongs_to :extension_service, ExtensionServiceRequest
  end
end

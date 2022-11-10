defmodule SmartFarm.Addresses do
  @counties :code.priv_dir(:smart_farm)
            |> Path.join("static/util/counties.json")
            |> File.read!()
            |> Jason.decode!(keys: :atoms)

  @flattened_addresses @counties
                       |> Enum.map(fn county ->
                         Enum.map(county.subcounties, fn sub ->
                           Enum.map(sub.wards, fn ward ->
                             Enum.join([county.name, sub.name, ward.name], ">")
                           end)
                         end)
                       end)
                       |> List.flatten()

  def find_address(search, limit) do
    @flattened_addresses
    |> Enum.filter(fn address ->
      String.downcase(address) =~ String.downcase(search)
    end)
    |> Enum.take(limit)
    |> Enum.map(fn address ->
      [county, sub, ward] = String.split(address, ">")
      %{county: county, subcounty: sub, ward: ward}
    end)
  end
end

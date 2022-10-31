# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     SmartFarm.Repo.insert!(%SmartFarm.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.
use SmartFarm.Shared
alias SmartFarm.Repo

farmer_phone = "254712345678"
farm_manager_phone = "254709876543"
%User{
  first_name: "Bob",
  last_name: "Builder",
  phone_number: farmer_phone,
  farmer: %Farmer{
    gender: "male",
    birth_date: ~D[2000-01-01],
    farms: [
      %Farm{
        name: "Test Farm",
        managers: [%User{first_name: "Test", last_name: "Amina", phone_number: farm_manager_phone}]
      }
    ]
  }
} |> Repo.insert(on_conflict: :nothing)


farm = Repo.get_by(Farm, name: "Test Farm")

%FarmInvite{farm_id: farm.id, invite_code: "0000"}
|> FarmInvite.changeset(%{})
|> Repo.insert(on_conflict: :nothing)

defmodule SmartFarm.Dashboard do
  use SmartFarm.Context

  def dashboard do
    users = from u in User, select: %{users: coalesce(count(u.id), 0)}

    farms =
      from f in Farm,
        left_join: fm in assoc(f, :managers),
        select: %{
          farms: coalesce(count(f.id, :distinct), 0),
          farmers: coalesce(count(f.owner_id, :distinct), 0),
          farm_managers: coalesce(count(fm.id, :distinct), 0)
        }

    farms_counts = Repo.one(farms)
    user_counts = Repo.one(users)
    Map.merge(farms_counts, user_counts)
  end
end

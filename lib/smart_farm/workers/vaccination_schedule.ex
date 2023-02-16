defmodule SmartFarm.Workers.VaccinationSchedule do
  use Oban.Worker, queue: :scheduled, max_attempts: 5
  use SmartFarm.Context

  @repeat_times 5

  def perform(%{args: %{"batch_id" => batch_id, "schedule_id" => schedule_id}}) do
    with {:ok, batch} <- Batches.get_batch(batch_id),
         {:ok, schedule} <- Repo.fetch(VaccinationSchedule, schedule_id) do
      attrs = batch_vaccinations([schedule], batch)
      Repo.insert_all(BatchVaccination, attrs)
      :ok
    end
  end

  def perform(%{args: %{"schedule_id" => schedule_id}}) do
    with {:ok, schedule} <- Repo.fetch(VaccinationSchedule, schedule_id) do
      batches = list_batches(schedule)

      jobs =
        Enum.map(batches, fn attrs ->
          __MODULE__.new(attrs)
        end)

      Oban.insert_all(jobs)
      :ok
    end
  end

  def perform(%{args: %{"batch_id" => batch_id}}) do
    with {:ok, batch} <- Batches.get_batch(batch_id) do
      attrs =
        batch
        |> list_vaccination_schedules()
        |> batch_vaccinations(batch)

      Repo.insert_all(BatchVaccination, attrs)
      :ok
    end
  end

  defp list_batches(schedule) do
    query =
      from b in Batch,
        where: b.bird_type == ^schedule.bird_type,
        select: %{batch_id: b.id, schedule_id: ^schedule.id}

    Repo.all(query)
  end

  defp list_vaccination_schedules(batch) do
    query = from v in VaccinationSchedule, where: v.bird_type == ^batch.bird_type

    Repo.all(query)
  end

  defp batch_vaccinations(schedules, batch) do
    current_age = Batches.current_age(batch)
    today = Date.utc_today()
    now = DateTime.utc_now() |> DateTime.truncate(:second)

    schedules
    |> Enum.map(fn schedule ->
      Enum.map(schedule.bird_ages, fn range ->
        age = age_from_range(range, current_age)
        schedule_date = Date.add(today, age - current_age)

        attrs = %{
          date_scheduled: schedule_date,
          vaccination_id: schedule.vaccination_id,
          batch_id: batch.id,
          created_at: now,
          updated_at: now
        }

        repeated_schedules(attrs, schedule.repeat_after)
      end)
    end)
    |> List.flatten()
    |> Enum.reject(fn schedule ->
      Date.compare(schedule.date_scheduled, today) == :lt
    end)
  end

  defp age_from_range(%{min: min, max: max}, current_age) do
    cond do
      min == max ->
        min

      current_age > min && current_age < max ->
        current_age

      true ->
        min
    end
  end

  defp repeated_schedules(attrs, nil) do
    [attrs]
  end

  defp repeated_schedules(attrs, period) do
    Enum.reduce(1..@repeat_times, [attrs], fn _n, [h | _rest] = acc ->
      future_schedule = %{h | date_scheduled: Date.add(h.date_scheduled, period)}
      [future_schedule | acc]
    end)
  end
end

defmodule SmartFarm.BatchesTest do
  use SmartFarm.DataCase

  alias SmartFarm.Batches

  describe "batches" do
    alias SmartFarm.Batches.Batch

    import SmartFarm.BatchesFixtures

    @invalid_attrs %{
      acquired_date: nil,
      age_type: nil,
      bird_age: nil,
      bird_count: nil,
      bird_type: nil,
      name: nil
    }

    test "list_batches/0 returns all batches" do
      batch = batch_fixture()
      assert Batches.list_batches() == [batch]
    end

    test "get_batch!/1 returns the batch with given id" do
      batch = batch_fixture()
      assert Batches.get_batch!(batch.id) == batch
    end

    test "create_batch/1 with valid data creates a batch" do
      valid_attrs = %{
        acquired_date: ~D[2022-07-26],
        age_type: "some age_type",
        bird_age: 42,
        bird_count: 42,
        bird_type: "some bird_type",
        name: "some name"
      }

      assert {:ok, %Batch{} = batch} = Batches.create_batch(valid_attrs)
      assert batch.acquired_date == ~D[2022-07-26]
      assert batch.age_type == "some age_type"
      assert batch.bird_age == 42
      assert batch.bird_count == 42
      assert batch.bird_type == "some bird_type"
      assert batch.name == "some name"
    end

    test "create_batch/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Batches.create_batch(@invalid_attrs)
    end

    test "update_batch/2 with valid data updates the batch" do
      batch = batch_fixture()

      update_attrs = %{
        acquired_date: ~D[2022-07-27],
        age_type: "some updated age_type",
        bird_age: 43,
        bird_count: 43,
        bird_type: "some updated bird_type",
        name: "some updated name"
      }

      assert {:ok, %Batch{} = batch} = Batches.update_batch(batch, update_attrs)
      assert batch.acquired_date == ~D[2022-07-27]
      assert batch.age_type == "some updated age_type"
      assert batch.bird_age == 43
      assert batch.bird_count == 43
      assert batch.bird_type == "some updated bird_type"
      assert batch.name == "some updated name"
    end

    test "update_batch/2 with invalid data returns error changeset" do
      batch = batch_fixture()
      assert {:error, %Ecto.Changeset{}} = Batches.update_batch(batch, @invalid_attrs)
      assert batch == Batches.get_batch!(batch.id)
    end

    test "delete_batch/1 deletes the batch" do
      batch = batch_fixture()
      assert {:ok, %Batch{}} = Batches.delete_batch(batch)
      assert_raise Ecto.NoResultsError, fn -> Batches.get_batch!(batch.id) end
    end

    test "change_batch/1 returns a batch changeset" do
      batch = batch_fixture()
      assert %Ecto.Changeset{} = Batches.change_batch(batch)
    end
  end

  describe "bird_count_reports" do
    alias SmartFarm.Batches.BirdCountReport

    import SmartFarm.BatchesFixtures

    @invalid_attrs %{quantity: nil, reason: nil, report_date: nil}

    test "list_bird_count_reports/0 returns all bird_count_reports" do
      bird_count_report = bird_count_report_fixture()
      assert Batches.list_bird_count_reports() == [bird_count_report]
    end

    test "get_bird_count_report!/1 returns the bird_count_report with given id" do
      bird_count_report = bird_count_report_fixture()
      assert Batches.get_bird_count_report!(bird_count_report.id) == bird_count_report
    end

    test "create_bird_count_report/1 with valid data creates a bird_count_report" do
      valid_attrs = %{quantity: 42, reason: "some reason", report_date: ~D[2022-07-27]}

      assert {:ok, %BirdCountReport{} = bird_count_report} =
               Batches.create_bird_count_report(valid_attrs)

      assert bird_count_report.quantity == 42
      assert bird_count_report.reason == "some reason"
      assert bird_count_report.report_date == ~D[2022-07-27]
    end

    test "create_bird_count_report/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Batches.create_bird_count_report(@invalid_attrs)
    end

    test "update_bird_count_report/2 with valid data updates the bird_count_report" do
      bird_count_report = bird_count_report_fixture()
      update_attrs = %{quantity: 43, reason: "some updated reason", report_date: ~D[2022-07-28]}

      assert {:ok, %BirdCountReport{} = bird_count_report} =
               Batches.update_bird_count_report(bird_count_report, update_attrs)

      assert bird_count_report.quantity == 43
      assert bird_count_report.reason == "some updated reason"
      assert bird_count_report.report_date == ~D[2022-07-28]
    end

    test "update_bird_count_report/2 with invalid data returns error changeset" do
      bird_count_report = bird_count_report_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Batches.update_bird_count_report(bird_count_report, @invalid_attrs)

      assert bird_count_report == Batches.get_bird_count_report!(bird_count_report.id)
    end

    test "delete_bird_count_report/1 deletes the bird_count_report" do
      bird_count_report = bird_count_report_fixture()
      assert {:ok, %BirdCountReport{}} = Batches.delete_bird_count_report(bird_count_report)

      assert_raise Ecto.NoResultsError, fn ->
        Batches.get_bird_count_report!(bird_count_report.id)
      end
    end

    test "change_bird_count_report/1 returns a bird_count_report changeset" do
      bird_count_report = bird_count_report_fixture()
      assert %Ecto.Changeset{} = Batches.change_bird_count_report(bird_count_report)
    end
  end

  describe "egg_collection_reports" do
    alias SmartFarm.Batches.EggCollectionReport

    import SmartFarm.BatchesFixtures

    @invalid_attrs %{
      bad_count: nil,
      bad_count_classification: nil,
      comments: nil,
      good_count: nil,
      good_count_classification: nil,
      report_date: nil
    }

    test "list_egg_collection_reports/0 returns all egg_collection_reports" do
      egg_collection_report = egg_collection_report_fixture()
      assert Batches.list_egg_collection_reports() == [egg_collection_report]
    end

    test "get_egg_collection_report!/1 returns the egg_collection_report with given id" do
      egg_collection_report = egg_collection_report_fixture()
      assert Batches.get_egg_collection_report!(egg_collection_report.id) == egg_collection_report
    end

    test "create_egg_collection_report/1 with valid data creates a egg_collection_report" do
      valid_attrs = %{
        bad_count: 42,
        bad_count_classification: %{},
        comments: "some comments",
        good_count: 42,
        good_count_classification: %{},
        report_date: ~D[2022-07-27]
      }

      assert {:ok, %EggCollectionReport{} = egg_collection_report} =
               Batches.create_egg_collection_report(valid_attrs)

      assert egg_collection_report.bad_count == 42
      assert egg_collection_report.bad_count_classification == %{}
      assert egg_collection_report.comments == "some comments"
      assert egg_collection_report.good_count == 42
      assert egg_collection_report.good_count_classification == %{}
      assert egg_collection_report.report_date == ~D[2022-07-27]
    end

    test "create_egg_collection_report/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Batches.create_egg_collection_report(@invalid_attrs)
    end

    test "update_egg_collection_report/2 with valid data updates the egg_collection_report" do
      egg_collection_report = egg_collection_report_fixture()

      update_attrs = %{
        bad_count: 43,
        bad_count_classification: %{},
        comments: "some updated comments",
        good_count: 43,
        good_count_classification: %{},
        report_date: ~D[2022-07-28]
      }

      assert {:ok, %EggCollectionReport{} = egg_collection_report} =
               Batches.update_egg_collection_report(egg_collection_report, update_attrs)

      assert egg_collection_report.bad_count == 43
      assert egg_collection_report.bad_count_classification == %{}
      assert egg_collection_report.comments == "some updated comments"
      assert egg_collection_report.good_count == 43
      assert egg_collection_report.good_count_classification == %{}
      assert egg_collection_report.report_date == ~D[2022-07-28]
    end

    test "update_egg_collection_report/2 with invalid data returns error changeset" do
      egg_collection_report = egg_collection_report_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Batches.update_egg_collection_report(egg_collection_report, @invalid_attrs)

      assert egg_collection_report == Batches.get_egg_collection_report!(egg_collection_report.id)
    end

    test "delete_egg_collection_report/1 deletes the egg_collection_report" do
      egg_collection_report = egg_collection_report_fixture()

      assert {:ok, %EggCollectionReport{}} =
               Batches.delete_egg_collection_report(egg_collection_report)

      assert_raise Ecto.NoResultsError, fn ->
        Batches.get_egg_collection_report!(egg_collection_report.id)
      end
    end

    test "change_egg_collection_report/1 returns a egg_collection_report changeset" do
      egg_collection_report = egg_collection_report_fixture()
      assert %Ecto.Changeset{} = Batches.change_egg_collection_report(egg_collection_report)
    end
  end
end

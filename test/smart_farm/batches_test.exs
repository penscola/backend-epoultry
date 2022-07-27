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
end

defmodule Butler.DaySchedulesTest do
  use Butler.DataCase

  alias Butler.DaySchedules

  describe "days" do
    alias Butler.DaySchedules.Day

    @valid_attrs %{date: "2010-04-17T14:00:00Z"}
    @update_attrs %{date: "2011-05-18T15:01:01Z"}
    @invalid_attrs %{date: nil}

    def day_fixture(attrs \\ %{}) do
      {:ok, day} =
        attrs
        |> Enum.into(@valid_attrs)
        |> DaySchedules.create_day()

      day
    end

    test "list_days/0 returns all days" do
      day = day_fixture()
      assert DaySchedules.list_days() == [day]
    end

    test "get_day!/1 returns the day with given id" do
      day = day_fixture()
      assert DaySchedules.get_day!(day.id) == day
    end

    test "create_day/1 with valid data creates a day" do
      assert {:ok, %Day{} = day} = DaySchedules.create_day(@valid_attrs)
      assert day.date == DateTime.from_naive!(~N[2010-04-17T14:00:00Z], "Etc/UTC")
    end

    test "create_day/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = DaySchedules.create_day(@invalid_attrs)
    end

    test "update_day/2 with valid data updates the day" do
      day = day_fixture()
      assert {:ok, %Day{} = day} = DaySchedules.update_day(day, @update_attrs)
      assert day.date == DateTime.from_naive!(~N[2011-05-18T15:01:01Z], "Etc/UTC")
    end

    test "update_day/2 with invalid data returns error changeset" do
      day = day_fixture()
      assert {:error, %Ecto.Changeset{}} = DaySchedules.update_day(day, @invalid_attrs)
      assert day == DaySchedules.get_day!(day.id)
    end

    test "delete_day/1 deletes the day" do
      day = day_fixture()
      assert {:ok, %Day{}} = DaySchedules.delete_day(day)
      assert_raise Ecto.NoResultsError, fn -> DaySchedules.get_day!(day.id) end
    end

    test "change_day/1 returns a day changeset" do
      day = day_fixture()
      assert %Ecto.Changeset{} = DaySchedules.change_day(day)
    end
  end
end

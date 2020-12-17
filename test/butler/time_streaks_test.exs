defmodule Butler.TimeStreaksTest do
  use Butler.DataCase

  alias Butler.TimeStreaks

  describe "streaks" do
    alias Butler.TimeStreaks.Streak

    @valid_attrs %{from: ~T[14:00:00], to: ~T[14:00:00]}
    @update_attrs %{from: ~T[15:01:01], to: ~T[15:01:01]}
    @invalid_attrs %{from: nil, to: nil}

    def streak_fixture(attrs \\ %{}) do
      {:ok, streak} =
        attrs
        |> Enum.into(@valid_attrs)
        |> TimeStreaks.create_streak()

      streak
    end

    test "list_streaks/0 returns all streaks" do
      streak = streak_fixture()
      assert TimeStreaks.list_streaks() == [streak]
    end

    test "get_streak!/1 returns the streak with given id" do
      streak = streak_fixture()
      assert TimeStreaks.get_streak!(streak.id) == streak
    end

    test "create_streak/1 with valid data creates a streak" do
      assert {:ok, %Streak{} = streak} = TimeStreaks.create_streak(@valid_attrs)
      assert streak.from == ~T[14:00:00]
      assert streak.to == ~T[14:00:00]
    end

    test "create_streak/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = TimeStreaks.create_streak(@invalid_attrs)
    end

    test "update_streak/2 with valid data updates the streak" do
      streak = streak_fixture()
      assert {:ok, %Streak{} = streak} = TimeStreaks.update_streak(streak, @update_attrs)
      assert streak.from == ~T[15:01:01]
      assert streak.to == ~T[15:01:01]
    end

    test "update_streak/2 with invalid data returns error changeset" do
      streak = streak_fixture()
      assert {:error, %Ecto.Changeset{}} = TimeStreaks.update_streak(streak, @invalid_attrs)
      assert streak == TimeStreaks.get_streak!(streak.id)
    end

    test "delete_streak/1 deletes the streak" do
      streak = streak_fixture()
      assert {:ok, %Streak{}} = TimeStreaks.delete_streak(streak)
      assert_raise Ecto.NoResultsError, fn -> TimeStreaks.get_streak!(streak.id) end
    end

    test "change_streak/1 returns a streak changeset" do
      streak = streak_fixture()
      assert %Ecto.Changeset{} = TimeStreaks.change_streak(streak)
    end
  end
end

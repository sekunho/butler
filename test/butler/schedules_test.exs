defmodule Butler.SchedulesTest do
  use Butler.DataCase

  alias Butler.Schedules

  describe "todos" do
    alias Butler.Schedules.Todo

    @valid_attrs %{duration: 42, name: "some name", priority: "some priority", start: "2010-04-17T14:00:00Z"}
    @update_attrs %{duration: 43, name: "some updated name", priority: "some updated priority", start: "2011-05-18T15:01:01Z"}
    @invalid_attrs %{duration: nil, name: nil, priority: nil, start: nil}

    def todo_fixture(attrs \\ %{}) do
      {:ok, todo} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Schedules.create_todo()

      todo
    end

    test "list_todos/0 returns all todos" do
      todo = todo_fixture()
      assert Schedules.list_todos() == [todo]
    end

    test "get_todo!/1 returns the todo with given id" do
      todo = todo_fixture()
      assert Schedules.get_todo!(todo.id) == todo
    end

    test "create_todo/1 with valid data creates a todo" do
      assert {:ok, %Todo{} = todo} = Schedules.create_todo(@valid_attrs)
      assert todo.duration == 42
      assert todo.name == "some name"
      assert todo.priority == "some priority"
      assert todo.start == DateTime.from_naive!(~N[2010-04-17T14:00:00Z], "Etc/UTC")
    end

    test "create_todo/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Schedules.create_todo(@invalid_attrs)
    end

    test "update_todo/2 with valid data updates the todo" do
      todo = todo_fixture()
      assert {:ok, %Todo{} = todo} = Schedules.update_todo(todo, @update_attrs)
      assert todo.duration == 43
      assert todo.name == "some updated name"
      assert todo.priority == "some updated priority"
      assert todo.start == DateTime.from_naive!(~N[2011-05-18T15:01:01Z], "Etc/UTC")
    end

    test "update_todo/2 with invalid data returns error changeset" do
      todo = todo_fixture()
      assert {:error, %Ecto.Changeset{}} = Schedules.update_todo(todo, @invalid_attrs)
      assert todo == Schedules.get_todo!(todo.id)
    end

    test "delete_todo/1 deletes the todo" do
      todo = todo_fixture()
      assert {:ok, %Todo{}} = Schedules.delete_todo(todo)
      assert_raise Ecto.NoResultsError, fn -> Schedules.get_todo!(todo.id) end
    end

    test "change_todo/1 returns a todo changeset" do
      todo = todo_fixture()
      assert %Ecto.Changeset{} = Schedules.change_todo(todo)
    end
  end
end

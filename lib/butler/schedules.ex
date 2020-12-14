defmodule Butler.Schedules do
  @moduledoc """
  The Schedules context.
  """

  import Ecto.Query, warn: false
  alias Butler.Repo

  alias Butler.Schedules.Todo

  def subscribe(topic) do
    Phoenix.PubSub.subscribe(Butler.PubSub, topic)
  end

  defp broadcast({:ok, todo}, event) do
    # Broadcast changes only to the users that can see it.
    todo_topic = IO.iodata_to_binary(["todos:", todo.user_id])
    Phoenix.PubSub.broadcast(Butler.PubSub, todo_topic, {event, todo})

    {:ok, todo}
  end

  defp broadcast({:error, _changeset} = error, _event), do: error

  @doc """
  Returns the list of todos.

  ## Examples

      iex> list_todos()
      [%Todo{}, ...]

  """
  def list_todos do
    Repo.all(Todo)
  end

  @doc """
  Gets a single todo.

  Raises `Ecto.NoResultsError` if the Todo does not exist.

  ## Examples

      iex> get_todo!(123)
      %Todo{}

      iex> get_todo!(456)
      ** (Ecto.NoResultsError)

  """
  def get_todo!(id), do: Repo.get!(Todo, id)

  @doc """
  Creates a todo.

  ## Examples

      iex> create_todo(%{field: value})
      {:ok, %Todo{}}

      iex> create_todo(%{field: value}, [:user])
      {:ok, %Todo{user: %User{}}}

      iex> create_todo(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_todo(attrs \\ %{}, preload_opts \\ []) do
    maybe_todo =
      %Todo{}
      |> Todo.changeset(attrs)
      |> Repo.insert()

    case maybe_todo do
      {:ok, todo} ->
        broadcast({:ok, Repo.preload(todo, preload_opts)}, :created_todo)

      error_changeset_pair ->
        broadcast(error_changeset_pair, :created_todo)
    end
  end

  @doc """
  Updates a todo.

  ## Examples

      iex> update_todo(todo, %{field: new_value})
      {:ok, %Todo{}}

      iex> update_todo(todo, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_todo(%Todo{} = todo, attrs) do
    todo
    |> Todo.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a todo.

  ## Examples

      iex> delete_todo(todo)
      {:ok, %Todo{}}

      iex> delete_todo(todo)
      {:error, %Ecto.Changeset{}}

  """
  def delete_todo(%Todo{} = todo) do
    Repo.delete(todo)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking todo changes.

  ## Examples

      iex> change_todo(todo)
      %Ecto.Changeset{data: %Todo{}}

  """
  def change_todo(%Todo{} = todo, attrs \\ %{}) do
    Todo.changeset(todo, attrs)
  end
end

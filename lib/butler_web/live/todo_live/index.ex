defmodule ButlerWeb.TodoLive.Index do
  use ButlerWeb, :live_view

  alias Butler.Schedules
  alias Butler.Schedules.Todo
  alias ButlerWeb.DayComponent
  alias Butler.Accounts.User

  @impl true
  def mount(_params, session, socket) do
    socket = assign_defaults(socket, session)

    if connected?(socket) do
      # Users can only be updated on changes of their own todos.
      topic = IO.iodata_to_binary(["todos:", socket.assigns.current_user.id])
      Schedules.subscribe(topic)
    end

    case socket.assigns.current_user do
      nil ->
        {:ok,
          socket
          |> put_flash(:error, "You have to be logged to access that.")
          |> push_redirect(to: Routes.user_session_path(socket, :new))
        }

      %User{id: user_id} -> {:ok, assign(socket, :todos, list_todos(user_id)), temporary_assigns: []}
    end
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Todo")
    |> assign(:todo, Schedules.get_todo!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Todo")
    |> assign(:todo, %Todo{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Todos")
    |> assign(:todo, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    todo = Schedules.get_todo!(id)
    {:ok, _} = Schedules.delete_todo(todo)

    {:noreply, assign(socket, :todos, list_todos(socket.assigns.current_user.id))}
  end

  @impl true
  def handle_event("new_todo", _params, socket) do
    {:noreply, push_patch(socket, to: Routes.todo_index_path(socket, :new))}
  end

  @impl true
  def handle_info({:created_todo, todo}, socket) do
    socket = update(socket, :todos, fn todos -> [todo | todos] end)

    {:noreply, socket}
  end

  defp list_todos(user_id) do
    Schedules.list_todos(user_id)
  end

  def list_week do
    Enum.reduce(0..6, [], fn offset, week ->
      day =
        Timex.today()
        |> Timex.beginning_of_week(:sun)
        |> Timex.shift(days: offset)

      [day | week]
    end)
    |> Enum.reverse()
  end

  defp group_todos_by_day(todos) when is_list(todos) do
    Enum.group_by(todos, fn todo ->
      Timex.to_date(todo.start)
    end)
  end

  defp get_priority(priority) do
    priority
    |> Atom.to_string()
    |> String.capitalize()
  end
end

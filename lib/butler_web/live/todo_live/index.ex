defmodule ButlerWeb.TodoLive.Index do
  use ButlerWeb, :live_view

  alias Butler.Schedules
  alias Butler.Schedules.Todo
  alias ButlerWeb.DayComponent

  @impl true
  def mount(_params, session, socket) do
    socket = assign_defaults(socket, session)

    case socket.assigns.current_user do
      nil ->
        {:ok,
          socket
          |> put_flash(:error, "You have to be logged to access that.")
          |> push_redirect(to: Routes.user_session_path(socket, :new))
        }

      _ -> {:ok, assign(socket, :todos, list_todos())}
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

    {:noreply, assign(socket, :todos, list_todos())}
  end

  @impl true
  def handle_event("new_todo", _params, socket) do
    {:noreply, push_patch(socket, to: Routes.todo_index_path(socket, :new))}
  end

  @impl true
  def handle_info({:added_todo, todo}, socket) do
    socket = update(socket, :todos, fn ts -> [todo | ts] end)

    {:noreply, socket}
  end

  defp list_todos do
    Schedules.list_todos()
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

  defp get_priority(num) do
    case num do
      1 -> "None"
      2 -> "Low"
      3 -> "Medium"
      4 -> "High"
    end
  end
end

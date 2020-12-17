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

      %User{id: user_id} ->
        socket =
          socket
          |> assign(:todos, list_todos(user_id))
          |> assign(:mode, :visual)

        {:ok, socket, temporary_assigns: []}
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

    todos = run_scheduler(socket.assigns.current_user.id)

    {:noreply, assign(socket, :todos, todos)}
  end

  @impl true
  def handle_event("new_todo", _params, socket) do
    {:noreply, push_patch(socket, to: Routes.todo_index_path(socket, :new))}
  end

  @impl true
  def handle_event("run_scheduler", _params, socket) do
    todos = run_scheduler(socket.assigns.current_user.id)

    {:noreply,
      socket
      |> assign(:todos, todos)
      |> put_flash(:info, "I've rescheduled your calendar! 🤵")}
  end

  @impl true
  def handle_event("to_select_mode", _params, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event("update_time_slots", params, socket) do
    IO.inspect params

    {:noreply, push_event(socket, "refresh_local_slots", params)}
  end

  @impl true
  def handle_info({:created_todo, todo}, socket) do
    socket = update(socket, :todos, fn todos -> [todo | todos] end)

    {:noreply, socket}
  end

  @impl true
  def handle_info(:run_scheduler, socket) do
    todos = run_scheduler(socket.assigns.current_user.id)

    {:noreply, assign(socket, :todos, todos)}
  end

  defp run_scheduler(user_id) do
    user_id
    |> Schedules.list_todos()
    |> Schedules.auto_assign()

    Schedules.list_todos(user_id)
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

  defp group_available_by_day(avail_slots) when is_list(avail_slots) do
    Enum.group_by(avail_slots, fn {start, _} ->
      Timex.to_date(start)
    end)
  end

  defp get_priority(priority) do
    priority
    |> Atom.to_string()
    |> String.capitalize()
  end

  # TODO: Remove when user-defined available slots are implemented.
  defp sample_streaks do
    [{~N[2020-12-15 09:00:00.00], ~N[2020-12-15 12:00:00.00]},
      {~N[2020-12-15 13:00:00.00], ~N[2020-12-15 20:00:00.00]},
      {~N[2020-12-16 09:00:00.00], ~N[2020-12-16 12:00:00.00]},
      {~N[2020-12-16 13:00:00.00], ~N[2020-12-16 20:00:00.00]},
      {~N[2020-12-17 09:00:00.00], ~N[2020-12-17 12:00:00.00]},
      {~N[2020-12-17 13:00:00.00], ~N[2020-12-17 15:00:00.00]},
      {~N[2020-12-18 09:00:00.00], ~N[2020-12-18 12:00:00.00]},
      {~N[2020-12-18 13:00:00.00], ~N[2020-12-18 20:00:00.00]},
      {~N[2020-12-19 09:00:00.00], ~N[2020-12-19 12:00:00.00]},
      {~N[2020-12-19 13:00:00.00], ~N[2020-12-19 20:00:00.00]}]
  end
end

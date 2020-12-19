defmodule ButlerWeb.TodoLive.Index do
  use ButlerWeb, :live_view

  alias Butler.DaySchedules
  alias Butler.Schedules
  alias Butler.Schedules.Todo
  alias ButlerWeb.DayComponent
  alias Butler.Accounts.User

  @impl true
  def mount(_params, session, socket) do
    socket = assign_defaults(socket, session)

    if connected?(socket) do
      # Users can only be updated on changes of their own todos.
      Enum.reduce(["todos:", "available_slots:"], [], fn topic_prefix, _ ->
        topic = IO.iodata_to_binary([topic_prefix, socket.assigns.current_user.id])
        Schedules.subscribe(topic)
      end)
    end

    case socket.assigns.current_user do
      nil ->
        {:ok,
          socket
          |> put_flash(:error, "You have to be logged to access that.")
          |> push_redirect(to: Routes.user_session_path(socket, :new))
        }

      %User{id: user_id} ->
        avail_dates = list_available_dates(user_id)

        socket =
          socket
          |> assign(:todos, list_todos(user_id))
          |> assign(:dates, avail_dates)
          |> assign(:mode, :visual)

        {:ok, socket, temporary_assigns: [avail_dates: []]}
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
    |> assign(:page_title, "Calendar")
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
    case socket.assigns.mode do
      :visual ->
        {:noreply, push_patch(socket, to: Routes.todo_index_path(socket, :new))}

      :select ->
        msg = "You can't do this unless you exit visual mode."
        {:noreply, put_flash(socket, :error, msg)}
    end
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
  def handle_event("toggle_mode", _params, socket) do
    {:noreply,
      update(socket, :mode, fn mode ->
        case mode do
          :select -> :visual
          :visual -> :select
        end
      end)}
  end

  @impl true
  def handle_event("update_time_slots", %{"selected_slots" => slots} = params, socket) do
    # TODO: Implement PubSub to update all instances of Butler for any changes.
    current_user = socket.assigns.current_user

    dates =
      slots
      |> Map.keys()
      |> Enum.map(fn date ->
        # The reason the timestamps are manually specified is because Multi
        # is pretty low-level, and does not seem to set those automatically.
        # Without this, this will complain about a null constraint violation.
        time = NaiveDateTime.truncate(NaiveDateTime.utc_now(), :second)
        date_slots =
          slots
          |> Map.get(date, [])
          |> Enum.reduce(MapSet.new(), fn slot, acc ->
            index = String.to_integer(slot)

            MapSet.put(acc, index)
          end)
          |> MapSet.to_list()
          |> Enum.sort()

        date =
          IO.iodata_to_binary([date, "T00:00:00-00:00"])
          |> Timex.parse!("{ISO:Extended}")

        %{
          date: date,
          user_id: current_user.id,
          inserted_at: time,
          updated_at: time,
          selected_slots: date_slots
        }
      end)

    socket =
      case Butler.DaySchedules.create_days_with_slots(dates) do
        {:ok, _} ->
          put_flash(socket, :info, "I've updated your available time slots. 🤵")

        _ ->
          put_flash(socket, :error, "An error happened while saving your changes.")
      end

    todos = run_scheduler(socket.assigns.current_user.id)

    # Have to provide some visual feedback that the changes were saved.
    {:noreply,
      socket
      |> assign(:todos, todos)
      |> assign(:dates, dates)
      |> push_event("refresh_local_slots", params)}
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

  def run_scheduler(user_id) do
    streaks =
      user_id
      |> list_available_dates()
      |> Enum.reduce([], fn day, acc ->
        streaks = get_streaks_from_slot_ids(day.date, day.selected_slots)
        acc ++ streaks
      end)

    todos = Schedules.list_todos(user_id)

    # TODO: Refactor
    # This one is really bad. I have to find a way to condense it to fewer db ops.
    cond do
      todos != [] and streaks != [] ->
        # Remove the old schedule of todos that were scheduled to a time slot.
        todos
        |> Enum.filter(fn t -> t.start != nil end)
        |> Enum.map(fn todo ->
          {todo, %{start: nil}}
        end)
        |> Schedules.multi_update()

        user_id
        |> Schedules.list_todos()
        |> Schedules.auto_assign(streaks)

      todos != [] and streaks == [] ->
        # Remove the old schedule of todos that were scheduled to a time slot.
        todos
        |> Enum.filter(fn t -> t.start != nil end)
        |> Enum.map(fn todo ->
          {todo, %{start: nil}}
        end)
        |> Schedules.multi_update()

      true -> todos
    end

    Schedules.list_todos(user_id)
  end

  defp get_streaks_from_slot_ids(date, slot_ids) do
    ndt = DateTime.to_naive(date)
    midnight = Time.new!(0, 0, 0, 0)

    case slot_ids do
      [] -> []

      [first_id | _] ->
        # TODO: Refactor
        Enum.reduce(slot_ids, {first_id, []}, fn
          id, {_prev_id, []} ->
            offset = trunc((id * 0.5) * 1800)
            from_ndt =
              midnight
              |> Time.add(offset, :second)
              |> update_datetime_with_time(ndt)

            to_ndt = NaiveDateTime.add(from_ndt, 1800, :second)
            {id, [%{from: from_ndt, to: to_ndt}]}

          id, {prev_id, streaks} ->
            offset = trunc((id * 0.5) * 3600)
            from_ndt =
              midnight
              |> Time.add(offset, :second)
              |> update_datetime_with_time(ndt)

            to_ndt = NaiveDateTime.add(from_ndt, 1800, :second)

            streaks =
              cond do
                id - prev_id == 1 ->
                  prev_streak = hd(streaks)
                  remaining_streaks = tl(streaks)

                  [%{prev_streak | to: to_ndt} | remaining_streaks]

                id - prev_id > 1 ->
                  [%{from: from_ndt, to: to_ndt} | streaks]
              end

            {id, streaks}
        end)
        |> fn {_, streaks} ->
          Enum.map(streaks, fn %{from: from, to: to} ->
            {from, to}
          end)
        end.()
    end
  end

  defp list_todos(user_id) do
    Schedules.list_todos(user_id)
  end

  defp update_datetime_with_time(time, datetime) do
    %{hour: hour, minute: minute} = time
    %{datetime | hour: hour, minute: minute}
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
    Enum.group_by(todos, fn
      %{start: nil} ->
        nil
      %{start: start} ->
        DateTime.to_date(start)
    end)
  end

  defp get_priority(priority) do
    priority
    |> Atom.to_string()
    |> String.capitalize()
  end

  defp list_available_dates(user_id) do
    from = Timex.beginning_of_week(DateTime.utc_now(), :sun)
    to = Timex.shift(from, days: 6)

    DaySchedules.list_days(user_id, from, to)
  end

  defp get_slots_from_date(dates, date) when is_list(dates) do
    dates
    |> Enum.find(fn d ->
      d_date = DateTime.to_date(d.date)
      Date.compare(d_date, date) == :eq
    end)
    |> case do
      nil ->
        []

      date ->
        Map.get(date, :selected_slots, [])
    end
  end
end

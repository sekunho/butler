defmodule ButlerWeb.DayComponent do
  use ButlerWeb, :live_component

  def render(assigns) do
    ~L"""
    <div>
        <div class="day-header">
            <h5 class="day-header__name"><%= get_day_name(@day) %></h5>
            <span class="day-header__number <%= if is_today?(@day), do: "day-header__number--active", else: "" %>">
                <%= get_day_num(@day) %>
            </span>
        </div>
        <ul class="mt-4 relative">
            <%= if is_disabled?(@day) do %>
            <li class="absolute w-full bg-gray-400 opacity-20 z-10 cursor-not-allowed select-none text-white"
                style="height: calc(3.25rem * 24);">
            </li>
            <% end %>

            <%= if is_today?(@day) do %>
                <li class="w-full h-0.5 bg-red-600 absolute z-10" style="margin-top: calc(3.25rem * 14);"></li>
            <% end %>
            <%= for todo <- @todos do %>
            <li class="border border-indigo-700 absolute w-full bg-indigo-500 px-1 rounded cursor-pointer select-none hover:bg-indigo-700 text-white"
                style="height: calc(3.25rem * <%= todo.duration / 60 %>); margin-top: calc(3.25rem * <%= get_time_offset(todo.start) %>);">
                <p class="text-xs font-medium truncate">
                    <span><%= todo.name %></span>
                    <span class="ml-1.5"><%= DateTime.to_time(todo.start) %></span>
                </p>
            </li>
            <% end %>
        </ul>
    </div>
    """
  end

  defp get_time_offset(datetime) do
    time = DateTime.to_time(datetime)
    Timex.diff(time, ~T[00:00:00], :second) / 3600
  end

  defp get_day_name(date), do: Date.day_of_week(date) |> Timex.day_shortname()

  defp get_day_num(%Date{day: day}), do: day

  defp is_today?(%Date{} = date), do: date == Timex.today()

  defp is_disabled?(%Date{} = date), do: Timex.before?(date, Timex.today())
end

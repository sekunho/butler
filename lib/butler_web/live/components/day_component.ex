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
                <li class="bg-gray-400 opacity-10 cursor-not-allowed select-none text-white"
                    style="height: calc(3.25rem * 24);">
                </li>
            <% else %>
                <%= for todo <- @todos do %>
                    <li class="absolute w-full bg-indigo-500 px-1 rounded cursor-pointer select-none hover:shadow-lg text-white"
                        style="height: calc(3.25rem * <%= todo.duration %>); margin-top: calc(3.25rem * <%= todo.start %>);">
                        <p class="text-xs font-medium truncate">
                            <span>
                                Continue with final project
                            </span>
                            <span class="ml-1.5">
                                0:00
                            </span>
                        </p>
                    </li>
                <% end %>
            <% end %>
        </ul>
    </div>
    """
  end

  defp get_day_name(date), do: Date.day_of_week(date) |> Timex.day_shortname()

  defp get_day_num(%Date{day: day}), do: day

  defp is_today?(%Date{} = date), do: date == Timex.today()

  defp is_disabled?(%Date{} = date), do: Timex.before?(date, Timex.today())
end

defmodule ButlerWeb.DayComponent do
  use ButlerWeb, :live_component

  def render(assigns) do
    ~L"""
    <div>
        <div class="day-header">
            <h5 class="day-header__name"><%= get_day_name(@date) %></h5>
            <span class="day-header__number <%= if is_today?(@date), do: "day-header__number--active", else: "" %>">
                <%= get_day_num(@date) %>
            </span>
        </div>
        <ul class="events relative mt-8">
            <%= if is_disabled?(@date) do %><!--
                <li class="absolute w-full bg-red-300 opacity-20 z-10 cursor-not-allowed select-none text-white"
                    style="height: calc(3.25rem * 24);">
                </li> -->
            <% end %>

            <%= if is_today?(@date) do %>
                <li class="w-full h-0.5 bg-red-600 absolute z-10" style="margin-top: calc(3.25rem * <%= get_time_offset(Timex.now()) %>);"></li>
            <% end %>

            <%= if @mode == :visual do %>
                <%= for todo <- @todos do %>
                    <li class="border border-indigo-600 absolute w-full bg-indigo-500 px-1 rounded cursor-pointer select-none hover:bg-indigo-600 text-white"
                        style="height: calc(3.25rem * <%= todo.duration / 60 %>); margin-top: calc(3.25rem * <%= get_time_offset(todo.start) %>);">
                        <p class="text-xs font-medium truncate">
                            <span><%= todo.name %></span>
                            <span class="ml-1.5">(<%= DateTime.to_time(todo.start) %>)</span>
                        </p>
                    </li>
                <% end %>
            <% else %>
                <%= for offset <- 0..47 do %>
                    <li class="events__time-slot <%= get_slot_class(@slots, offset) %>"
                      draggable="false"
                      phx-value-id="<%= offset %>"
                      phx-value-day="<%= @date %>"
                        style="margin-top: calc(3.25rem * <%= 0.5 * offset %>); height: calc(3.25rem * 0.5);">
                    </li>
                <% end %>
            <% end %>
        </ul>
    </div>
    """
  end

  defp get_time_offset(%DateTime{} = datetime) do
    time = DateTime.to_time(datetime)

    # TODO: Fix issue with types. Not sure what exactly. I don't get dialyzer.
    Timex.diff(time, ~T[00:00:00], :second) / 3600
  end

  defp get_time_offset(%NaiveDateTime{} = datetime) do
    time = NaiveDateTime.to_time(datetime)

    # TODO: Fix issue with types. Not sure what exactly. I don't get dialyzer.
    Timex.diff(time, ~T[00:00:00], :second) / 3600
  end

  defp get_day_name(date), do: Date.day_of_week(date) |> Timex.day_shortname()

  defp get_day_num(%{day: day}), do: day

  defp is_today?(date), do: date == DateTime.to_date(DateTime.utc_now())

  defp is_disabled?(date), do: Timex.before?(date, DateTime.utc_now())

  defp get_slot_class(slots, index) when is_list(slots) and is_integer(index) do
    case Enum.member?(slots, index) do
      true -> "events__time-slot--active"

      false -> ""
    end
  end
end

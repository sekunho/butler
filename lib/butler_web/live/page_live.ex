defmodule ButlerWeb.PageLive do
  use ButlerWeb, :live_view

  @impl true
  def mount(_params, session, socket) do
    socket = assign_defaults(socket, session)

    case socket.assigns.current_user do
      nil -> {:ok, socket}

      _ ->
        {:ok,
          push_redirect(socket, to: Routes.todo_index_path(socket, :index))}
    end
  end
end

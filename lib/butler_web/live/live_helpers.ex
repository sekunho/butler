defmodule ButlerWeb.LiveHelpers do
  import Phoenix.LiveView.Helpers
  import Phoenix.LiveView

  @doc """
  Renders a component inside the `ButlerWeb.ModalComponent` component.

  The rendered modal receives a `:return_to` option to properly update
  the URL when the modal is closed.

  ## Examples

      <%= live_modal @socket, ButlerWeb.TodoLive.FormComponent,
        id: @todo.id || :new,
        action: @live_action,
        todo: @todo,
        return_to: Routes.todo_index_path(@socket, :index) %>
  """
  def live_modal(socket, component, opts) do
    path = Keyword.fetch!(opts, :return_to)
    modal_opts = [id: :modal, return_to: path, component: component, opts: opts]
    live_component(socket, ButlerWeb.ModalComponent, modal_opts)
  end

  alias Butler.Accounts

  def assign_defaults(socket, %{"user_token" => user_token}) do
    socket = assign_new(socket, :current_user, fn -> Accounts.get_user_by_session_token(user_token) end)

    if socket.assigns.current_user do
      socket
    else
      redirect(socket, to: "/login")
    end
  end

  def assign_defaults(socket, _) do
    assign_new(socket, :current_user, fn -> nil end)
  end
end

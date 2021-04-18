defmodule SimpleVoteWeb.ModalComponent do
  use SimpleVoteWeb, :live_component

  @impl true
  def render(assigns) do
    ~L"""

    <div id="<%= @id %>" class="phx-modal"
      phx-capture-click="close"
      phx-window-keydown="close"
      phx-key="escape"
      phx-target="#<%= @id %>"
      phx-page-loading>
      <div class="phx-modal-content shadow-xl rounded-lg bg-white px-4 pt-5 pb-4 text-left overflow-hidden transform transition-all sm:my-72 sm:max-w-sm sm:w-full sm:p-6 ">
        <%= live_patch raw("&times;"), to: @return_to, class: "phx-modal-close" %>
        <%= live_component @socket, @component, @opts %>
      </div>
    </div>


    """
  end

  @impl true
  def handle_event("close", _, socket) do
    {:noreply, push_patch(socket, to: socket.assigns.return_to)}
  end
end

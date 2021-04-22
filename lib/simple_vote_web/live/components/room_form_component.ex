defmodule SimpleVoteWeb.RoomLive.RoomFormComponent do
  use SimpleVoteWeb, :live_component

  alias SimpleVote.Rooms

  @impl true
  def render(assigns) do
    ~L"""
    <h2 class="text-lg leading-6 font-medium text-gray-900">
      <%= @title %>
    </h2>
    <%= f = form_for @changeset, "#",
      id: "room-form",
      phx_target: @myself,
      phx_change: "validate",
      phx_submit: "save",
      class: "mt-5 sm:flex sm:items-center"
    %>
      <%= label f, :name, class: "sr-only"  %>
      <%= text_input f, :name, placeholder: "Name", class: "shadow-sm focus:ring-indigo-500 focus:border-indigo-500 block w-full sm:text-sm border-gray-300 rounded-md"  %>      </div>
      <%= error_tag f, :name %>

      <%= submit "Save", phx_disable_with: "Saving...", class: "mt-3 w-full inline-flex items-center justify-center px-4 py-2 border border-transparent shadow-sm font-medium rounded-md text-white bg-indigo-600 hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500 sm:mt-0 sm:ml-3 sm:w-auto sm:text-sm" %>
    </form>
    """
  end

  @impl true
  def update(%{room: room} = assigns, socket) do
    changeset = Rooms.change_room(room)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"room" => room_params}, socket) do
    changeset =
      socket.assigns.room
      |> Rooms.change_room(room_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"room" => room_params}, socket) do
    save_room(socket, socket.assigns.action, room_params)
  end

  defp save_room(socket, :edit, room_params) do
    case Rooms.update_room(socket.assigns.room, room_params) do
      {:ok, _room} ->
        {:noreply,
         socket
         |> put_flash(:info, "Room updated successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_room(socket, :new, room_params) do
    case Rooms.create_room(room_params) do
      {:ok, room} ->
        {:noreply,
         socket
         |> put_flash(:info, "Room created successfully")
         |> push_redirect(
           to:
             Routes.room_show_path(
               socket,
               :show,
               room
             )
         )}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end

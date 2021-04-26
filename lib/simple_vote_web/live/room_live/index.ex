defmodule SimpleVoteWeb.RoomLive.Index do
  use SimpleVoteWeb, :live_view

  alias SimpleVote.Accounts.User
  alias SimpleVote.Rooms
  alias SimpleVote.Rooms.Room

  @impl true
  def mount(_params, session, socket) do
    socket = assign_user(session, socket)

    with {:ok, %User{} = user} <- get_current_user(socket),
         rooms <- Rooms.list_user_rooms(user.id) do
      {:ok, assign(socket, :rooms, rooms)}
    else
      _ -> {:ok, assign(socket, :rooms, [])}
    end
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"slug" => slug}) do
    id = Rooms.RoomRegistry.get_room_id(slug)

    socket
    |> assign(:page_title, "Edit Room")
    |> assign(:room, Rooms.get_room!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Room")
    |> assign(:room, %Room{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Rooms")
    |> assign(:room, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    room = Rooms.get_room!(id)
    {:ok, _} = Rooms.delete_room(room)

    {:noreply, assign(socket, :rooms, list_rooms())}
  end

  defp list_rooms do
    Rooms.list_rooms()
  end
end

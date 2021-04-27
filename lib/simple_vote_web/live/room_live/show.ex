defmodule SimpleVoteWeb.RoomLive.Show do
  use SimpleVoteWeb, :live_view

  alias SimpleVote.Rooms
  alias SimpleVote.Rooms.RoomRegistry
  alias SimpleVote.Polls
  alias SimpleVote.Polls.{Prompt, Option}
  alias SimpleVote.Accounts.{User}

  @impl true
  def mount(%{"slug" => slug}, session, socket) do
    socket = assign_user(session, socket)

    with {:ok, room_id} <- RoomRegistry.get_room_id(slug),
         {:ok, %User{id: user_id}} <- get_current_user(socket),
         room = %Rooms.Room{owner_id: ^user_id} <- Rooms.get_room!(room_id) do
      {:ok, assign(socket, :room, room)}
    else
      {:error, :no_room_with_slug} ->
        socket =
          socket
          |> put_flash(:error, "Couldn't find that room.")
          |> redirect(to: "/rooms")

        {:ok, socket}

      {:error, :not_authenticated} ->
        {:ok, redirect(socket, to: "/rooms/#{slug}/vote")}

      _err ->
        {:ok, redirect(socket, to: "/rooms")}
    end
  end

  @impl true
  def handle_params(%{"prompt_id" => prompt_id, "option_id" => option_id}, _url, socket) do
    with prompt = %Prompt{} <- Polls.get_prompt!(prompt_id),
         option = %Option{} <- Polls.get_option!(option_id) do
      socket =
        socket
        |> assign(:page_title, page_title(socket.assigns.live_action))
        |> assign(:prompt, prompt)
        |> assign(:option, option)

      {:noreply, socket}
    else
      _ -> {:noreply, redirect(socket, to: "/rooms")}
    end
  end

  @impl true
  def handle_params(%{"prompt_id" => prompt_id}, _url, socket) do
    with prompt = %Prompt{} <- Polls.get_prompt!(prompt_id) do
      socket =
        socket
        |> assign(:page_title, page_title(socket.assigns.live_action))
        |> assign(:prompt, prompt)

      {:noreply, socket}
    else
      _ -> {:noreply, redirect(socket, to: "/rooms")}
    end
  end

  @impl true
  def handle_params(_params, _url, socket) do
    room = socket.assigns.room

    socket =
      socket
      |> assign(:page_title, page_title(socket.assigns.live_action))
      |> assign_new(:prompts, fn -> room.prompts end)
      |> assign_new(:prompt, fn -> %Prompt{} end)
      |> assign_new(:option, fn -> %Option{} end)

    {:noreply, socket}
  end

  defp page_title(:show), do: "Show Room"
  defp page_title(:edit), do: "Edit Room"
  defp page_title(:new_prompt), do: "New Prompt"
  defp page_title(:edit_prompt), do: "Edit Prompt"
  defp page_title(:new_option), do: "New Option"
  defp page_title(:edit_option), do: "Edit Option"

  @impl true
  def handle_event("delete_option", %{"room-id" => room_id, "option-id" => option_id}, socket) do
    option = Polls.get_option!(option_id)
    Polls.delete_option(option)

    {:noreply, assign(socket, prompts: Polls.list_room_prompts(room_id))}
  end

  @impl true
  def handle_event("delete_prompt", %{"room-id" => room_id, "prompt-id" => prompt_id}, socket) do
    prompt = Polls.get_prompt!(prompt_id)
    {:ok, _} = Polls.delete_prompt(prompt)

    {:noreply, assign(socket, :prompts, Polls.list_room_prompts(room_id))}
  end
end

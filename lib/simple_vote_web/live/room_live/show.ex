defmodule SimpleVoteWeb.RoomLive.Show do
  use SimpleVoteWeb, :live_view

  alias SimpleVote.Rooms
  alias SimpleVote.Rooms.RoomRegistry
  alias SimpleVote.Polls
  alias SimpleVote.Polls.{Prompt, Option}

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(
        %{"slug" => slug, "prompt_id" => prompt_id, "option_id" => option_id},
        _url,
        socket
      ) do
    room = slug |> RoomRegistry.get_room_id() |> Rooms.get_room!()
    prompts = Polls.list_room_prompts(room.id)
    prompt = Polls.get_prompt!(prompt_id)
    option = Polls.get_option!(option_id)
    options = Polls.list_prompt_options(prompt_id)

    socket =
      socket
      |> assign(:page_title, page_title(socket.assigns.live_action))
      |> assign(:room, room)
      |> assign(:prompt, prompt)
      |> assign(:prompts, prompts)
      |> assign(:option, option)
      |> assign(:options, options)

    {:noreply, socket}
  end

  @impl true
  def handle_params(%{"slug" => slug, "prompt_id" => prompt_id}, _url, socket) do
    room = slug |> RoomRegistry.get_room_id() |> Rooms.get_room!()
    prompts = Polls.list_room_prompts(room.id)
    prompt = Polls.get_prompt!(prompt_id)
    option = %Option{}
    options = Polls.list_prompt_options(prompt_id)

    socket =
      socket
      |> assign(:page_title, page_title(socket.assigns.live_action))
      |> assign(:room, room)
      |> assign(:prompt, prompt)
      |> assign(:prompts, prompts)
      |> assign(:option, option)
      |> assign(:options, options)

    {:noreply, socket}
  end

  @impl true
  def handle_params(%{"slug" => slug}, _, socket) do
    case RoomRegistry.get_room_id(slug) do
      {:error, _} ->
        socket

      id ->
        socket =
          socket
          |> assign(:page_title, page_title(socket.assigns.live_action))
          |> assign(:room, Rooms.get_room!(id))
          |> assign(:prompt, %Prompt{})
          |> assign(:prompts, Polls.list_room_prompts(id))
          |> assign(:option, %Option{})

        {:noreply, socket}
    end
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

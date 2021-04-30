defmodule SimpleVoteWeb.RoomLive.Vote.NameForm do
  use SimpleVoteWeb, :surface_component

  alias Surface.Components.Form
  alias Surface.Components.Form.{Field, Label, TextInput}

  data name, :string, default: ""

  def render(assigns) do
    """
      <Form for={{ @socket }} change="change" opts={{ autocomplete: "off" }}>
      <Field name="name">
      <Label/>
        <div class="control">
          <TextInput value={{ @name }}/>
        </div>
      </Field>

    </Form>
    """

    ~H"""
    Register now!

    """
  end
end

defmodule SimpleVoteWeb.RoomLive.Lobby do
  use SimpleVoteWeb, :surface_view

  import Logger

  alias SimpleVote.Rooms
  alias SimpleVote.Rooms.RoomRegistry
  alias SimpleVote.Accounts.User
  alias SimpleVoteWeb.Presence

  defp get_username(socket) do
    case Map.get(socket.assigns, "username") do
      nil -> {:error, :no_username}
      username -> {:ok, username}
    end
  end

  @impl true
  @spec mount(map, any, Phoenix.LiveView.Socket.t()) :: {:ok, Phoenix.LiveView.Socket.t()}
  def mount(%{"slug" => slug}, _session, socket) do
    with {:ok, room_id} <- RoomRegistry.get_room_id(slug),
         room = %Rooms.Room{} <- Rooms.get_room!(room_id),
         {:ok, present} = join_room(socket, slug) do
      socket =
        socket
        |> assign(:present, present)
        |> assign(:room, room)

      {:ok, socket}
    else
      {:error, :no_room_with_slug} ->
        socket =
          socket
          |> put_flash(:error, "Couldn't find that room.")
          |> redirect(to: "/rooms")

        {:ok, socket}

      _err ->
        {:ok, redirect(socket, to: "/rooms")}
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    Vote: {{@room.name}}
    Present: {{@present}}
        Register now!
      <div :for={{ prompt <- @room.prompts }}>
        <SimpleVoteWeb.RoomLive.Vote.Prompt body={{prompt.body}} options={{prompt.options}} />
      </div>
    """
  end

  defp join_room(socket, slug) do
    topic = "lobby:#{slug}"

    # before subscribing, let's get the current_reader_count
    initial_count =
      topic
      |> Presence.list()
      |> map_size

    # Subscribe to the topic
    SimpleVoteWeb.Endpoint.subscribe(topic)

    # Track changes to the topic
    Presence.track(self(), topic, socket.id, %{})

    {:ok, initial_count}
  end

  @impl true
  def handle_info(
        %{event: "presence_diff", payload: %{joins: joins, leaves: leaves}},
        %{assigns: %{present: count}} = socket
      ) do
    present = count + map_size(joins) - map_size(leaves)

    {:noreply, assign(socket, :present, present)}
  end
end

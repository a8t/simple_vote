defmodule SimpleVoteWeb.RoomLive.Lobby.NameForm do
  use SimpleVoteWeb, :surface_component

  alias Surface.Components.Form
  alias Surface.Components.Form.{Field, Label, TextInput, HiddenInput, ErrorTag}
  alias SimpleVote.Rooms.NicknameRegistry

  prop return, :string
  prop room_slug, :string
  data nickname, :string, default: ""
  data trigger_submit, :boolean, default: false
  data errors, :list, default: []

  def render(assigns) do
    ~H"""
    <Form
      for={{ :nickname_form }}
      submit="save"
      change="change"
      action={{Routes.nickname_path(@socket, :create)}}
      opts={{
        id: "lobby-form",
        autocomplete: "off",
        phx_trigger_action: @trigger_submit
      }}
      as={{:nickname_form}}
      errors={{@errors}}
    >
      <Field name="return_to">
        <HiddenInput value={{@return}} name="return_to" field="return_to"  form="nickname_form"/>
      </Field>
      <Field name="room_slug">
        <HiddenInput value={{@room_slug}} name="room_slug" field="room_slug"  form="nickname_form"/>
      </Field>
      <Field name="nickname">
        <Label/>
        <TextInput form="nickname_form" value={{@nickname}}/>
        <ErrorTag field="nickname"/>
      </Field>
    </Form>
    """
  end

  def handle_event(
        "save",
        %{"nickname_form" => %{"nickname" => nickname}, "room_slug" => room_slug},
        socket
      ) do
    # check if there is anyone else with that name already

    if socket.assigns.trigger_submit do
      send(self(), {:changed_nickname, nickname})
    else
      case NicknameRegistry.register(room_slug, nickname) do
        {:ok, _nickname} ->
          {:noreply, assign(socket, trigger_submit: true)}

        _ ->
          {:noreply,
           assign(socket, errors: [nickname: {"Someone already has this nickname!", []}])}
      end
    end
  end

  def handle_event("change", %{"nickname_form" => %{"nickname" => nickname}}, socket) do
    case nickname do
      "" -> {:noreply, assign(socket, errors: [nickname: {"Cannot be blank", []}])}
      _ -> {:noreply, assign(socket, nickname: nickname, errors: [])}
    end
  end
end

defmodule SimpleVoteWeb.RoomLive.Lobby do
  use SimpleVoteWeb, :surface_view

  alias SimpleVote.Rooms
  alias SimpleVote.Rooms.RoomRegistry
  alias SimpleVote.Rooms.NicknameRegistry
  alias SimpleVoteWeb.Presence

  @impl true
  @spec mount(map, any, Phoenix.LiveView.Socket.t()) :: {:ok, Phoenix.LiveView.Socket.t()}
  def mount(%{"slug" => slug}, session, socket) do
    socket =
      assign_user(session, socket)
      |> assign(:slug, slug)

    with {:ok, room_id} <- RoomRegistry.get_room_id(slug),
         room = %Rooms.Room{} <- Rooms.get_room!(room_id),
         {:ok, present} = join_room(socket, slug) do
      nickname = Map.get(session, "nickname", nil)

      if nickname do
        NicknameRegistry.register(slug, nickname)
      end

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
    nickname = Map.get(assigns, :nickname, nil)

    if nickname do
      ~H"""
      <div class="max-w-3xl mx-auto">
        <div>
          {{@room.name}}
        </div>
        <div>
          Present: {{@present}}
        </div>
        <div>
          Nickname: {{nickname}}
        </div>

        Lobby
        <div :for={{ prompt <- @room.prompts }}>
          <SimpleVoteWeb.RoomLive.Vote.Prompt body={{prompt.body}} options={{prompt.options}} />
        </div>

      </div>

      """
    else
      ~H"""
        <div class="max-w-3xl mx-auto">
          <div>
            {{@room.name}}
          </div>
          <div>
            Present: {{@present}}
          </div>

          Register now!
          <SimpleVoteWeb.RoomLive.Lobby.NameForm id="lobby-form" return={{Routes.room_lobby_path(@socket, :show, @room)}} room_slug={{@slug}}/>
        </div>
      """
    end
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

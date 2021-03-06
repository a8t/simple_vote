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
    ~F"""
    <Form
      for={ :nickname_form }
      submit="save"
      change="change"
      action={Routes.nickname_path(@socket, :create)}
      opts={
        id: "lobby-form",
        autocomplete: "off",
        phx_trigger_action: @trigger_submit
      }
      as={:nickname_form}
      errors={@errors}
    >
      <Field name="return_to">
        <HiddenInput value={@return} name="return_to" field="return_to"  form={:nickname_form}/>
      </Field>
      <Field name="room_slug">
        <HiddenInput value={@room_slug} name="room_slug" field="room_slug"  form={:nickname_form}/>
      </Field>
      <Field name="nickname">
        <Label/>
        <TextInput form={:nickname_form} value={@nickname}/>
        <ErrorTag field={:nickname}/>
      </Field>
    </Form>
    """
  end

  def handle_event("save", value, %{assigns: %{trigger_submit: trigger_submit}} = socket) do
    nickname = String.trim(value["nickname_form"]["nickname"])
    room_slug = value["room_slug"]

    with {:ok, _nickname} <- NicknameRegistry.register(room_slug, nickname) do
      {:noreply, assign(socket, trigger_submit: true)}
    else
      {:error, :nickname_already_registered} ->
        {:noreply, assign(socket, errors: [nickname: {"Someone already has this nickname!", []}])}

      {:error, :nickname_empty} ->
        {:noreply, assign(socket, errors: [nickname: {"Nickname cannot be empty!", []}])}
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
      |> assign(:other_users, get_other_users(slug, socket.id))

    with {:ok, room_id} <- RoomRegistry.get_room_id(slug),
         room = %Rooms.Room{} <- Rooms.get_room!(room_id),
         {:ok, present} = join_room(socket, slug) do
      nickname = Map.get(session, "nickname", nil)

      if nickname do
        NicknameRegistry.register(slug, nickname)

        update_nickname_presence(socket, nickname)

        # is this bad?
        if room.state == :open do
          send(self(), {:opened, room})
        else
          Rooms.subscribe(room_id)
        end
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
    other_users = Map.get(assigns, :other_users, [])
    others = Enum.join(other_users, ", ")

    if nickname do
      ~F"""
      <div class="max-w-3xl mx-auto">
        <div>
          {@room.name}
        </div>
        <div>
          Present: {@present}
        </div>
        <div>

        Others: {others}
        </div>
        <div>
          Nickname: {nickname}
        </div>

        Lobby
        <div :for={ prompt <- @room.prompts }>
          <SimpleVoteWeb.RoomLive.Vote.Prompt body={prompt.body} options={prompt.options} />
        </div>

      </div>

      """
    else
      ~F"""
        <div class="max-w-3xl mx-auto">
          <div>
            {@room.name}
          </div>
          <div>
            Present: {@present}
          </div>

          <div>
            Others: {others}
          </div>

          Register now!
          <SimpleVoteWeb.RoomLive.Lobby.NameForm id="lobby-form" return={Routes.room_lobby_path(@socket, :show, @room)} room_slug={@slug}/>
        </div>
      """
    end
  end

  defp join_room(socket, slug) do
    topic = "room:#{slug}"

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

  defp get_other_users(slug, socket_id) do
    topic = "room:#{slug}"

    for {id, %{metas: metas}} <- Presence.list(topic),
        socket_id != id,
        into: [],
        do: metas |> hd() |> Map.get(:nickname)
  end

  defp update_nickname_presence(socket, nickname) do
    slug = socket.assigns.slug
    topic = "room:#{slug}"
    Presence.update(self(), topic, socket.id, %{nickname: nickname})
  end

  @impl true
  def handle_info(
        %{event: "presence_diff", payload: %{joins: joins, leaves: leaves}},
        %{assigns: %{present: count}} = socket
      ) do
    present = count + map_size(joins) - map_size(leaves)

    socket =
      socket
      |> assign(:present, present)
      |> assign(:other_users, get_other_users(socket.assigns.slug, socket.id))

    {:noreply, socket}
  end

  @impl true
  def handle_info({:opened, room}, socket) do
    {:noreply, push_redirect(socket, to: Routes.room_vote_path(socket, :show, room))}
  end
end

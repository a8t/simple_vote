defmodule SimpleVoteWeb.RoomLive.Vote.Option do
  use Surface.Component

  @doc "The type (color) of the button"
  prop body, :string

  def render(assigns) do
    ~H"""
    <label class="relative block rounded-lg border border-gray-300 bg-white shadow-sm px-6 py-4 cursor-pointer hover:border-gray-400 sm:flex sm:justify-between focus-within:ring-1 focus-within:ring-offset-2 focus-within:ring-indigo-500">
      <input type="radio" name="server_size" value="Hobby" class="sr-only" aria-labelledby="server-size-0-label" aria-describedby="server-size-0-description-0 server-size-0-description-1">
      <div class="flex items-center">
        <div class="text-sm">
          <p id="server-size-0-label" class="font-medium text-gray-900">
          {{@body}}
          </p>
        </div>
      </div>
      <div id="server-size-0-description-1" class="mt-2 flex text-sm sm:mt-0 sm:block sm:ml-4 sm:text-right">
        <div class="font-medium text-gray-900">$40</div>
        <div class="ml-1 text-gray-500 sm:ml-0">/mo</div>
      </div>
      <!-- Checked: "border-indigo-500", Not Checked: "border-transparent" -->
      <div class="border-transparent absolute -inset-px rounded-lg border-2 pointer-events-none" aria-hidden="true"></div>
    </label>
    """
  end
end

defmodule SimpleVoteWeb.RoomLive.Vote.Prompt do
  use Surface.Component

  @doc "The body of the prompt"
  prop body, :string

  @doc "The prompt's options"
  prop options, :list

  def render(assigns) do
    ~H"""
    {{@body}}
    <fieldset class="space-y-4">
        <legend class="sr-only">
          Prompts
        </legend>
        <li :for={{ option <- @options }}>
          <SimpleVoteWeb.RoomLive.Vote.Option body={{option.body}}/>
        </li>
      </fieldset>
    """
  end
end

defmodule SimpleVoteWeb.RoomLive.Vote do
  use Surface.LiveView

  alias SimpleVote.Rooms
  alias SimpleVote.Rooms.RoomRegistry

  @impl true
  def mount(%{"slug" => slug}, _session, socket) do
    with room_id <- RoomRegistry.get_room_id(slug),
         room = %Rooms.Room{} <- Rooms.get_room!(room_id) do
      {:ok, assign(socket, :room, room)}
    else
      _err -> {:ok, redirect(socket, to: "/rooms")}
    end
  end

  @impl true
  def render(assigns) do
    IO.inspect(assigns)

    ~H"""
    {{@room.name}}
      <div :for={{ prompt <- @room.prompts }}>
        <SimpleVoteWeb.RoomLive.Vote.Prompt body={{prompt.body}} options={{prompt.options}} />
      </div>
    """
  end
end

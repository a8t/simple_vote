defmodule SimpleVote.Rooms.RoomRegistry do
  use GenServer
  alias SimpleVote.Rooms.SlugGenerator
  @table :room_registry

  @spec start_link(any) :: :ignore | {:error, any} | {:ok, pid}
  def start_link(_args) do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  @spec get_room_slug(binary()) :: binary()
  def get_room_slug(room_id) do
    :ets.match_object(@table, {:_, room_id}) |> hd |> elem(0)
  rescue
    _ -> open_room(room_id)
  end

  defp open_room(room_id) do
    room_slug = SlugGenerator.generate()

    # if the slug is already taken, try... try again!
    if :ets.insert_new(@table, {room_slug, room_id}) do
      room_slug
    else
      open_room(room_id)
    end
  end

  @spec get_room_id(binary()) :: {:error, :no_room_with_slug} | {:ok, binary()}
  def get_room_id(room_slug) do
    case :ets.lookup(@table, room_slug) do
      [{^room_slug, id}] -> {:ok, id}
      _ -> {:error, :no_room_with_slug}
    end
  end

  @spec close_room(binary()) :: true
  def close_room(room_slug) do
    :ets.delete(@table, room_slug)
  end

  ## Server
  @spec init(any) :: {:ok, nil}
  def init(_) do
    :ets.new(@table, [
      :set,
      :named_table,
      :public
    ])

    {:ok, nil}
  end
end

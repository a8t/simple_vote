defmodule SimpleVote.Rooms.NicknameRegistry do
  use GenServer

  @table :nickname_registry

  @spec start_link(any) :: :ignore | {:error, any} | {:ok, pid}
  def start_link(_args) do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def register(room_slug, nickname) do
    inserted_new = GenServer.call(__MODULE__, {:register_nickname_to_room, room_slug, nickname})

    case inserted_new do
      true -> {:ok, nickname}
      false -> {:error, :nickname_already_registered}
    end
  end

  def list(room_slug) do
    {:ok, :ets.match_object(@table, {{room_slug, :_}, :_})}
  end

  ## Server
  @spec init(any) :: {:ok, nil}
  def init(_) do
    :ets.new(@table, [
      :ordered_set,
      :named_table,
      :public
    ])

    {:ok, nil}
  end

  def handle_call({:register_nickname_to_room, room_slug, nickname}, _from, state) do
    new_inserted = :ets.insert_new(@table, {{room_slug, nickname}, %{nickname: nickname}})

    {:reply, new_inserted, state}
  end
end

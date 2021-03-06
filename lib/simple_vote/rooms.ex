defmodule SimpleVote.Rooms do
  @moduledoc """
  The Rooms context.
  """

  import Ecto.Query, warn: false
  alias SimpleVote.Repo

  alias SimpleVote.Rooms.Room

  @doc """
  Returns the list of rooms.

  ## Examples

      iex> list_rooms()
      [%Room{}, ...]

  """
  def list_rooms do
    Room |> preload([:owner]) |> Repo.all()
  end

  @doc """
  Returns the list of rooms for a given user.

  ## Examples

      iex> list_user_rooms(123)
      [%Room{}, ...]

  """
  def list_user_rooms(user_id) do
    query =
      from r in Room,
        where: r.owner_id == ^user_id

    query |> preload([:owner]) |> Repo.all()
  end

  @doc """
  Gets a single room.

  Raises `Ecto.NoResultsError` if the Room does not exist.

  ## Examples

      iex> get_room!(123)
      %Room{}

      iex> get_room!(456)
      ** (Ecto.NoResultsError)

  """
  def get_room!(id), do: Room |> preload([:owner, prompts: :options]) |> Repo.get!(id)

  @doc """
  Creates a room.

  ## Examples

      iex> create_room(%{field: value})
      {:ok, %Room{}}

      iex> create_room(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_room(attrs \\ %{}) do
    %Room{}
    |> Room.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a room.

  ## Examples

      iex> update_room(room, %{field: new_value})
      {:ok, %Room{}}

      iex> update_room(room, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_room(%Room{} = room, attrs) do
    room
    |> Room.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Open a room.

  ## Examples

      iex> open_room(room)
      {:ok, %Room{state: :open}}

      iex> open_room(room)
      {:error, %Ecto.Changeset{}}

  """
  def open_room(%Room{} = room) do
    update_room(room, %{state: :open})
    |> broadcast(:opened)
  end

  @doc """
  Close a room.

  ## Examples

      iex> close_room(room)
      {:ok, %Room{state: :closed}}

      iex> close_room(room)
      {:error, %Ecto.Changeset{}}

  """
  def close_room(%Room{} = room) do
    update_room(room, %{state: :closed})
    |> broadcast(:closed)
  end

  @doc """
  Deletes a room.

  ## Examples

      iex> delete_room(room)
      {:ok, %Room{}}

      iex> delete_room(room)
      {:error, %Ecto.Changeset{}}

  """
  def delete_room(%Room{} = room) do
    Repo.delete(room)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking room changes.

  ## Examples

      iex> change_room(room)
      %Ecto.Changeset{data: %Room{}}

  """
  def change_room(%Room{} = room, attrs \\ %{}) do
    Room.changeset(room, attrs)
  end

  @pubsub SimpleVote.PubSub

  @doc """
  Subscribes the current process to the provided pubsub topic.

  ## Examples

      iex> subscribe(room)
      %Ecto.Changeset{data: %Room{}}

  """
  def subscribe(room_id) do
    Phoenix.PubSub.subscribe(@pubsub, make_topic(room_id))
  end

  defp broadcast({:error, _reason} = error, _event), do: error

  defp broadcast({:ok, room}, event) do
    Phoenix.PubSub.broadcast(@pubsub, make_topic(room.id), {event, room})
    {:ok, room}
  end

  @doc """
  Returns a topic for PubSub.

  ## Examples

      iex> make_topic(room_id)
      "room:493"

  """
  def make_topic(room_id) do
    "room:" <> to_string(room_id)
  end
end

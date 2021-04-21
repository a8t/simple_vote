defmodule SimpleVote.RoomsTest do
  use SimpleVote.DataCase

  alias SimpleVote.Rooms

  describe "rooms" do
    alias SimpleVote.Rooms.Room

    @valid_attrs %{name: "some name"}
    @update_attrs %{name: "some updated name"}
    @invalid_attrs %{name: nil}

    def room_fixture(attrs \\ %{}) do
      {:ok, room} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Rooms.create_room()

      room
    end

    test "list_rooms/0 returns all rooms" do
      room = room_fixture()
      assert Rooms.list_rooms() == [room]
    end

    test "get_room!/1 returns the room with given id" do
      room = room_fixture()
      assert Rooms.get_room!(room.id) == room
    end

    test "create_room/1 with valid data creates a room" do
      assert {:ok, %Room{} = room} = Rooms.create_room(@valid_attrs)
      assert room.name == "some name"
    end

    test "create_room/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Rooms.create_room(@invalid_attrs)
    end

    test "update_room/2 with valid data updates the room" do
      room = room_fixture()
      assert {:ok, %Room{} = room} = Rooms.update_room(room, @update_attrs)
      assert room.name == "some updated name"
    end

    test "update_room/2 with invalid data returns error changeset" do
      room = room_fixture()
      assert {:error, %Ecto.Changeset{}} = Rooms.update_room(room, @invalid_attrs)
      assert room == Rooms.get_room!(room.id)
    end

    test "delete_room/1 deletes the room" do
      room = room_fixture()
      assert {:ok, %Room{}} = Rooms.delete_room(room)
      assert_raise Ecto.NoResultsError, fn -> Rooms.get_room!(room.id) end
    end

    test "change_room/1 returns a room changeset" do
      room = room_fixture()
      assert %Ecto.Changeset{} = Rooms.change_room(room)
    end
  end

  describe "room registry" do
    alias SimpleVote.Rooms.RoomRegistry

    test "registers" do
      room_slug = RoomRegistry.get_room_slug("id")

      assert room_slug == RoomRegistry.get_room_slug("id")
    end

    test "closes" do
      original_room_slug = RoomRegistry.get_room_slug("id")

      RoomRegistry.close_room(original_room_slug)

      # make sure that the new room slug isn't the same as the original
      assert original_room_slug != RoomRegistry.get_room_slug("id")
    end

    test "get_room_id" do
      room_slug = RoomRegistry.get_room_slug("id")

      assert RoomRegistry.get_room_id(room_slug) == "id"
    end
  end
end
defmodule SimpleVote.RoomsTest do
  use SimpleVote.DataCase, async: true

  import SimpleVote.Factory

  alias SimpleVote.Rooms
  alias SimpleVote.Rooms.Room
  alias SimpleVote.Repo

  describe "rooms" do
    @valid_attrs %{name: "some name"}
    @update_attrs %{name: "some updated name"}
    @invalid_attrs %{name: nil}

    test "list_rooms/0 returns all rooms" do
      room = insert(:room)
      assert Rooms.list_rooms() == [room]
    end

    test "list_user_rooms/1 returns all rooms for the right user" do
      user = insert(:user)
      room = insert(:room, owner: user)
      assert Rooms.list_user_rooms(user.id) == [room]

      other_user = insert(:user)
      assert Rooms.list_user_rooms(other_user.id) == []
    end

    test "get_room!/1 returns the room with given id" do
      room = insert(:room) |> Repo.preload(:prompts)
      assert Rooms.get_room!(room.id) == room
    end

    test "create_room/1 with valid data creates a room" do
      user = insert(:user)
      attrs = Map.merge(@valid_attrs, %{owner_id: user.id})
      assert {:ok, %Room{} = room} = Rooms.create_room(attrs)
      assert room.name == "some name"
    end

    test "create_room/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Rooms.create_room(@invalid_attrs)
    end

    test "update_room/2 with valid data updates the room" do
      room = insert(:room)
      assert {:ok, %Room{} = room} = Rooms.update_room(room, @update_attrs)
      assert room.name == "some updated name"
    end

    test "update_room/2 with invalid data returns error changeset" do
      room = insert(:room)
      assert {:error, %Ecto.Changeset{}} = Rooms.update_room(room, @invalid_attrs)
      assert room |> Repo.preload(:prompts) == Rooms.get_room!(room.id)
    end

    test "delete_room/1 deletes the room" do
      room = insert(:room)
      assert {:ok, %Room{}} = Rooms.delete_room(room)
      assert_raise Ecto.NoResultsError, fn -> Rooms.get_room!(room.id) end
    end

    test "change_room/1 returns a room changeset" do
      room = insert(:room)
      assert %Ecto.Changeset{} = Rooms.change_room(room)
    end

    test "open_room/1 opens room" do
      room = insert(:room)
      assert {:ok, %Room{state: :open}} = Rooms.open_room(room)
    end

    test "close_room/1 closes room" do
      room = insert(:room)
      assert {:ok, %Room{state: :closed}} = Rooms.close_room(room)
    end
  end

  describe "room pubsub utils" do
    @pubsub SimpleVote.PubSub

    test "make_topic/1 makes topic" do
      room = insert(:room)

      assert Rooms.make_topic(room.id) == "room:#{to_string(room.id)}"
    end

    test "subscribe/1 subscribes the current process" do
      Rooms.subscribe(1)

      Phoenix.PubSub.broadcast(@pubsub, Rooms.make_topic(1), :hello)

      assert_received(:hello)
    end
  end

  describe "room pubsub broadcasts" do
    setup do
      room = insert(:room)
      Rooms.subscribe(room.id)
      %{room: room}
    end

    test "open_room/1 broadcasts", %{room: room} do
      Rooms.open_room(room)

      assert_receive({:opened, %Room{}}, 100)
    end

    test "close_room/1 broadcasts", %{room: room} do
      Rooms.close_room(room)

      assert_receive({:closed, %Room{}}, 100)
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

      assert RoomRegistry.get_room_id(room_slug) == {:ok, "id"}
    end

    test "get_room_id with bad slug" do
      assert {:error, :no_room_with_slug} = RoomRegistry.get_room_id("bad slug")
    end
  end

  describe "nickname registry" do
    alias SimpleVote.Rooms.RoomRegistry
    alias SimpleVote.Rooms.NicknameRegistry

    setup do
      room_id = :rand.uniform(9999)
      room_slug = RoomRegistry.get_room_slug(room_id)

      %{room_id: room_id, room_slug: room_slug}
    end

    test "register/1 - registers nickname to room that exists", %{room_slug: room_slug} do
      assert {:ok, "nickname"} = NicknameRegistry.register(room_slug, "nickname")
    end

    test "register/1 - allows multiple registration to the same room", %{room_slug: room_slug} do
      assert {:ok, "nickname"} = NicknameRegistry.register(room_slug, "nickname")
      assert {:ok, "nickname2"} = NicknameRegistry.register(room_slug, "nickname2")
    end

    test "register/1 - errors if nickname already registered", %{room_slug: room_slug} do
      NicknameRegistry.register(room_slug, "nickname")

      assert {:error, :nickname_already_registered} =
               NicknameRegistry.register(room_slug, "nickname")
    end

    test "list/1 - lists nicknames registered in a room", %{room_slug: room_slug} do
      {:ok, _} = NicknameRegistry.register(room_slug, "andy")
      {:ok, _} = NicknameRegistry.register(room_slug, "fatima")

      assert {:ok,
              [
                {{^room_slug, "andy"}, %{nickname: "andy"}},
                {{^room_slug, "fatima"}, %{nickname: "fatima"}}
              ]} = NicknameRegistry.list(room_slug)
    end

    test "list/1 - returns empty list for empty room", %{room_slug: room_slug} do
      assert {:ok, []} = NicknameRegistry.list(room_slug)
    end

    test "list/1 - returns empty list even if room dne", %{room_slug: _room_slug} do
      assert {:ok, []} = NicknameRegistry.list("hello")
    end

    test "unregister/1 - unregisters from a room", %{room_slug: room_slug} do
      {:ok, _} = NicknameRegistry.register(room_slug, "andy")
      assert :ok = NicknameRegistry.unregister(room_slug, "andy")
      assert {:ok, []} = NicknameRegistry.list(room_slug)
    end
  end
end

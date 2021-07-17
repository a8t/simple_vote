defmodule SimpleVoteWeb.RoomLiveIndexTest do
  use SimpleVoteWeb.ConnCase

  import Phoenix.LiveViewTest
  import SimpleVote.Factory

  @create_attrs %{name: "some name"}
  @update_attrs %{name: "some updated name"}
  @invalid_attrs %{name: nil}

  defp create_room(%{conn: conn}) do
    user = insert(:user)
    room = insert(:room, owner: user)

    authed_conn = conn |> log_in_user(user)

    %{room: room, user: user, authed_conn: authed_conn}
  end

  describe "Index" do
    setup [:create_room]

    test "lists only rooms created by this user", %{
      conn: conn,
      authed_conn: authed_conn,
      room: room
    } do
      {:ok, _index_live, html} = live(conn, Routes.room_index_path(conn, :index))

      assert html =~ "Listing Rooms"
      refute html =~ room.name

      {:ok, _index_live, html} = live(authed_conn, Routes.room_index_path(authed_conn, :index))

      assert html =~ "Listing Rooms"
      assert html =~ room.name
    end

    test "saves new room", %{authed_conn: authed_conn} do
      {:ok, index_live, _html} = live(authed_conn, Routes.room_index_path(authed_conn, :index))

      assert index_live |> element("a", "New Room") |> render_click() =~
               "New Room"

      assert_patch(index_live, Routes.room_index_path(authed_conn, :new))

      assert index_live
             |> form("#room-form", room: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#room-form", room: @create_attrs)
        |> render_submit()
        |> follow_redirect(authed_conn)

      assert html =~ "Room created successfully"
      assert html =~ "some name"

      # make sure it's there

      {:ok, _index_live, html} = live(authed_conn, Routes.room_index_path(authed_conn, :index))

      assert html =~ @create_attrs.name
    end

    test "updates room in listing", %{authed_conn: authed_conn, room: room} do
      {:ok, index_live, _html} = live(authed_conn, Routes.room_index_path(authed_conn, :index))

      assert index_live |> element("#room-#{room.id} a", "Edit") |> render_click() =~
               "Edit Room"

      assert_patch(index_live, Routes.room_index_path(authed_conn, :edit, room))

      assert index_live
             |> form("#room-form", room: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#room-form", room: @update_attrs)
        |> render_submit()
        |> follow_redirect(authed_conn, Routes.room_index_path(authed_conn, :index))

      assert html =~ "Room updated successfully"
      assert html =~ "some updated name"
    end

    test "deletes room in listing", %{authed_conn: authed_conn, room: room} do
      {:ok, index_live, _html} = live(authed_conn, Routes.room_index_path(authed_conn, :index))

      assert index_live |> element("#room-#{room.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#room-#{room.id}")
    end
  end
end

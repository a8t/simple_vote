defmodule SimpleVoteWeb.VoteLiveTest do
  use SimpleVoteWeb.ConnCase

  import Phoenix.LiveViewTest
  import SimpleVote.Factory

  defp create_room(%{conn: conn}) do
    user = insert(:user)
    room = insert(:room, owner: user)

    authed_conn = conn |> log_in_user(user)

    %{room: room, user: user, authed_conn: authed_conn}
  end

  describe "Show" do
    setup [:create_room]

    test "shows room", %{conn: conn, room: room} do
      {:ok, _show_live, html} = live(conn, Routes.room_vote_path(conn, :show, room))

      assert html =~ room.name
    end

    test "allows room creator to vote", %{
      authed_conn: authed_conn,
      room: room
    } do
      {:ok, _show_live, html} = live(authed_conn, Routes.room_vote_path(authed_conn, :show, room))

      assert html =~ "Vote:"
      assert html =~ room.name
    end

    test "redirects if bad slug", %{conn: conn} do
      assert {:ok, _conn} =
               conn
               |> live("/rooms/bad_slug/vote")
               |> follow_redirect(conn, Routes.room_index_path(conn, :index))
    end

    test "publishes on join", %{
      conn: conn,
      room: room
    } do
      {:ok, _show_live, _html} = live(conn, Routes.room_vote_path(conn, :show, room))
      {:ok, _show_live, html} = live(conn, Routes.room_vote_path(conn, :show, room))

      assert html =~ "Present: 2"
    end
  end

  describe "Lobby" do
    setup [:create_room]

    defp refute_redirect(conn, path) do
      try do
        assert_redirect(conn, path)
      rescue
        e ->
          assert %ArgumentError{message: message} = e
          assert message =~ "to redirect to"
      end
    end

    test "Doesn't redirect if user has no nickname", %{conn: conn, room: room} do
      {:ok, show_live, _html} = live(conn, Routes.room_lobby_path(conn, :show, room))

      SimpleVote.Rooms.open_room(room)

      refute_redirect(show_live, Routes.room_vote_path(conn, :show, room))
    end

    test "Redirects to /vote if user has nickname when room opens", %{conn: conn, room: room} do
      {:ok, show_live, _html} = live_register_nickname(room, "nickname1", conn)

      SimpleVote.Rooms.open_room(room)

      assert_redirect(show_live, Routes.room_vote_path(conn, :show, room))
    end

    test "Redirects to /vote if user sets nickname after room opens", %{conn: conn, room: room} do
      {:ok, _show_live, _html} = live(conn, Routes.room_lobby_path(conn, :show, room))

      SimpleVote.Rooms.open_room(room)

      {:ok, show_live, _html} = live_register_nickname(room, "nickname1", conn)

      assert_redirect(show_live, Routes.room_vote_path(conn, :show, room))
    end

    test "shows form", %{conn: conn, room: room} do
      {:ok, _show_live, html} = live(conn, Routes.room_lobby_path(conn, :show, room))

      assert html =~ "Register now!"
    end

    test "form shows validation errors correctly when blank name", %{conn: conn, room: room} do
      {:ok, show_live, html} = live(conn, Routes.room_lobby_path(conn, :show, room))

      refute html =~ "Cannot be blank"

      refute show_live
             |> form("#lobby-form")
             |> render_change(
               nickname_form: %{
                 nickname: "hello"
               }
             ) =~ "Cannot be blank"

      assert show_live
             |> form("#lobby-form")
             |> render_change(
               nickname_form: %{
                 nickname: ""
               }
             ) =~ "Cannot be blank"
    end

    test "registering nickname works! submiting form triggers POST submission form", %{
      conn: conn,
      room: room
    } do
      {:ok, show_live, _html} = live(conn, Routes.room_lobby_path(conn, :show, room))

      show_live
      |> form("#lobby-form",
        nickname_form: %{
          nickname: "hello"
        }
      )
      |> render_submit()

      conn =
        show_live
        |> form("#lobby-form",
          nickname_form: %{
            nickname: "hello"
          },
          return_to: Routes.room_lobby_path(conn, :show, room)
        )
        |> follow_trigger_action(conn)

      assert get_session(conn, :nickname) == "hello"

      # make sure the form is gone now
      {:ok, show_live, _html} = live(conn, Routes.room_lobby_path(conn, :show, room))

      refute show_live
             |> has_element?("#lobby-form")
    end

    test "registers nickname in room if exists in session", %{conn: conn, room: room} do
      conn = Plug.Test.init_test_session(conn, nickname: "hello")

      room_slug = SimpleVote.Rooms.RoomRegistry.get_room_slug(room.id)
      {:ok, []} = SimpleVote.Rooms.NicknameRegistry.list(room_slug)

      {:ok, _show_live, _html} = live(conn, Routes.room_lobby_path(conn, :show, room))
      refute {:ok, []} == SimpleVote.Rooms.NicknameRegistry.list(room_slug)
    end

    test "form shows validation errors when submitting empty nickname", %{conn: conn, room: room} do
      # setup! make a conn with nickname
      {:ok, show_live, _html} = live(conn, Routes.room_lobby_path(conn, :show, room))

      assert show_live
             |> form("#lobby-form",
               nickname_form: %{
                 nickname: ""
               }
             )
             |> render_submit() =~
               "Nickname cannot be empty!"
    end

    test "form shows validation errors when submitting whitespace nickname", %{
      conn: conn,
      room: room
    } do
      {:ok, show_live, _html} = live(conn, Routes.room_lobby_path(conn, :show, room))

      assert show_live
             |> form("#lobby-form",
               nickname_form: %{
                 nickname: " "
               }
             )
             |> render_submit() =~
               "Nickname cannot be empty!"
    end

    defp live_register_nickname(room, nickname, conn \\ build_conn()) do
      {:ok, show_live, _html} = live(conn, Routes.room_lobby_path(conn, :show, room))

      show_live
      |> form("#lobby-form",
        nickname_form: %{
          nickname: nickname
        }
      )
      |> render_submit()

      triggered_conn =
        show_live
        |> form("#lobby-form",
          nickname_form: %{
            nickname: nickname
          },
          return_to: Routes.room_lobby_path(conn, :show, room)
        )
        |> follow_trigger_action(conn)

      live(triggered_conn, Routes.room_lobby_path(triggered_conn, :show, room))
    end

    test "displays all registered people", %{
      room: room
    } do
      # first person registers
      live_register_nickname(room, "nickname1")
      # second person registers
      live_register_nickname(room, "nickname2")

      # third person connects
      third_conn = build_conn()

      {:ok, _third_show_live, html} =
        live(third_conn, Routes.room_lobby_path(third_conn, :show, room))

      # assert that they see both previous nicknames
      assert html =~ "nickname1"
      assert html =~ "nickname2"
    end

    test "form shows validation errors when duplicate name", %{room: room} do
      # first, register with a given nickname
      live_register_nickname(room, "uniq-nickname")

      # now, try to register another user with the same nickname
      another_conn = build_conn()

      {:ok, another_show_live, _html} =
        live(another_conn, Routes.room_lobby_path(another_conn, :show, room))

      assert another_show_live
             |> form("#lobby-form",
               nickname_form: %{
                 nickname: "uniq-nickname"
               },
               return_to: Routes.room_lobby_path(another_conn, :show, room)
             )
             |> render_submit() =~
               "Someone already has this nickname!"
    end
  end
end

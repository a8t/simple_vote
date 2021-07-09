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

    test "displays all registered people", %{
      conn: conn,
      room: room
    } do
      # first person registers
      {:ok, show_live, _html} = live(conn, Routes.room_lobby_path(conn, :show, room))

      show_live
      |> form("#lobby-form",
        nickname_form: %{
          nickname: "nickname1"
        }
      )
      |> render_submit()

      triggered_conn =
        show_live
        |> form("#lobby-form",
          nickname_form: %{
            nickname: "nickname1"
          },
          return_to: Routes.room_lobby_path(conn, :show, room)
        )
        |> follow_trigger_action(conn)

      # second person registers

      another_conn = build_conn()

      {:ok, second_show_live, _html} =
        live(another_conn, Routes.room_lobby_path(another_conn, :show, room))

      second_show_live
      |> form("#lobby-form",
        nickname_form: %{
          nickname: "hello2"
        }
      )
      |> render_submit()

      second_show_live
      |> form("#lobby-form",
        nickname_form: %{
          nickname: "hello2"
        },
        return_to: Routes.room_lobby_path(another_conn, :show, room)
      )
      |> follow_trigger_action(another_conn)

      third_conn = build_conn()

      {:ok, _third_show_live, html} =
        live(third_conn, Routes.room_lobby_path(third_conn, :show, room))

      ["", _, slug, "lobby"] =
        Routes.room_lobby_path(third_conn, :show, room) |> String.split("/")

      assert html =~ "hello2"
      assert html =~ "nickname1"
    end

    test "registers nickname in room if exists in session", %{conn: conn, room: room} do
      conn = Plug.Test.init_test_session(conn, nickname: "hello")

      room_slug = SimpleVote.Rooms.RoomRegistry.get_room_slug(room.id)
      {:ok, []} = SimpleVote.Rooms.NicknameRegistry.list(room_slug)

      {:ok, _show_live, _html} = live(conn, Routes.room_lobby_path(conn, :show, room))
      refute {:ok, []} == SimpleVote.Rooms.NicknameRegistry.list(room_slug)
    end

    test "form shows validation errors when duplicate name", %{conn: conn, room: room} do
      # setup! make a conn with nickname
      {:ok, show_live, _html} = live(conn, Routes.room_lobby_path(conn, :show, room))

      show_live
      |> form("#lobby-form",
        nickname_form: %{
          nickname: "nickname"
        }
      )
      |> render_submit()

      show_live
      |> form("#lobby-form",
        nickname_form: %{
          nickname: "nickname"
        },
        return_to: Routes.room_lobby_path(conn, :show, room)
      )
      |> follow_trigger_action(conn)

      # ok now make another conn and try to register with the same nickname there

      another_conn = build_conn()

      {:ok, another_show_live, _html} =
        live(another_conn, Routes.room_lobby_path(another_conn, :show, room))

      assert another_show_live
             |> form("#lobby-form",
               nickname_form: %{
                 nickname: "nickname"
               },
               return_to: Routes.room_lobby_path(another_conn, :show, room)
             )
             |> render_submit() =~
               "Someone already has this nickname!"
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
      # setup! make a conn with nickname
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
  end
end

defmodule SimpleVoteWeb.RoomLiveTest do
  use SimpleVoteWeb.ConnCase

  import Phoenix.LiveViewTest
  import SimpleVote.Factory

  @create_attrs %{name: "some name"}
  @update_attrs %{name: "some updated name"}
  @invalid_attrs %{name: nil}

  defp create_room(_) do
    room = insert(:room)
    %{room: room}
  end

  describe "Index" do
    setup [:create_room]

    test "lists all rooms", %{conn: conn, room: room} do
      {:ok, _index_live, html} = live(conn, Routes.room_index_path(conn, :index))

      assert html =~ "Listing Rooms"
      assert html =~ room.name
    end

    test "saves new room", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, Routes.room_index_path(conn, :index))

      assert index_live |> element("a", "New Room") |> render_click() =~
               "New Room"

      assert_patch(index_live, Routes.room_index_path(conn, :new))

      assert index_live
             |> form("#room-form", room: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#room-form", room: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn)

      assert html =~ "Room created successfully"
      assert html =~ "some name"
    end

    test "updates room in listing", %{conn: conn, room: room} do
      {:ok, index_live, _html} = live(conn, Routes.room_index_path(conn, :index))

      assert index_live |> element("#room-#{room.id} a", "Edit") |> render_click() =~
               "Edit Room"

      assert_patch(index_live, Routes.room_index_path(conn, :edit, room))

      assert index_live
             |> form("#room-form", room: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#room-form", room: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.room_index_path(conn, :index))

      assert html =~ "Room updated successfully"
      assert html =~ "some updated name"
    end

    test "deletes room in listing", %{conn: conn, room: room} do
      {:ok, index_live, _html} = live(conn, Routes.room_index_path(conn, :index))

      assert index_live |> element("#room-#{room.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#room-#{room.id}")
    end
  end

  describe "Show" do
    setup [:create_room]

    test "displays room", %{conn: conn, room: room} do
      {:ok, _show_live, html} = live(conn, Routes.room_show_path(conn, :show, room))

      assert html =~ "Show Room"
      assert html =~ room.name
    end

    test "updates room within modal", %{conn: conn, room: room} do
      {:ok, show_live, _html} = live(conn, Routes.room_show_path(conn, :show, room))

      assert show_live |> element("a#edit-room") |> render_click() =~
               "Edit Room"

      assert_patch(show_live, Routes.room_show_path(conn, :edit, room))

      assert show_live
             |> form("#room-form", room: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        show_live
        |> form("#room-form", room: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.room_show_path(conn, :show, room))

      assert html =~ "Room updated successfully"
      assert html =~ "some updated name"
    end
  end

  @create_prompt_attrs %{body: "some body"}
  @update_prompt_attrs %{body: "some updated body"}
  @invalid_prompt_attrs %{body: nil}

  defp create_room_and_prompt(_) do
    room = insert(:room)
    prompt = insert(:prompt, room: room)
    %{room: room, prompt: prompt}
  end

  describe "Show room prompts" do
    setup [:create_room_and_prompt]

    test "lists all prompts", %{conn: conn, room: room, prompt: prompt} do
      {:ok, _index_live, html} = live(conn, Routes.room_show_path(conn, :show, room))

      assert html =~ prompt.body
    end

    test "saves new prompt", %{conn: conn, room: room} do
      {:ok, show_live, _html} = live(conn, Routes.room_show_path(conn, :show, room))

      assert show_live |> element("a#new-prompt") |> render_click() =~
               "New Prompt"

      assert_patch(show_live, Routes.room_show_path(conn, :new_prompt, room))

      assert show_live
             |> form("#prompt-form", prompt: @invalid_prompt_attrs)
             |> render_change() =~ "t be blank"

      {:ok, _, html} =
        show_live
        |> form("#prompt-form", prompt: @create_prompt_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.room_show_path(conn, :show, room))

      assert html =~ "Prompt created successfully"
      assert html =~ "some body"
    end

    test "updates prompt in listing", %{conn: conn, room: room, prompt: prompt} do
      {:ok, index_live, _html} = live(conn, Routes.room_show_path(conn, :show, room))

      assert index_live |> element("a#prompt-#{prompt.id}-edit") |> render_click() =~
               "Edit Prompt"

      assert_patch(index_live, Routes.room_show_path(conn, :edit_prompt, room, prompt))

      assert index_live
             |> form("#prompt-form", prompt: @invalid_prompt_attrs)
             |> render_change() =~ "t be blank"

      {:ok, _, html} =
        index_live
        |> form("#prompt-form", prompt: @update_prompt_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.room_show_path(conn, :show, room))

      assert html =~ "Prompt updated successfully"
      assert html =~ "some updated body"
    end

    test "deletes prompt in listing", %{conn: conn, room: room, prompt: prompt} do
      {:ok, index_live, _html} = live(conn, Routes.room_show_path(conn, :show, room))

      assert index_live |> element("#prompt-#{prompt.id}-delete") |> render_click()
      refute has_element?(index_live, "#prompt-#{prompt.id}")
    end
  end

  describe "Show room prompts and options" do
    @create_option_attrs %{body: "some body"}
    @update_option_attrs %{body: "some updated body"}
    @invalid_option_attrs %{body: nil}

    defp create_room_prompt_and_option(_) do
      room = insert(:room)
      prompt = insert(:prompt, room: room)
      option = insert(:option, prompt: prompt)
      %{room: room, prompt: prompt, option: option}
    end

    setup [:create_room_prompt_and_option]

    test "displays option", %{conn: conn, room: room, prompt: prompt, option: option} do
      {:ok, _show_live, html} = live(conn, Routes.room_show_path(conn, :show, room))

      assert html =~ prompt.body
      assert html =~ option.body
    end

    test "saves new option", %{conn: conn, room: room, prompt: prompt} do
      {:ok, show_live, _html} = live(conn, Routes.room_show_path(conn, :show, room))

      assert show_live |> element("#new-option") |> render_click() =~
               "New Option"

      assert_patch(show_live, Routes.room_show_path(conn, :new_option, room, prompt))

      assert show_live
             |> form("#option-form", option: @invalid_option_attrs)
             |> render_change() =~ "t be blank"

      {:ok, _, html} =
        show_live
        |> form("#option-form", option: @create_option_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.room_show_path(conn, :show, room))

      assert html =~ "Option created successfully"
      assert html =~ "some body"
    end

    test "updates prompt within modal", %{conn: conn, room: room, prompt: prompt, option: option} do
      {:ok, show_live, _html} = live(conn, Routes.room_show_path(conn, :show, room))

      assert show_live |> element("#option-#{option.id}-edit") |> render_click() =~
               "Edit Option"

      assert_patch(show_live, Routes.room_show_path(conn, :edit_option, room, prompt, option))

      assert show_live
             |> form("#option-form", option: @invalid_option_attrs)
             |> render_change() =~ "t be blank"

      {:ok, _, html} =
        show_live
        |> form("#option-form", option: @update_option_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.room_show_path(conn, :show, room))

      assert html =~ "Option updated successfully"
      assert html =~ "some updated body"
    end

    test "deletes option", %{conn: conn, room: room, option: option} do
      {:ok, show_live, _html} = live(conn, Routes.room_show_path(conn, :show, room))

      assert show_live |> element("#option-#{option.id}-delete") |> render_click()
      refute has_element?(show_live, "#option-#{option.id}")
    end
  end
end

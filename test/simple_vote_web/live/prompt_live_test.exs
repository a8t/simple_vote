defmodule SimpleVoteWeb.PromptLiveTest do
  use SimpleVoteWeb.ConnCase

  import Phoenix.LiveViewTest

  alias SimpleVote.Polls

  @create_attrs %{body: "some body"}
  @update_attrs %{body: "some updated body"}
  @invalid_attrs %{body: nil}

  defp fixture(:prompt) do
    {:ok, prompt} = Polls.create_prompt(@create_attrs)
    prompt
  end

  defp create_prompt(_) do
    prompt = fixture(:prompt)
    %{prompt: prompt}
  end

  describe "Index" do
    setup [:create_prompt]

    test "lists all prompts", %{conn: conn, prompt: prompt} do
      {:ok, _index_live, html} = live(conn, Routes.prompt_index_path(conn, :index))

      assert html =~ "Listing Prompts"
      assert html =~ prompt.body
    end

    test "saves new prompt", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, Routes.prompt_index_path(conn, :index))

      assert index_live |> element("a#new-prompt") |> render_click() =~
               "New Prompt"

      assert_patch(index_live, Routes.prompt_index_path(conn, :new))

      assert index_live
             |> form("#prompt-form", prompt: @invalid_attrs)
             |> render_change() =~ "t be blank"

      {:ok, _, html} =
        index_live
        |> form("#prompt-form", prompt: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.prompt_index_path(conn, :index))

      assert html =~ "Prompt created successfully"
      assert html =~ "some body"
    end

    test "updates prompt in listing", %{conn: conn, prompt: prompt} do
      {:ok, index_live, _html} = live(conn, Routes.prompt_index_path(conn, :index))

      assert index_live |> element("#prompt-#{prompt.id} a", "Edit body") |> render_click() =~
               "Edit Prompt"

      assert_patch(index_live, Routes.prompt_index_path(conn, :edit, prompt))

      assert index_live
             |> form("#prompt-form", prompt: @invalid_attrs)
             |> render_change() =~ "t be blank"

      {:ok, _, html} =
        index_live
        |> form("#prompt-form", prompt: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.prompt_index_path(conn, :index))

      assert html =~ "Prompt updated successfully"
      assert html =~ "some updated body"
    end

    test "deletes prompt in listing", %{conn: conn, prompt: prompt} do
      {:ok, index_live, _html} = live(conn, Routes.prompt_index_path(conn, :index))

      assert index_live |> element("#prompt-#{prompt.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#prompt-#{prompt.id}")
    end
  end

  describe "Show" do
    setup [:create_prompt]

    test "displays prompt", %{conn: conn, prompt: prompt} do
      {:ok, _show_live, html} = live(conn, Routes.prompt_show_path(conn, :show, prompt))

      assert html =~ "Show Prompt"
      assert html =~ prompt.body
    end

    test "updates prompt within modal", %{conn: conn, prompt: prompt} do
      {:ok, show_live, _html} = live(conn, Routes.prompt_show_path(conn, :show, prompt))

      assert show_live |> element("#edit-body") |> render_click() =~
               "Edit Prompt"

      assert_patch(show_live, Routes.prompt_show_path(conn, :edit, prompt))

      assert show_live
             |> form("#prompt-form", prompt: @invalid_attrs)
             |> render_change() =~ "t be blank"

      {:ok, _, html} =
        show_live
        |> form("#prompt-form", prompt: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.prompt_show_path(conn, :show, prompt))

      assert html =~ "Prompt updated successfully"
      assert html =~ "some updated body"
    end
  end
end

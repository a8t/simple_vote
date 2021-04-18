defmodule SimpleVote.PollsTest do
  use SimpleVote.DataCase

  alias SimpleVote.Polls

  describe "prompts" do
    alias SimpleVote.Polls.Prompt

    @valid_attrs %{body: "some body"}
    @update_attrs %{body: "some updated body"}
    @invalid_attrs %{body: nil}

    def prompt_fixture(attrs \\ %{}) do
      {:ok, prompt} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Polls.create_prompt()

      prompt
    end

    test "list_prompts/0 returns all prompts" do
      prompt = prompt_fixture()
      assert Polls.list_prompts() == [prompt]
    end

    test "get_prompt!/1 returns the prompt with given id" do
      prompt = prompt_fixture()
      assert Polls.get_prompt!(prompt.id) == prompt
    end

    test "create_prompt/1 with valid data creates a prompt" do
      assert {:ok, %Prompt{} = prompt} = Polls.create_prompt(@valid_attrs)
      assert prompt.body == "some body"
    end

    test "create_prompt/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Polls.create_prompt(@invalid_attrs)
    end

    test "update_prompt/2 with valid data updates the prompt" do
      prompt = prompt_fixture()
      assert {:ok, %Prompt{} = prompt} = Polls.update_prompt(prompt, @update_attrs)
      assert prompt.body == "some updated body"
    end

    test "update_prompt/2 with invalid data returns error changeset" do
      prompt = prompt_fixture()
      assert {:error, %Ecto.Changeset{}} = Polls.update_prompt(prompt, @invalid_attrs)
      assert prompt == Polls.get_prompt!(prompt.id)
    end

    test "delete_prompt/1 deletes the prompt" do
      prompt = prompt_fixture()
      assert {:ok, %Prompt{}} = Polls.delete_prompt(prompt)
      assert_raise Ecto.NoResultsError, fn -> Polls.get_prompt!(prompt.id) end
    end

    test "change_prompt/1 returns a prompt changeset" do
      prompt = prompt_fixture()
      assert %Ecto.Changeset{} = Polls.change_prompt(prompt)
    end
  end
end

defmodule SimpleVote.PollsTest do
  alias SimpleVote.Polls

  import SimpleVote.Factory

  use SimpleVote.DataCase

  describe "prompts" do
    alias SimpleVote.Polls.Prompt

    @valid_attrs %{body: "some body"}
    @update_attrs %{body: "some updated body"}
    @invalid_attrs %{body: nil}

    test "list_prompts/0 returns all prompts" do
      prompt = insert(:prompt)
      assert Polls.list_prompts() == [prompt]
    end

    test "get_prompt!/1 returns the prompt with given id" do
      prompt = insert(:prompt)
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
      prompt = insert(:prompt)
      assert {:ok, %Prompt{} = prompt} = Polls.update_prompt(prompt, @update_attrs)
      assert prompt.body == "some updated body"
    end

    test "update_prompt/2 with invalid data returns error changeset" do
      prompt = insert(:prompt)
      assert {:error, %Ecto.Changeset{}} = Polls.update_prompt(prompt, @invalid_attrs)
      assert prompt == Polls.get_prompt!(prompt.id)
    end

    test "delete_prompt/1 deletes the prompt" do
      prompt = insert(:prompt)
      assert {:ok, %Prompt{}} = Polls.delete_prompt(prompt)
      assert_raise Ecto.NoResultsError, fn -> Polls.get_prompt!(prompt.id) end
    end

    test "change_prompt/1 returns a prompt changeset" do
      prompt = insert(:prompt)
      assert %Ecto.Changeset{} = Polls.change_prompt(prompt)
    end
  end

  describe "options" do
    alias SimpleVote.Polls.Option

    @valid_attrs %{body: "some body"}
    @update_attrs %{body: "some updated body"}
    @invalid_attrs %{body: nil}

    test "create_option_for_prompt/1 with valid data creates a option" do
      prompt = insert(:prompt)
      assert {:ok, %Option{} = option} = Polls.create_option_for_prompt(prompt, @valid_attrs)
      assert option.body == "some body"
    end

    test "create_option_for_prompt/1 with invalid data returns error changeset" do
      prompt = insert(:prompt)

      assert {:error, %Ecto.Changeset{}} = Polls.create_option_for_prompt(prompt, @invalid_attrs)
    end

    test "update_option/2 with valid data updates the option" do
      option = insert(:option)
      assert {:ok, %Option{} = option} = Polls.update_option(option, @update_attrs)
      assert option.body == "some updated body"
    end

    test "update_option/2 with invalid data returns error changeset" do
      option = insert(:option)
      assert {:error, %Ecto.Changeset{}} = Polls.update_option(option, @invalid_attrs)
      assert option == Polls.get_option!(option.id) |> SimpleVote.Repo.preload(:prompt)
    end

    test "delete_option/1 deletes the option" do
      option = insert(:option)
      assert {:ok, %Option{}} = Polls.delete_option(option)
      assert_raise Ecto.NoResultsError, fn -> Polls.get_option!(option.id) end
    end

    test "change_option/1 returns a option changeset" do
      option = insert(:option)
      assert %Ecto.Changeset{} = Polls.change_option(option)
    end
  end
end

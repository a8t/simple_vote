defmodule SimpleVote.PollsTest do
  alias SimpleVote.Polls

  import SimpleVote.Factory

  use SimpleVote.DataCase

  describe "prompts" do
    alias SimpleVote.Polls.Prompt

    @update_attrs %{body: "some updated body"}
    @invalid_attrs %{body: nil}

    test "list_prompts/0 returns all prompts" do
      prompt = insert(:prompt, options: [])
      assert Polls.list_prompts() == [prompt]
    end

    test "get_prompt!/1 returns the prompt with given id" do
      prompt = insert(:prompt, options: [])
      assert Polls.get_prompt!(prompt.id) == prompt
    end

    test "create_prompt/1 with valid data creates a prompt" do
      room = insert(:room)

      assert {:ok, %Prompt{} = prompt} =
               Polls.create_prompt(%{body: "some body", room_id: room.id})

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
      prompt = insert(:prompt, options: [])
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
      room = insert(:room)
      prompt = insert(:prompt, room: room)
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
      assert option.id == Polls.get_option!(option.id).id
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

  describe "votes" do
    alias SimpleVote.Polls.Vote

    @update_attrs %{}
    @invalid_attrs %{}

    test "list_votes/0 returns all votes" do
      vote = insert(:vote)
      assert Polls.list_votes() |> length == 1
      assert Polls.list_votes() |> hd |> Map.get(:id) == vote.id
    end

    test "get_vote!/1 returns the vote with given id" do
      vote = insert(:vote)
      assert Polls.get_vote!(vote.id).id == vote.id
    end

    test "create_vote/1 with valid data creates a vote" do
      user = insert(:user)
      option = insert(:option)

      assert {:ok, %Vote{}} = Polls.create_vote(%{user_id: user.id, option_id: option.id})
    end

    test "create_vote/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Polls.create_vote(@invalid_attrs)
    end

    test "update_vote/2 with valid data updates the vote" do
      vote = insert(:vote)
      assert {:ok, %Vote{}} = Polls.update_vote(vote, @update_attrs)
    end

    test "update_vote/2 with invalid data returns error changeset" do
      vote = insert(:vote)

      assert {:error, %Ecto.Changeset{}} =
               Polls.update_vote(vote, %{user_id: nil, option_id: nil})

      updated_vote = Polls.get_vote!(vote.id)
      assert vote.id == updated_vote.id
      assert vote.user_id == updated_vote.user_id
      assert vote.option_id == updated_vote.option_id
    end

    test "delete_vote/1 deletes the vote" do
      vote = insert(:vote)
      assert {:ok, %Vote{}} = Polls.delete_vote(vote)
      assert_raise Ecto.NoResultsError, fn -> Polls.get_vote!(vote.id) end
    end

    test "change_vote/1 returns a vote changeset" do
      vote = insert(:vote)
      assert %Ecto.Changeset{} = Polls.change_vote(vote)
    end
  end
end

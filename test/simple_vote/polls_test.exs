defmodule SimpleVote.PollsTest do
  alias SimpleVote.Polls

  import SimpleVote.Factory

  use SimpleVote.DataCase, async: true

  describe "poll pubsub utils" do
    @pubsub SimpleVote.PubSub

    test "subscribe/1 subscribes the current process" do
      Polls.subscribe("slug")

      Phoenix.PubSub.broadcast(@pubsub, Polls.make_topic("slug"), :hello)

      assert_received(:hello)
    end
  end

  setup do
    room = insert(:room)
    Polls.subscribe(room.id)
    %{room: room}
  end

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

    test "create_prompt/1 with valid data creates a prompt", %{room: room} do
      assert {:ok, %Prompt{} = prompt} =
               Polls.create_prompt(%{body: "some body", room_id: room.id})

      assert prompt.body == "some body"
      assert_received({:prompt_created, ^prompt})
    end

    test "create_prompt/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Polls.create_prompt(@invalid_attrs)
      refute_received({:prompt_updated, _})
    end

    test "update_prompt/2 with valid data updates the prompt", %{room: room} do
      prompt = insert(:prompt, room: room)
      assert {:ok, %Prompt{} = prompt} = Polls.update_prompt(prompt, @update_attrs)
      assert prompt.body == "some updated body"
      assert_received({:prompt_updated, ^prompt})
    end

    test "update_prompt/2 with invalid data returns error changeset" do
      prompt = insert(:prompt, options: [])
      assert {:error, %Ecto.Changeset{}} = Polls.update_prompt(prompt, @invalid_attrs)
      refute_received({:prompt_updated, _})

      assert prompt == Polls.get_prompt!(prompt.id)
    end

    test "delete_prompt/1 deletes the prompt", %{room: room} do
      prompt = insert(:prompt, room: room)
      assert {:ok, %Prompt{}} = Polls.delete_prompt(prompt)
      assert_received({:prompt_deleted, %Prompt{}})

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

    test "create_option_for_prompt/1 with valid data creates a option", %{room: room} do
      prompt = insert(:prompt, room: room)

      assert {:ok, %Option{} = option} = Polls.create_option_for_prompt(prompt, @valid_attrs)
      assert option.body == "some body"
      assert_received({:option_created, ^option})
    end

    test "create_option_for_prompt/1 with invalid data returns error changeset", %{room: room} do
      prompt = insert(:prompt, room: room)

      assert {:error, %Ecto.Changeset{}} = Polls.create_option_for_prompt(prompt, @invalid_attrs)
      refute_received({:option_created, _})
    end

    test "update_option/2 with valid data updates the option", %{room: room} do
      option = insert(:option, prompt: %{room: room})

      assert {:ok, %Option{} = option} = Polls.update_option(option, @update_attrs)
      assert option.body == "some updated body"
      assert_received({:option_updated, %Option{}})
    end

    test "update_option/2 with invalid data returns error changeset" do
      option = insert(:option)

      assert {:error, %Ecto.Changeset{}} = Polls.update_option(option, @invalid_attrs)
      assert option.id == Polls.get_option!(option.id).id
      refute_received({:option_updated, %Option{}})
    end

    test "delete_option/1 deletes the option", %{room: room} do
      option = insert(:option, prompt: %{room: room})

      assert {:ok, %Option{}} = Polls.delete_option(option)
      assert_received({:option_deleted, %Option{}})

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

    test "list_votes/0 returns all votes" do
      vote = insert(:vote)
      assert Polls.list_votes() |> length == 1
      assert Polls.list_votes() |> hd |> Map.get(:id) == vote.id
    end

    test "get_vote!/1 returns the vote with given id" do
      vote = insert(:vote)
      assert Polls.get_vote!(vote.id).id == vote.id
    end

    test "get_option_room_state/1 works" do
      room = insert(:room, state: :closed)
      prompt = insert(:prompt, room: room)
      option = insert(:option, prompt: prompt)

      assert {:ok, :closed} = Polls.get_option_room_state(option.id)
    end

    test "cast_vote/1 with valid data creates a vote when the room is open" do
      voter_user = insert(:user)

      room = insert(:room, state: :open)
      prompt = insert(:prompt, room: room)
      option = insert(:option, prompt: prompt)

      assert {:ok, %Vote{option_id: option_id, user_id: voter_user_id}} =
               Polls.cast_vote(voter_user.id, option.id)

      assert option_id == option.id
      assert voter_user_id == voter_user.id
    end

    test "cast_vote/1 with valid data fails when a vote is not open" do
      voter_user = insert(:user)

      room = insert(:room, state: :closed)
      prompt = insert(:prompt, room: room)
      option = insert(:option, prompt: prompt)

      assert {:error, :room_not_open} = Polls.cast_vote(voter_user.id, option.id)
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

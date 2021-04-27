defmodule SimpleVoteWeb.RoomLive.Vote do
  use SimpleVoteWeb, :live_view

  alias SimpleVote.Rooms
  alias SimpleVote.Rooms.RoomRegistry
  alias SimpleVote.Polls
  alias SimpleVote.Polls.{Prompt, Option}
  alias SimpleVote.Accounts.{User}

  @impl true
  def mount(%{"slug" => _slug}, _session, socket) do
    {:ok, socket}
  end
end

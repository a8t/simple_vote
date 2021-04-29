defmodule SimpleVoteWeb.Presence do
  use Phoenix.Presence,
    otp_app: :simple_vote,
    pubsub_server: SimpleVote.PubSub

  def fetch("room:" <> room_slug, presences) do
    presences
  end

  def fetch(_, presences) do
    presences
  end
end

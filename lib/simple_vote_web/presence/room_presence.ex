defmodule SimpleVoteWeb.Presence do
  use Phoenix.Presence,
    otp_app: :simple_vote,
    pubsub_server: SimpleVote.PubSub
end

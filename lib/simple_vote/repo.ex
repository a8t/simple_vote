defmodule SimpleVote.Repo do
  use Ecto.Repo,
    otp_app: :simple_vote,
    adapter: Ecto.Adapters.Postgres
end

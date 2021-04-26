defmodule SimpleVote.Polls.Vote do
  use Ecto.Schema
  import Ecto.Changeset

  schema "votes" do
    belongs_to :user, SimpleVote.Accounts.User
    belongs_to :option, SimpleVote.Polls.Option

    timestamps()
  end

  @doc false
  def changeset(vote, attrs) do
    vote
    |> cast(attrs, [:option_id, :user_id])
    |> validate_required([:option_id, :user_id])
  end
end

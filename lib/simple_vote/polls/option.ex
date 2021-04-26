defmodule SimpleVote.Polls.Option do
  use Ecto.Schema
  import Ecto.Changeset

  schema "options" do
    field :body, :string
    belongs_to :prompt, SimpleVote.Polls.Prompt
    has_many :votes, SimpleVote.Polls.Vote

    timestamps()
  end

  @doc false
  def changeset(option, attrs) do
    option
    |> cast(attrs, [:body])
    |> validate_required([:body])
  end
end

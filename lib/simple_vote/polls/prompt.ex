defmodule SimpleVote.Polls.Prompt do
  use Ecto.Schema
  import Ecto.Changeset

  schema "prompts" do
    field :body, :string
    has_many :options, SimpleVote.Polls.Option
    belongs_to :room, SimpleVote.Rooms.Room

    timestamps()
  end

  @doc false
  def changeset(prompt, attrs) do
    prompt
    |> cast(attrs, [:body, :room_id])
    |> validate_required([:body, :room_id])
  end
end

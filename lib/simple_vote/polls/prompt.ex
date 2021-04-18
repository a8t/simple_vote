defmodule SimpleVote.Polls.Prompt do
  use Ecto.Schema
  import Ecto.Changeset

  schema "prompts" do
    field :body, :string
    has_many :options, SimpleVote.Polls.Option

    timestamps()
  end

  @doc false
  def changeset(prompt, attrs) do
    prompt
    |> cast(attrs, [:body])
    |> validate_required([:body])
  end
end

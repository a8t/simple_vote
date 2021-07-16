defmodule SimpleVote.Rooms.Room do
  use Ecto.Schema
  import Ecto.Changeset

  schema "rooms" do
    field :name, :string
    field :state, Ecto.Enum, values: [:open, :closed]
    has_many :prompts, SimpleVote.Polls.Prompt
    belongs_to :owner, SimpleVote.Accounts.User, foreign_key: :owner_id

    timestamps()
  end

  @doc false
  def changeset(room, attrs) do
    room
    |> cast(attrs, [:name, :owner_id, :state])
    |> validate_required([:name, :owner_id])
  end

  defimpl Phoenix.Param, for: SimpleVote.Rooms.Room do
    def to_param(%{id: id}) do
      slug = SimpleVote.Rooms.RoomRegistry.get_room_slug(id)

      slug
    end
  end
end

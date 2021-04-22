defmodule SimpleVote.Rooms.Room do
  use Ecto.Schema
  import Ecto.Changeset

  schema "rooms" do
    field :name, :string
    has_many :prompts, SimpleVote.Polls.Prompt

    timestamps()
  end

  @doc false
  def changeset(room, attrs) do
    room
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end

  defimpl Phoenix.Param, for: SimpleVote.Rooms.Room do
    def to_param(%{id: id}) do
      slug = SimpleVote.Rooms.RoomRegistry.get_room_slug(id)

      slug
    end
  end
end

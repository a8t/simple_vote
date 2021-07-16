defmodule SimpleVote.Repo.Migrations.AddRoomState do
  use Ecto.Migration

  def change do
    create_query = "CREATE TYPE room_state AS ENUM ('open', 'closed')"
    drop_query = "DROP TYPE room_state"
    execute(create_query, drop_query)

    alter table(:rooms) do
      add :state, :room_state
    end
  end
end

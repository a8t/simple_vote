defmodule SimpleVote.Repo.Migrations.AddRoomCreator do
  use Ecto.Migration

  def change do

    alter table(:rooms) do
      add :owner_id, references(:users)
    end

    create index(:rooms, [:owner_id])
  end
end

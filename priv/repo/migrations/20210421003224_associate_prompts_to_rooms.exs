defmodule SimpleVote.Repo.Migrations.AssociatePromptsToRooms do
  use Ecto.Migration

  def change do
    alter table(:prompts) do
      add :room_id, references(:rooms, on_delete: :delete_all)
    end

    create index(:prompts, [:room_id])
  end
end

defmodule SimpleVote.Repo.Migrations.CreateVotes do
  use Ecto.Migration

  def change do
    create table(:votes) do
      add :user_id, references(:users, on_delete: :delete_all)
      add :option_id, references(:options, on_delete: :delete_all)

      timestamps()
    end

    create index(:votes, [:user_id])
    create index(:votes, [:option_id])
  end
end

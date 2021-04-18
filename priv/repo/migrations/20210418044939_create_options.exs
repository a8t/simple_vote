defmodule SimpleVote.Repo.Migrations.CreateOptions do
  use Ecto.Migration

  def change do
    create table(:options) do
      add :body, :text
      add :prompt_id, references(:prompts, on_delete: :delete_all)

      timestamps()
    end

    create index(:options, [:prompt_id])
  end
end

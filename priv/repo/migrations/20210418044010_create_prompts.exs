defmodule SimpleVote.Repo.Migrations.CreatePrompts do
  use Ecto.Migration

  def change do
    create table(:prompts) do
      add :body, :text

      timestamps()
    end

  end
end

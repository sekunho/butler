defmodule Butler.Repo.Migrations.UpdateTodosTable do
  use Ecto.Migration

  def change do
    alter table(:todos) do
      add :user_id, references(:users, type: :binary_id)
    end
  end
end

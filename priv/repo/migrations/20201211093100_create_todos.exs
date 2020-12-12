defmodule Butler.Repo.Migrations.CreateTodos do
  use Ecto.Migration

  def change do
    create table(:todos, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string
      add :start, :utc_datetime
      add :duration, :integer
      add :priority, :string

      timestamps()
    end

  end
end

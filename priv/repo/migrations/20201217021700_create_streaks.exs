defmodule Butler.Repo.Migrations.CreateStreaks do
  use Ecto.Migration

  def change do
    create table(:streaks, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :from, :time
      add :to, :time

      timestamps()
    end

    alter table(:days) do
      add :streaks, references(:days, type: :binary_id)
    end

  end
end

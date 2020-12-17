defmodule Butler.Repo.Migrations.CreateDays do
  use Ecto.Migration

  def change do
    create table(:days, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :date, :utc_datetime

      timestamps()
    end

  end
end

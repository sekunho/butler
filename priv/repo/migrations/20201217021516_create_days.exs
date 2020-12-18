defmodule Butler.Repo.Migrations.CreateDays do
  use Ecto.Migration

  def change do
    execute("CREATE EXTENSION IF NOT EXISTS \"pgcrypto\";")

    create table(:days, primary_key: false) do
      add :id, :binary_id, primary_key: true, default: fragment("gen_random_uuid()")
      add :date, :utc_datetime

      add :user_id, references(:users, type: :binary_id)

      timestamps()
    end

    create unique_index(:days, [:user_id, :date], name: :user_id_date)
  end
end

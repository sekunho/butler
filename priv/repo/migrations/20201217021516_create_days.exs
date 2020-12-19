defmodule Butler.Repo.Migrations.CreateDays do
  use Ecto.Migration

  def up do
    execute("CREATE EXTENSION IF NOT EXISTS \"pgcrypto\";")

    create table(:days, primary_key: false) do
      add :id, :binary_id, primary_key: true, default: fragment("gen_random_uuid()")
      add :date, :utc_datetime
      add :selected_slots, {:array, :integer}

      add :user_id, references(:users, type: :binary_id)

      timestamps()
    end

    create unique_index(:days, [:user_id, :date], name: :user_id_date)
  end

  def down do
    drop table(:days)

    execute("DROP EXTENSION IF EXISTS \"pgcrypto\";")
  end
end

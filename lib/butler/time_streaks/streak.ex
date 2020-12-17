defmodule Butler.TimeStreaks.Streak do
  use Ecto.Schema
  import Ecto.Changeset

  alias Butler.DaySchedules.Day

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "streaks" do
    field :from, :time
    field :to, :time

    belongs_to :day, Day, foreign_key: :day_id, type: :binary_id

    timestamps()
  end

  @doc false
  def changeset(streak, attrs) do
    streak
    |> cast(attrs, [:from, :to, :day_id])
    |> validate_required([:from, :to])
  end
end

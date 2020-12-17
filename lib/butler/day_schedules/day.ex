defmodule Butler.DaySchedules.Day do
  use Ecto.Schema
  import Ecto.Changeset

  alias Butler.TimeStreaks.Streak

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "days" do
    field :date, :utc_datetime

    has_many :streaks, Streak

    timestamps()
  end

  @doc false
  def changeset(day, attrs) do
    day
    |> cast(attrs, [:date])
    |> validate_required([:date])
  end
end

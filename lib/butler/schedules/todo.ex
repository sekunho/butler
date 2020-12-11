defmodule Butler.Schedules.Todo do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "todos" do
    field :duration, :integer
    field :name, :string
    field :priority, Ecto.Enum, values: [:none, :low, :medium, :high]
    field :start, :utc_datetime

    timestamps()
  end

  @doc false
  def changeset(todo, attrs) do
    todo
    |> cast(attrs, [:name, :start, :duration, :priority])
    |> validate_required([:name, :start, :duration, :priority])
  end
end

defmodule Butler.Schedules.Todo do
  use Ecto.Schema
  import Ecto.Changeset

  alias Butler.Accounts.User

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "todos" do
    field :duration, :integer
    field :name, :string
    field :priority, Ecto.Enum, values: [:none, :low, :medium, :high]
    field :start, :utc_datetime

    belongs_to :user, User, foreign_key: :user_id, type: :binary_id

    timestamps()
  end

  @doc false
  @min_duration 15
  def changeset(todo, attrs) do
    todo
    |> cast(attrs, [:name, :start, :duration, :priority, :user_id])
    |> validate_required([:name, :duration, :priority, :user_id])
    |> validate_number(:duration, greater_than_or_equal_to: @min_duration)
  end
end

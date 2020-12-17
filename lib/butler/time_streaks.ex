defmodule Butler.TimeStreaks do
  @moduledoc """
  The TimeStreaks context.
  """

  import Ecto.Query, warn: false
  alias Butler.Repo

  alias Butler.TimeStreaks.Streak

  @type t() :: %__MODULE__{
    from: Time.t(),
    to: Time.t()
  }

  @enforce_keys [:from, :to]
  defstruct [:from, :to]

  @doc """
  Returns the list of streaks.

  ## Examples

      iex> list_streaks()
      [%Streak{}, ...]

  """
  def list_streaks do
    Repo.all(Streak)
  end

  @doc """
  Gets a single streak.

  Raises `Ecto.NoResultsError` if the Streak does not exist.

  ## Examples

      iex> get_streak!(123)
      %Streak{}

      iex> get_streak!(456)
      ** (Ecto.NoResultsError)

  """
  def get_streak!(id), do: Repo.get!(Streak, id)

  @doc """
  Creates a streak.

  ## Examples

      iex> create_streak(%{field: value})
      {:ok, %Streak{}}

      iex> create_streak(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_streak(attrs \\ %{}) do
    %Streak{}
    |> Streak.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a streak.

  ## Examples

      iex> update_streak(streak, %{field: new_value})
      {:ok, %Streak{}}

      iex> update_streak(streak, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_streak(%Streak{} = streak, attrs) do
    streak
    |> Streak.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a streak.

  ## Examples

      iex> delete_streak(streak)
      {:ok, %Streak{}}

      iex> delete_streak(streak)
      {:error, %Ecto.Changeset{}}

  """
  def delete_streak(%Streak{} = streak) do
    Repo.delete(streak)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking streak changes.

  ## Examples

      iex> change_streak(streak)
      %Ecto.Changeset{data: %Streak{}}

  """
  def change_streak(%Streak{} = streak, attrs \\ %{}) do
    Streak.changeset(streak, attrs)
  end

  def from_unparsed_slots(unparsed_slots) when is_list(unparsed_slots) do
    # TODO: Remove duplicate values
    # TODO: Ensure time is always in :15, :30, :00
    # Group slots according to common date
    grouped_slots =
      Enum.reduce(unparsed_slots, %{}, fn
        %{"day" => date, "slot" => time}, acc ->
          {:ok, date} =
            [date, "T", "00:00:00+00:00"]
            |> IO.iodata_to_binary()
            |> Timex.parse("{ISO:Extended}")

          {:ok, time} = Time.from_iso8601(time)

          Map.update(acc, date, [time], fn slots ->
            [time | slots]
          end )
      end)
      |> Enum.into([])


    Enum.reduce(grouped_slots, %{}, fn {day, slots}, acc ->
      streaks = slots_to_streak(slots)

      Map.put_new(acc, day, streaks)
    end)
  end

  @max_interval 30.0
  def slots_to_streak(slots) when is_list(slots) do
    sorted_slots = Enum.sort(slots, &Timex.before?/2)

    Enum.reduce(sorted_slots, [], fn
      slot_b, [] ->
        [%__MODULE__{from: slot_b, to: slot_b}]

      slot_b, [%__MODULE__{to: to} = prev_streak | other_streaks] = streaks ->
        if Time.diff(slot_b, to, :second) / 60 <= @max_interval do
          [Map.put(prev_streak, :to, slot_b) | other_streaks]
        else
          [%__MODULE__{from: slot_b, to: slot_b} | streaks]
        end
    end)
    |> Enum.reverse()
  end
end

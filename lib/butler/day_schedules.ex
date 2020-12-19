defmodule Butler.DaySchedules do
  @moduledoc """
  The DaySchedules context.
  """

  import Ecto.Query, warn: false

  alias Butler.Repo
  alias Butler.DaySchedules.Day
  alias Ecto.Multi

  @doc """
  Returns the list of days.

  ## Examples

      iex> list_days()
      [%Day{}, ...]

  """
  def list_days(user_id, from_date, to_date) do
    query =
      from d in Day,
      where: d.date >= ^from_date and d.date <= ^to_date,
      where: d.user_id == ^user_id

    Repo.all(query)
  end

  @doc """
  Gets a single day.

  Raises `Ecto.NoResultsError` if the Day does not exist.

  ## Examples

      iex> get_day!(123)
      %Day{}

      iex> get_day!(456)
      ** (Ecto.NoResultsError)

  """
  def get_day!(id), do: Repo.get!(Day, id)

  @doc """
  Creates a day.

  ## Examples

      iex> create_day(%{field: value})
      {:ok, %Day{}}

      iex> create_day(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_day(attrs \\ %{}) do
    %Day{}
    |> Day.changeset(attrs)
    |> Repo.insert(on_conflict: :nothing, returning: true)
  end

  @doc """
  Creates a list of day with slots.

  ## Examples

      iex> create_day([])
      {:ok, %Day{}}

      iex> create_day(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_days_with_slots(dates) when is_list(dates) do
    opts = [
      returning: true,
      conflict_target: [:user_id, :date]
    ]

    dates
    |> Enum.with_index()
    |> Enum.reduce(Multi.new(), fn
      {date, index}, multi ->
        date_cs = change_day(%Day{}, date)
        selected_slots = Ecto.Changeset.get_change(date_cs, :selected_slots)

        # If date already exists then only `selected_slots` has to be updated.
        date_on_conflict = {:on_conflict, [set: [selected_slots: selected_slots]]}
        date_opts = [ date_on_conflict | opts]

        Multi.insert(multi, index, date_cs, date_opts)
    end)
    |> Repo.transaction()
    |> IO.inspect()
  end

  @doc """
  Updates a day.

  ## Examples

      iex> update_day(day, %{field: new_value})
      {:ok, %Day{}}

      iex> update_day(day, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_day(%Day{} = day, attrs) do
    day
    |> Day.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a day.

  ## Examples

      iex> delete_day(day)
      {:ok, %Day{}}

      iex> delete_day(day)
      {:error, %Ecto.Changeset{}}

  """
  def delete_day(%Day{} = day) do
    Repo.delete(day)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking day changes.

  ## Examples

      iex> change_day(day)
      %Ecto.Changeset{data: %Day{}}

  """
  def change_day(%Day{} = day, attrs \\ %{}) do
    Day.changeset(day, attrs)
  end
end

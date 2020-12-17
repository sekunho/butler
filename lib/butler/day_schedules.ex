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
  def list_days do
    Repo.all(Day)
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
    |> Repo.insert(on_conflict: :nothing, conflict_target: [:user_id, :date], returning: true)
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

  # defp get_or_insert_tag(name) do
  #   Repo.get_by(MyApp.Tag, name: name) ||
  #     maybe_insert_tag(name)
  # end

  # defp maybe_insert_tag(name) do
  #   %Tag{}
  #   |> Ecto.Changeset.change(name: name)
  #   |> Ecto.Changeset.unique_constraint(:name)
  #   |> Repo.insert
  #   |> case do
  #     {:ok, tag} -> tag
  #     {:error, _} -> Repo.get_by!(MyApp.Tag, name: name)
  #   end
  # end
end

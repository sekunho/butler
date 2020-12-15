defmodule Butler.Scheduler do
  def run(todos) do
    # TODO: Remove when selecting available slots is implemented.
    time_streaks = Scheduler.time_streaks()
    time_streak_durations = Core.TimeStreak.get_durations(time_streaks, :matrix)
    todo_durations = Core.Todo.to_duration_matrix(todos)
    todo_priorities = Core.Todo.to_priority_matrix(todos)

    # Data to be accessed by the GA
    # TODO: Remove unnecessary data
    data = %{
      todo_ids: Enum.map(Enum.with_index(todos, 1), fn {_, index} -> index end),
      todos: todos,
      todo_size: length(todos),
      ts_size: length(time_streaks),
      time_streaks: time_streaks,
      time_streak_durations: time_streak_durations,
      durations: todo_durations,
      priorities: todo_priorities,
    }

    opts = [
      population_size: 100,
      # reinsertion_type: &Toolbox.Reinsertion.elitist/4,
      # selection_type: &Toolbox.Selection.unique_tournament/4,
      tournament_size: 5
    ]
    soln = Genetic.run(TTP, data, opts)

    IO.write("\n===========> BEST SOLUTION\n")
    IO.write("-----------> Fitness: #{soln.fitness}\n")
    IO.write("-----------> Genes\n")

    soln.genes
    |> IO.inspect()
    |> Matrex.to_list_of_lists()
    |> IO.inspect()
    |> Core.Timetable.sort_todos(todos)
    |> Core.Timetable.from_bit_timetable()
    # |> Core.Timetable.sort_todos(todos)
    |> IO.inspect()
    |> Core.Timetable.print(todos, time_streaks)
  end
end

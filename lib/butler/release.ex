defmodule Butler.Release do
  @app :butler

  # Running migrations in production would look like this:
  # > _build/prod/rel/butler/bin/butler eval "Butler.Release.migrate"
  def migrate do
    load_app()

    for repo <- repos() do
      {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :up, all: true))
    end
  end

  def rollback(repo, version) do
    load_app()
    {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :down, to: version))
  end

  defp repos do
    Application.fetch_env!(@app, :ecto_repos)
  end

  defp load_app do
    Application.load(@app)

    # Without this, Phoenix will throw an error about having to add `:ssl` to
    # `extra_applications`. Doing so won't do anything, because the error is
    # unrelated.
    # https://elixirforum.com/t/ssl-connection-cannot-be-established-using-elixir-releases/25444/12
    Application.ensure_all_started(:ssl)
  end
end

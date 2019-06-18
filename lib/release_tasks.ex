defmodule Lucidboard.ReleaseTasks do
  @moduledoc "Tasks related to Distillery releases"
  def migrate do
    {:ok, _} = Application.ensure_all_started(:lucidboard)

    path = Application.app_dir(:lucidboard, "priv/repo/migrations")

    Ecto.Migrator.run(Lucidboard.Repo, path, :up, all: true)
  end
end
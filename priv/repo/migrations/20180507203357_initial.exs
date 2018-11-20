defmodule Lb2.Repo.Migrations.Initial do
  @moduledoc false
  use Ecto.Migration

  def change do
    create table("boards") do
      add :name, :string
      add :columns, {:array, :jsonb}, default: []

      timestamps()
    end
end

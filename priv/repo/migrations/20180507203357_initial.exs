defmodule Lb2.Repo.Migrations.Initial do
  use Ecto.Migration

  def change do
    create table("boards") do
      add :title, :string
      add :columns, {:array, :jsonb}, default: []

      timestamps()
    end
  end
end

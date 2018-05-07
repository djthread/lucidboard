defmodule Lb2.Repo.Migrations.Initial do
  use Ecto.Migration

  def change do
    create table("boards") do
      add :name, :string
      add :columns, {:array, :integer}

      timestamps()
    end

    create table("columns") do
      add :name, :string
      add :cards, {:array, :integer}

      timestamps()
    end

    create table("cards") do
      add :content, :text
    end
  end
end

defmodule Lb2.Repo.Migrations.Initial do
  use Ecto.Migration

  def change do
    create table("boards") do
      add :name, :string, null: false
      add :columns, {:array, :integer}, null: false

      timestamps()
    end

    create table("columns") do
      add :name, :string, null: false
      add :cards, {:array, :integer}, null: false

      timestamps()
    end

    create table("cards") do
      add :content, :text, null: false

      timestamps()
    end
  end
end

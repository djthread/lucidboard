defmodule Lb2.Repo.Migrations.Initial do
  use Ecto.Migration

  def change do
    create table("boards") do
      add :title, :string, null: false
      add :settings, :jsonb

      timestamps()
    end

    create table("columns") do
      add :title, :string, null: false
      add :pos, :integer, null: false
      add :board_id, references(:boards)
    end

    create table("piles") do
      add :column_id, references(:columns)
      add :pos, :integer, null: false
    end

    create table("cards") do
      add :pile_id, references(:piles)
      add :pos, :integer, null: false
      add :body, :string, null: false
    end
  end
end

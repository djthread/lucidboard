defmodule Lucidboard.Repo.Migrations.Initial do
  @moduledoc false
  use Ecto.Migration

  def change do
    create table("users") do
      add(:name, :string, null: false)
      add(:settings, :jsonb, null: false, default: "{}")

      timestamps()
    end

    create table("boards") do
      add(:title, :string, null: false)
      add(:settings, :jsonb, null: false, default: "{}")

      timestamps()
    end

    create table("columns") do
      add(:title, :string, null: false)
      add(:pos, :integer, null: false)
      add(:board_id, references(:boards))

      timestamps()
    end

    create table("piles") do
      add(:column_id, references(:columns))
      add(:pos, :integer, null: false)

      timestamps()
    end

    create table("cards") do
      add(:pile_id, references(:piles))
      add(:pos, :integer, null: false)
      add(:body, :string, null: false)
      add(:settings, :jsonb, null: false, default: "{}")

      timestamps()
    end
  end
end

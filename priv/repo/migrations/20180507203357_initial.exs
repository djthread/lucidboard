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
      add(:user_id, references(:users))

      timestamps()
    end

    create table("columns", primary_key: false) do
      add(:id, :uuid, primary_key: true)
      add(:title, :string, null: false)
      add(:pos, :integer, null: false)
      add(:board_id, references(:boards))
    end

    create table("piles", primary_key: false) do
      add(:id, :uuid, primary_key: true)
      add(:pos, :integer, null: false)
      add(:column_id, references(:columns, type: :uuid))
    end

    create table("cards", primary_key: false) do
      add(:id, :uuid, primary_key: true)
      add(:pos, :integer, null: false)
      add(:body, :string, null: false)
      add(:locked, :boolean, default: false)
      add(:settings, :jsonb, null: false, default: "{}")
      add(:pile_id, references(:piles, type: :uuid))
      add(:user_id, references(:users))
    end
  end
end

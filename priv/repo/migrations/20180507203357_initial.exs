defmodule Lucidboard.Repo.Migrations.Initial do
  @moduledoc false
  use Ecto.Migration

  def change do
    create table(:users) do
      add(:name, :string, null: false)
      add(:settings, :jsonb, null: false, default: "{}")

      timestamps()
    end

    create(unique_index(:users, :name))

    create table(:boards) do
      add(:title, :string, null: false)
      add(:settings, :jsonb, null: false, default: "{}")
      add(:user_id, references(:users), null: false)

      timestamps()
    end

    create table(:columns, primary_key: false) do
      add(:id, :uuid, primary_key: true)
      add(:title, :string, null: false)
      add(:pos, :integer, null: false)
      add(:board_id, references(:boards), null: false)
    end

    create table(:piles, primary_key: false) do
      add(:id, :uuid, primary_key: true)
      add(:pos, :integer, null: false)
      add(:column_id, references(:columns, type: :uuid), null: false)
    end

    create table(:cards, primary_key: false) do
      add(:id, :uuid, primary_key: true)
      add(:pos, :integer, null: false)
      add(:body, :string, null: false)
      add(:locked, :boolean, null: false, default: false)
      add(:settings, :jsonb, null: false, default: "{}")
      add(:pile_id, references(:piles, type: :uuid), null: false)
      add(:user_id, references(:users), null: false)
    end

    create table(:likes, primary_key: false) do
      add(:id, :uuid, primary_key: true)
      # add(:count, :integer, default: 1, null: false)
      add(:user_id, references(:users), null: false)
      add(:card_id, references(:cards, type: :uuid), null: false)
    end
  end
end

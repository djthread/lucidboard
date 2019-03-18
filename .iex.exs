import Ecto.Query
alias Ecto.{Changeset, UUID}
alias Lucidboard.{
  Board,
  BoardSettings,
  Column,
  Card,
  Event,
  Like,
  Pile,
  User,
  UserSettings,
  CardSettings
}

alias Lucidboard.LiveBoard, as: Liveboard
alias Lucidboard.Repo, as: Repo
alias Lucidboard.Twiddler, as: Twiddler


defmodule L do
  def go do
    Lucidboard.LiveBoard.start 1
  end
end
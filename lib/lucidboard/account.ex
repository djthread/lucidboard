defmodule Lucidboard.Account do
  @moduledoc "Context for user things"
  import Ecto.Query
  alias Ecto.Changeset
  alias Lucidboard.Account.Github
  alias Lucidboard.{Board, BoardRole, Repo, User}
  alias Ueberauth.Auth
  require Logger

  @providers %{
    github: Github
  }

  def get!(user_id) do
    Repo.get!(User, user_id)
  end

  def get(user_id) do
    Repo.get(User, user_id)
  end

  @spec has_role?(User.t(), Board.t(), atom) :: boolean
  def has_role?(%User{id: user_id}, %Board{board_roles: roles}, role) do
    Enum.any?(roles, fn
      %{user_id: ^user_id, role: ^role} -> true
      _ -> false
    end)
  end

  @spec suggest_users(String.t()) :: [User.t()]
  def suggest_users(query) do
    q = "%#{query}%"

    Repo.all(
      from(u in User, where: ilike(u.name, ^q) or ilike(u.full_name, ^q))
    )
  end

  @spec grant(integer, integer, atom) :: :ok | :error
  def grant(user_id, board_id, role) do
    with %User{id: user_id} <- Repo.get(User, user_id),
         %Board{id: board_id} = board <-
           Board |> Repo.get(board_id) |> Repo.preload(:board_roles),
         new_role <-
           BoardRole.new(user_id: user_id, board_id: board_id, role: role),
         {:ok, _} <-
           board
           |> Board.changeset()
           |> Changeset.put_assoc(:board_roles, [new_role | board.board_roles])
           |> Repo.update() do
      :ok
    else
      _ -> :error
    end
  end

  @spec revoke(integer, integer) :: :ok
  def revoke(user_id, board_id) do
    Repo.delete_all(
      from(r in BoardRole,
        where: r.user_id == ^user_id and r.board_id == ^board_id
      )
    )

    :ok
  end

  @doc """
  Given the `%Ueberauth.Auth{}` result, get a loaded user from the db.

  If one does not exist, it will be created.
  """
  @spec auth_to_user(Auth.t()) :: {:ok, User.t()} | {:error, String.t()}
  def auth_to_user(auth) do
    with {:ok, user} <- apply(@providers[auth.provider], :to_user, [auth]) do
      case Repo.one(from(u in User, where: u.name == ^user.name)) do
        nil -> Repo.insert(user)
        db_user -> {:ok, db_user}
      end
    end
  end
end

defmodule Lucidboard.Account do
  @moduledoc "Context for user things"
  import Ecto.Query
  alias Ecto.Changeset
  alias Lucidboard.Account.{Github, PingFed}
  alias Lucidboard.{Board, BoardRole, BoardSettings, Card, Repo, User}
  alias Ueberauth.Auth
  require Logger

  @providers %{
    github: Github,
    pingfed: PingFed
  }

  def get!(user_id), do: Repo.get!(User, user_id)

  def get(user_id), do: Repo.get(User, user_id)

  def by_username(username) do
    Repo.one(from(u in User, where: u.name == ^username))
  end

  def create(fields) do
    fields |> User.new() |> insert()
  end

  def insert(%User{} = user) do
    Repo.insert(user)
  end

  def display_name(%User{name: name, full_name: full_name}) do
    "#{name} (#{full_name})"
  end

  @spec has_role?(User.t(), Board.t(), atom) :: boolean
  def has_role?(user, board, role \\ :owner)

  def has_role?(_user, %Board{settings: %BoardSettings{access: "open"}}, role)
      when role in [:observer, :contributor] do
    true
  end

  def has_role?(
        _user,
        %Board{settings: %BoardSettings{access: "public"}},
        :observer
      ) do
    true
  end

  def has_role?(%User{admin: true}, _board, _role) do
    true
  end

  def has_role?(%User{id: user_id}, %Board{board_roles: roles}, role) do
    Enum.any?(roles, fn
      %{user_id: ^user_id, role: :owner} ->
        true

      %{user_id: ^user_id, role: :contributor} ->
        role in [:contributor, :observer]

      %{user_id: ^user_id, role: :observer} ->
        role == :observer

      _ ->
        false
    end)
  end

  @spec card_is_editable?(Card.t(), User.t(), Board.t()) :: boolean
  def card_is_editable?(card, user, board)

  def card_is_editable?(_, %User{admin: true}, _), do: true

  def card_is_editable?(%Card{user: %User{id: user_id}}, %User{id: user_id}, _),
    do: true

  def card_is_editable?(_, %User{id: user_id}, %Board{board_roles: board_roles}) do
    Enum.any?(board_roles, fn %{user: %{id: uid}, role: :owner} ->
      uid == user_id
    end)
  end

  @spec suggest_users(String.t(), User.t()) :: [User.t()]
  def suggest_users(query, %User{id: user_id}) do
    q = "%#{query}%"

    Repo.all(
      from(u in User,
        where:
          (ilike(u.name, ^q) or ilike(u.full_name, ^q)) and u.id != ^user_id,
        order_by: [asc: u.name]

      )
    )
  end

  @spec grant(integer, BoardRole.t()) :: :ok | {:error, Changeset.t()}
  def grant(board_id, board_role) do
    with %Board{} = board <-
           Board |> Repo.get(board_id) |> Repo.preload(:board_roles),
         {:ok, _} <-
           board
           |> Board.changeset()
           |> Changeset.put_assoc(:board_roles, [board_role | board.board_roles])
           |> Repo.update() do
      :ok
    else
      {:error, error} -> {:error, error}
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

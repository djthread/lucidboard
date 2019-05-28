defmodule Lucidboard.Account do
  @moduledoc "Context for user things"
  import Ecto.Query
  alias Lucidboard.Account.Github
  alias Lucidboard.{Repo, User}
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

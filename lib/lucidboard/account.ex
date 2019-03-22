defmodule Lucidboard.Account do
  @moduledoc "Context for user things"
  alias Lucidboard.{Repo, User}

  def get_user(user_id) do
    Repo.get(User, user_id)
  end
end

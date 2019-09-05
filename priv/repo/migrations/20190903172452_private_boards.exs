defmodule Lucidboard.Repo.Migrations.PrivateBoards do
  use Ecto.Migration
  import Ecto.Adapters.SQL, only: [query!: 3]
  alias Lucidboard.Repo

  def up do
    # All existing boards have been and will remain open (0).
    query!(
      Repo,
      "UPDATE boards SET settings = jsonb_set(settings, '{access}', '\"open\"')",
      []
    )
  end
end

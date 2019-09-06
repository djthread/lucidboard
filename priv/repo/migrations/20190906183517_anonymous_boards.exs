defmodule Lucidboard.Repo.Migrations.AnonymousBoards do
  use Ecto.Migration
  import Ecto.Adapters.SQL, only: [query!: 3]
  alias Lucidboard.Repo

  def up do
    query!(
      Repo,
      "UPDATE boards SET settings = jsonb_set(settings, '{anonymous}', 'true')",
      []
    )
  end
end

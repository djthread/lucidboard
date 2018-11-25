defmodule Lb2.Board.Card do
  @moduledoc "Schema for a board record"
  use Ecto.Schema
  import Ecto.Changeset

  # @primary_key {:id, :binary_id, autogenerate: false}
  @primary_key false

  embedded_schema do
    field(:id, :binary)
    field(:body, :string)
  end

  def create(params) do
    uuid = [id: Ecto.UUID.generate()]
    struct(__MODULE__, uuid ++ params)
  end

  @doc false
  def changeset(card, attrs) do
    card
    |> cast(attrs, [:body])
    |> validate_required([:body])
  end
end

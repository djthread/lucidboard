defmodule Lb2.LiveBoard.Instance do
  @moduledoc """
  GenServer for a live board
  """
  use GenServer
  alias Lb2.Board, as: B

  @registry Lb2.BoardRegistry

  def start_link(id) do
    name = {:via, Registry, {@registry, id}}
    GenServer.start_link(__MODULE__, id, name: name)
  end

  @impl true
  def init(id) do
    case B.by_id(id) do
      nil -> {:stop, :not_found}
      board -> {:ok, board}
    end
  end
end
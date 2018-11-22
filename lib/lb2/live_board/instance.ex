defmodule Lb2.LiveBoard.Instance do
  @moduledoc """
  GenServer for a live board
  """
  use GenServer
  alias Lb2.Board, as: B
  alias Lb2.Board.Board

  @registry Lb2.BoardRegistry

  def start_link(id) do
    name = {:via, Registry, {@registry, id}}
    GenServer.start_link(__MODULE__, id, name: name)
  end

  @impl true
  def init(id) do
    case B.by_id(id) do
      %Board{} = board -> {:ok, board}
      nil -> {:stop, :not_found}
    end
  end
end
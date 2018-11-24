defmodule Lb2.LiveBoard.Event do
  @moduledoc """
  An event queued, executing, or executed on a board
  """

  defstruct [:action, :params]

  @type t :: %__MODULE__{
          action: atom,
          params: keyword
        }
end

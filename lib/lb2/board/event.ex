defmodule Lb2.Board.Event do
  @moduledoc """
  An event queued, executing, or executed on a board

  * `:action` - Atom identifying the action
  * `:args` - Keyword list of parameters
  """

  defstruct [:action, :args, :error]

  @type t :: %__MODULE__{
          action: atom,
          args: keyword
        }
end

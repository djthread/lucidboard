defmodule Lb2.Board.Action do
  @moduledoc """
  A change a user is trying to make to a LiveBoard

  * `:name` - Atom identifying the action
  * `:args` - Keyword list of parameters
  """

  defstruct [:name, :args]

  @type t :: %__MODULE__{
          name: atom,
          args: keyword
        }
end

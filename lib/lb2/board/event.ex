defmodule Lb2.Board.Event do
  @moduledoc """
  Something that has occurred on a LiveBoard

  * `:name` - Atom identifying the action
  * `:desc` - String explaining what happened
  """

  defstruct [:name, :desc]

  @type t :: %__MODULE__{
          name: atom,
          desc: String.t()
        }
end

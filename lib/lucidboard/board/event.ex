defmodule Lucidboard.Board.Event do
  @moduledoc """
  Something that has occurred on a Lucidboard

  * `:desc` - String explaining what happened
  """

  defstruct [:desc]

  @type t :: %__MODULE__{
          desc: String.t()
        }
end

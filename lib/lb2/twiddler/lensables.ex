# defmodule Lb2.BoardScope do
#   @moduledoc "Helper for managing %Board{} data"
#   import Lens
#   deflenses(title: "", columns: [])
# end

# defmodule Lb2.ColumnScope do
#   @moduledoc "Helper for managing %Column{} data"
#   import Lens
#   deflenses(title: "", piles: [])
# end

# defmodule Lb2.PileScope do
#   @moduledoc "Helper for managing %Pile{} data"
#   import Lens
#   deflenses(cards: [])
# end

defimpl Lensable, for: Lb2.Board.Board do
  def getter(s, x), do: Map.get(s, x, {:error, {:lens, :bad_path}})
  def setter({:error, {:lens, :bad_path}} = e), do: e

  def setter(s, x, f) do
    if Map.has_key?(s, x), do: Map.put(s, x, f), else: s
  end
end

defimpl Lensable, for: Lb2.Board.Column do
  def getter(s, x), do: Map.get(s, x, {:error, {:lens, :bad_path}})
  def setter({:error, {:lens, :bad_path}} = e), do: e

  def setter(s, x, f) do
    if Map.has_key?(s, x), do: Map.put(s, x, f), else: s
  end
end

defimpl Lensable, for: Lb2.Board.Pile do
  def getter(s, x), do: Map.get(s, x, {:error, {:lens, :bad_path}})
  def setter({:error, {:lens, :bad_path}} = e), do: e

  def setter(s, x, f) do
    if Map.has_key?(s, x), do: Map.put(s, x, f), else: s
  end
end

defimpl Lensable, for: Lb2.Board.Card do
  def getter(s, x), do: Map.get(s, x, {:error, {:lens, :bad_path}})
  def setter({:error, {:lens, :bad_path}} = e), do: e

  def setter(s, x, f) do
    if Map.has_key?(s, x), do: Map.put(s, x, f), else: s
  end
end

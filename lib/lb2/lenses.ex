defmodule Lb2.BoardScope do
  @moduledoc "Helper for managing %Board{} data"
  import Lens
  deflenses title: "", columns: []
end

defmodule Lb2.ColumnScope do
  @moduledoc "Helper for managing %Column{} data"
  import Lens
  deflenses title: "", piles: []
end

defmodule Lb2.PileScope do
  @moduledoc "Helper for managing %Pile{} data"
  import Lens
  deflenses cards: []
end
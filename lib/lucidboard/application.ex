defmodule Lucidboard.Application do
  @moduledoc false
  use Application
  alias Lucidboard.LiveBoard
  alias LucidboardWeb.Endpoint

  def start(_type, _args) do
    import Supervisor.Spec

    IO.puts(banner())

    children = [
      supervisor(Lucidboard.Repo, []),
      supervisor(LucidboardWeb.Endpoint, []),
      LiveBoard.registry_child_spec(),
      LiveBoard.dynamic_supervisor_child_spec(),
    ]

    opts = [strategy: :one_for_one, name: Lucidboard.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def config_change(changed, _new, removed) do
    Endpoint.config_change(changed, removed)
    :ok
  end

  defp banner,
    do: ~S"""
         __            _     _ _                         _
        / / _   _  ___(_) __| | |__   ___   __ _ _ __ __| |
       / / | | | |/ __| |/ _` | '_ \ / _ \ / _` | '__/ _` |
      / /__| |_| | (__| | (_| | |_) | (_) | (_| | | | (_| |
      \____/\__,_|\___|_|\__,_|_.__/ \___/ \__,_|_|  \__,_|
    """
end

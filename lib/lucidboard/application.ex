defmodule Lucidboard.Application do
  @moduledoc false
  use Application

  def start(_type, _args) do
    import Supervisor.Spec

    IO.puts(banner())

    children = [
      supervisor(Lucidboard.Repo, []),
      {Registry, keys: :unique, name: Lucidboard.BoardRegistry},
      {DynamicSupervisor,
       name: Lucidboard.BoardSupervisor, strategy: :one_for_one},
      supervisor(LucidboardWeb.Endpoint, [])
    ]

    opts = [strategy: :one_for_one, name: Lucidboard.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def config_change(changed, _new, removed) do
    LucidboardWeb.Endpoint.config_change(changed, removed)
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

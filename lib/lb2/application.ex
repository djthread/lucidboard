defmodule Lb2.Application do
  @moduledoc false
  use Application

  def start(_type, _args) do
    import Supervisor.Spec

    IO.puts(banner())

    children = [
      supervisor(Lb2.Repo, []),
      {Registry, keys: :unique, name: Lb2.BoardRegistry},
      {DynamicSupervisor, name: Lb2.BoardSupervisor, strategy: :one_for_one},
      supervisor(Lb2Web.Endpoint, [])
    ]

    opts = [strategy: :one_for_one, name: Lb2.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def config_change(changed, _new, removed) do
    Lb2Web.Endpoint.config_change(changed, removed)
    :ok
  end

  def banner,
    do: ~S"""
         __            _     _ _                         _
        / / _   _  ___(_) __| | |__   ___   __ _ _ __ __| |
       / / | | | |/ __| |/ _` | '_ \ / _ \ / _` | '__/ _` |
      / /__| |_| | (__| | (_| | |_) | (_) | (_| | | | (_| |
      \____/\__,_|\___|_|\__,_|_.__/ \___/ \__,_|_|  \__,_|
    """
end

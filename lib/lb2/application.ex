defmodule Lb2.Application do
  @moduledoc false
  use Application

  def start(_type, _args) do
    import Supervisor.Spec

    children = [
      supervisor(Lb2.Repo, []),
      supervisor(Lb2Web.Endpoint, [])
    ]

    opts = [strategy: :one_for_one, name: Lb2.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def config_change(changed, _new, removed) do
    Lb2Web.Endpoint.config_change(changed, removed)
    :ok
  end
end

defmodule Tron.Application do
  use Application

  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec

    # Define workers and child supervisors to be supervised
    children = [
      # Start the endpoint when the application starts
      supervisor(TronWeb.Endpoint, []),
      # Start your own worker by calling: Tron.Worker.start_link(arg1, arg2, arg3)
      # worker(Tron.Worker, [arg1, arg2, arg3]),
      # Create a registry to map player IDs to their processes
      { Tron.Player.Registry, name: Tron.Player.Registry },
      # Create a dynamic supervisor to handle player connections
      { DynamicSupervisor,
        name: Tron.PlayerSupervisor, strategy: :one_for_one },
      # Create a server to keep track of foods
      { Tron.World.Food, name: Tron.World.Food }
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Tron.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    TronWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end

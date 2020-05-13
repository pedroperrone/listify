defmodule Listify.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      Listify.Repo,
      # Start the Telemetry supervisor
      ListifyWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Listify.PubSub},
      # Start the Endpoint (http/https)
      ListifyWeb.Endpoint
      # Start a worker by calling: Listify.Worker.start_link(arg)
      # {Listify.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Listify.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    ListifyWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end

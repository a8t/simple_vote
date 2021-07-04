defmodule SimpleVote.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      SimpleVote.Repo,
      # Start the Telemetry supervisor
      SimpleVoteWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: SimpleVote.PubSub},
      # Start the Endpoint (http/https)
      SimpleVoteWeb.Endpoint,
      # Start a worker by calling: SimpleVote.Worker.start_link(arg)
      {SimpleVote.Rooms.RoomRegistry, nil},
      {SimpleVote.Rooms.NicknameRegistry, nil},
      SimpleVoteWeb.Presence
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: SimpleVote.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    SimpleVoteWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end

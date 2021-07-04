# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :simple_vote,
  ecto_repos: [SimpleVote.Repo]

# Configures the endpoint
config :simple_vote, SimpleVoteWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "nOKqKY5qxU8Xx4SyRoXJZ6/vDEjXqNCnOuoaltSjInhvsj3E4+ko8qsCkC5KYgfK",
  render_errors: [view: SimpleVoteWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: SimpleVote.PubSub,
  live_view: [signing_salt: "YTd03k8m"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :surface, :components, [
  {Surface.Components.Form.ErrorTag,
   default_translator: {SimpleVoteWeb.ErrorHelpers, :translate_error}}
]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"

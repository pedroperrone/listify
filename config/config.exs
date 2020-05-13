# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :listify,
  ecto_repos: [Listify.Repo]

# Configures the endpoint
config :listify, ListifyWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "ATyzS+W0Yz2HB8elUcutWkIELfecNSA21Dl4vopR6mGxcfWfaJy8RL5FWF0zNF2T",
  render_errors: [view: ListifyWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: Listify.PubSub,
  live_view: [signing_salt: "3SgLCUcR"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"

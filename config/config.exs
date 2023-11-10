# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

# Configures the endpoint
config :super_perfundo, SuperPerfundoWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "g9ITUiJF7vCpIsUxnlnEONQVRbtjE6Afe2icT1AwwQVBczelfGbeTx/M6PvdzKpq",
  render_errors: [view: SuperPerfundoWeb.ErrorView, accepts: ~w(html json)],
  pubsub_server: SuperPerfundo.PubSub,
  live_view: [signing_salt: "5owO4PIx"]

config :super_perfundo, :posts_pattern, "posts/published/**/*.md"
config :super_perfundo, :drafts_pattern, "posts/drafts/*.md"
config :super_perfundo, :timezone, "US/Eastern"
config :super_perfundo, :email_list, "email-list"
config :super_perfundo, :env, config_env()

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :ex_aws, json_codec: Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"

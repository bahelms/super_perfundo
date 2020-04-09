use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :super_perfundo, SuperPerfundoWeb.Endpoint,
  http: [port: 4002],
  server: false

config :super_perfundo, :posts_pattern, "test/posts/published/**/*.md"
config :super_perfundo, :drafts_pattern, "test/posts/drafts/*.md"

# Print only warnings and errors during test
config :logger, level: :warn

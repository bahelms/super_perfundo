import Config

config :super_perfundo, SuperPerfundoWeb.Endpoint,
  server: true,
  http: [port: {:system, "PORT"}],
  url: [host: System.get_env("APP_NAME") <> ".gigalixirapp.com", port: 443],
  force_ssl: [rewrite_on: [:x_forwarded_proto]]

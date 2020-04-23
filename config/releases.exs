import Config

config :super_perfundo, SuperPerfundoWeb.Endpoint,
  server: true,
  http: [port: {:system, "PORT"}],
  url: [host: System.get_env("HOST")]

config :super_perfundo, SuperPerfundo.Mailer,
  adapter: Bamboo.SendGridAdapter,
  api_key: System.get_env("SENDGRID_API_KEY")

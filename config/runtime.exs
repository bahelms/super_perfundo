import Config

if config_env() == :prod do
  port = System.get_env("PORT", "80")

  config :super_perfundo, SuperPerfundoWeb.Endpoint,
    http: [
      port: String.to_integer(port),
      transport_options: [socket_opts: [:inet6]]
    ],
    url: [host: System.get_env("HOST"), port: port],
    secret_key_base: System.fetch_env!("SECRET_KEY_BASE"),
    server: true

  config :super_perfundo, SuperPerfundo.Mailer,
    adapter: Bamboo.SendGridAdapter,
    api_key: System.fetch_env!("SENDGRID_API_KEY")

  config :super_perfundo, :analytics_src, System.get_env("ANALYTICS_SRC")
end

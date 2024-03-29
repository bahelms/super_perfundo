defmodule SuperPerfundo.MixProject do
  use Mix.Project

  def project do
    [
      app: :super_perfundo,
      version: "0.3.1",
      elixir: "~> 1.14.0",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix, :gettext] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {SuperPerfundo.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:phoenix, "~> 1.5.3"},
      {:phoenix_pubsub, "~> 2.0"},
      {:phoenix_html, "~> 2.11"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:phoenix_live_view, "~> 0.13.2"},
      # remove when upgrading phoenix to 1.6
      {:cowboy_telemetry, "~> 0.3.1"},
      {:gettext, "~> 0.11"},
      {:jason, "~> 1.0"},
      {:plug_cowboy, "~> 2.5"},
      {:earmark, "~> 1.3"},
      {:ex_doc, "~> 0.21.3"},
      {:timex, "~> 3.6.1"},
      {:ex_aws, "~> 2.2"},
      {:ex_aws_s3, "~> 2.2"},
      {:hackney, "~> 1.16"},
      {:sweet_xml, "~> 0.6"},
      {:bamboo, "~> 1.4"},
      {:floki, "~> 0.27.0", only: :test},
      {:rustler, "~> 0.25.0"}
    ]
  end
end

defmodule SuperPerfundo.MixProject do
  use Mix.Project

  def project do
    [
      app: :super_perfundo,
      version: "0.3.1",
      elixir: "~> 1.14",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: Mix.compilers(),
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
      {:phoenix, "~> 1.7.0"},
      # Phoenix 1.7 dropped Phoenix.View from core. This compat package keeps the
      # existing SuperPerfundoWeb.*View modules and .eex templates working, so the
      # view -> Phoenix.Component migration stays a separate decision.
      {:phoenix_view, "~> 2.0"},
      {:phoenix_pubsub, "~> 2.0"},
      # 3.3 rather than 4.0 on purpose: 4.0 removes link/2, button/2, form_for and
      # the input helpers, which all 12 templates use. Phoenix 1.7 supports both.
      {:phoenix_html, "~> 3.3"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:phoenix_live_view, "~> 1.0.0"},
      {:gettext, "~> 0.11"},
      {:jason, "~> 1.0"},
      {:plug, "~> 1.20"},
      {:plug_cowboy, "~> 2.9"},
      # Replaced Earmark, which is retired at every version ("no longer
      # maintained") and whose stored-XSS advisory has no fixed release. Post
      # bodies no longer embed EEx, so nothing depends on a parser that leaves
      # HTML attributes alone -- see Blog.Post.parse_attr/2.
      {:mdex, "~> 0.13"},
      {:timex, "~> 3.7"},
      {:ex_aws, "~> 2.2"},
      {:ex_aws_s3, "~> 2.2"},
      {:hackney, "~> 1.16"},
      {:sweet_xml, "~> 0.6"},
      {:bamboo, "~> 2.5"},
      # Bamboo 2.0 extracted Bamboo.Phoenix (used by SuperPerfundo.Email) into
      # its own package.
      {:bamboo_phoenix, "~> 1.0"},
      {:floki, "~> 0.38", only: :test},
      {:rustler, "~> 0.38.0"}
    ]
  end
end

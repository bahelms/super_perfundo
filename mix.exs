defmodule SuperPerfundo.MixProject do
  use Mix.Project

  def project do
    [
      app: :super_perfundo,
      version: "0.3.1",
      elixir: "~> 1.14",
      elixirc_paths: elixirc_paths(Mix.env()),
      # :gettext dropped (its compiler is gone in gettext >= 0.20 anyway).
      # :phoenix must stay until Phoenix 1.6. Without it a *clean* build passes,
      # but touching a LiveView component leaves update/2 unregistered and
      # render/1 fails with "assign @piece not available" -- so it only breaks
      # incremental rebuilds, which is why a clean build looks fine. Remove in
      # Stage 2 alongside the Phoenix upgrade.
      compilers: [:phoenix] ++ Mix.compilers(),
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
      # plug >= 1.16 requires Elixir ~> 1.15; 1.15.4 is the security backport
      # for the multipart/param-decoding advisories. Widen once on Elixir 1.15+.
      {:plug, "~> 1.15.4"},
      # 2.8.1 patches the HTTP/2 :scheme atom-exhaustion advisory; 2.9.0 needs
      # plug ~> 1.18 (Elixir 1.15+). Widen once on Elixir 1.15+.
      {:plug_cowboy, "~> 2.8.1"},
      # Pinned exactly. Earmark >= 1.4.4 parses HTML attributes, which mangles the
      # EEx embedded in post bodies:
      #   <img src="<%= img_url.("x.jpeg") %>" />
      #     becomes <img src="<%= img_url.(" test="test">   -- the %> is dropped
      # Upgrading requires resolving img_url *before* markdown rendering rather
      # than after (see Blog.get_article/2). Earmark is retired and its stored-XSS
      # advisory has no fixed release, so a parser migration is the real answer.
      {:earmark, "== 1.4.3"},
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

defmodule ExAdmin.Mixfile do
  use Mix.Project

  @version "0.9.1-dev"

  def project do
    [ app: :ex_admin,
      version: @version,
      elixir: "~> 1.4",
      elixirc_paths: elixirc_paths(Mix.env),
      compilers: [:phoenix, :gettext] ++ Mix.compilers,
      build_embedded: Mix.env == :prod,
      start_permanent: Mix.env == :prod,
      name: "ExAdmin",
      docs: [extras: ["README.md"], main: "ExAdmin"],
      deps: deps(),
      package: package(),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [coveralls: :test, "coveralls.detail": :test, "coveralls.post": :test, "coveralls.html": :test],
      description: """
      An Elixir Phoenix Auto Administration Package.
      """
    ]
  end

  def application do
    [ applications: applications(Mix.env)]
  end

  defp applications(:test) do
    [:plug, :cowboy | applications(:prod)]
  end
  defp applications(_) do
    [:gettext, :phoenix, :ecto, :inflex, :scrivener, :scrivener_ecto, :csvlixir, :logger, :xain]
  end
  defp elixirc_paths(:test), do: ["lib", "web", "test/support"]
  defp elixirc_paths(_),     do: ["lib", "web"]

  defp deps do
    [
      {:decimal, "~> 1.4"},
      {:plug_cowboy, "~> 2.0"},
      {:jason, "~> 1.0"},
      {:phoenix, "~> 1.4"},
      {:phoenix_html, "~> 2.12"},
      {:ecto_sql, "~> 3.0"},
      {:phoenix_ecto, "~> 4.0"},
      {:postgrex, "~> 0.14", only: :test},
      {:floki, "~> 0.20", only: :test},
      {:inflex, "~> 1.10"},
      {:scrivener_ecto, "~> 2.0"},
      {:xain, github: "paulzql/xain"},
      {:csvlixir, "~> 2.0.4"},
      {:exactor, "~> 2.2"},
      {:ex_doc, "~> 0.19", only: :dev},
      {:earmark, "~> 1.3", only: :dev},
      {:excoveralls, "~> 0.10", only: :test},
      {:gettext, "~> 0.16"},
      {:hound, "~> 1.0", only: :test}
    ]
  end

  defp package do
    [ maintainers: ["Stephen Pallen", "Roman Smirnov"],
      licenses: ["MIT"],
      links: %{ "Github" => "https://github.com/smpallen99/ex_admin" },
      files: ~w(lib priv web README.md package.json mix.exs LICENSE brunch-config.js AdminLte-LICENSE)]
  end
end

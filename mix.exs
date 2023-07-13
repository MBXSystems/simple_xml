defmodule SimpleXml.MixProject do
  use Mix.Project

  def project do
    [
      app: :simple_xml,
      version: "1.0.1",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      dialyzer: dialyzer(),
      description: description(),
      package: package(),
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp description do
    """
    A simplified Elixir string-based XML processor that avoids the atom exhaustion vulnerability
    present with xmerl based parsers.
    """
  end

  defp package do
    [
      files: ~w(lib .formatter.exs mix.exs README* LICENSE* CHANGELOG*),
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/MBXSystems/simple_xml"}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:saxy, "~> 1.5.0"},
      {:x509, "~> 0.8.7"},
      {:ex_doc, ">= 0.0.0", only: [:dev], runtime: false},
      {:credo, "~> 1.7.0", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.3", only: [:dev, :test], runtime: false},

      # We only use esaml for unit testing.
      {:esaml, "~> 4.5", only: [:dev, :test]}
    ]
  end

  defp dialyzer do
    [
      ignore_warnings: "config/dialyzer.ignore.exs",
      plt_ignore_apps: [:xmerl, :esaml]
    ]
  end

  defp aliases do
    [
      lint: ["format --check-formatted", "credo --strict", "dialyzer --halt-exit-status"]
    ]
  end
end

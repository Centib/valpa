defmodule Valpa.MixProject do
  use Mix.Project

  @source_url "https://github.com/Centib/valpa"
  @version "0.1.1"

  def project do
    [
      app: :valpa,
      version: @version,
      elixir: "~> 1.18",
      start_permanent: Mix.env() == :prod,
      deps: deps(),

      # Hex
      description: "Composable validation library for Elixir. Works on raw values, {:ok, _}, or {:error, _}, with pipelined field validation and automatic error propagation.",
      package: package(),

      # Docs
      name: "Valpa",
      docs: docs()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:credo, "~> 1.7.12", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.38.1", only: :dev, runtime: false},
      {:loe, "~> 0.1.2"},
      {:decimal, "~> 2.3.0"}
    ]
  end

  defp package do
    [
      maintainers: ["gnjec (Centib)"],
      licenses: ["MIT"],
      links: %{"GitHub" => @source_url},
      files: ~w(.formatter.exs mix.exs README.md CHANGELOG.md LICENSE.md lib),
      keywords: ["validation", "valid", "lift", "pipe", "railway", "macro", "elixir", "helpers"]
    ]
  end

  defp docs do
    [
      main: "readme",
      extras: ["README.md", "CHANGELOG.md", "LICENSE.md"],
      source_ref: "v#{@version}",
      source_url: @source_url,
      logo: "assets/logo.svg"
    ]
  end
end

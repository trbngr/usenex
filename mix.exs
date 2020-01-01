defmodule Usenex.MixProject do
  use Mix.Project

  def project do
    [
      app: :usenex,
      aliases: aliases(),
      version: "0.1.0",
      elixir: "~> 1.9",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      elixirc_paths: elixirc_paths(Mix.env())
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"] ++ Path.wildcard("test/**/support")
  defp elixirc_paths(:dev), do: ["lib", "scripts"]
  defp elixirc_paths(_), do: ["lib"]

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Usenex, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:connection, "~> 1.0"},
      {:poolboy, "~> 1.5"}
    ]
  end

  defp aliases do
    [
      test: ["test --no-start"]
    ]
  end
end

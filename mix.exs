defmodule SegSeg.Mixfile do
  use Mix.Project

  def project do
    [
      app: :seg_seg,
      version: "1.0.0",
      elixir: "~> 1.2",
      description: description(),
      package: package(),
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [coveralls: :test],
      dialyzer: [plt_add_apps: [:mix]],
      deps: deps(),
      aliases: aliases()
    ]
  end

  def application do
    [applications: [:logger, :vector]]
  end

  defp deps do
    [
      {:vector, "~> 1.0"},
      {:earmark, "~> 1.0", only: :dev},
      {:ex_doc, "~> 0.16", only: :dev},
      {:excoveralls, "~> 0.4", only: :test},
      {:credo, "~> 1.6", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.2", only: [:dev], runtime: false}
    ]
  end

  defp description do
    """
    Segment-Segment intersection point and classification
    """
  end

  defp package do
    [
      files: ["lib", "mix.exs", "README*"],
      maintainers: ["Powell Kinney"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/pkinney/segseg_ex"}
    ]
  end

  defp aliases do
    [
      validate: [
        "clean",
        "compile --warnings-as-error",
        "format --check-formatted",
        "credo",
        "dialyzer"
      ]
    ]
  end
end

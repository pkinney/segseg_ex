defmodule SegSeg.Mixfile do
  use Mix.Project

  def project do
    [app: :seg_seg,
     version: "0.1.1",
     elixir: "~> 1.2",
     description: description(),
     package: package(),
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     test_coverage: [tool: ExCoveralls],
     preferred_cli_env: [coveralls: :test],
     dialyzer: [plt_add_apps: [:poison, :mix]],
     deps: deps()]
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
      {:credo, "~> 0.8", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 0.4", only: [:dev], runtime: false}
    ]
  end

  defp description do
    """
    Segment-Segment intersection piont and classification
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
end

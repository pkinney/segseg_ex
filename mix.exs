defmodule SegSeg.Mixfile do
  use Mix.Project

  def project do
    [app: :seg_seg,
     version: "0.1.0",
     elixir: "~> 1.2",
     description: description,
     package: package,
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     test_coverage: [tool: ExCoveralls],
     deps: deps]
  end

  def application do
    [applications: [:logger]]
  end

  defp deps do
    [
      {:vector, "~> 0.2.1"},
      {:earmark, "~> 0.1", only: :dev},
      {:ex_doc, "~> 0.11", only: :dev},
      {:excoveralls, "~> 0.4", only: :test}
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

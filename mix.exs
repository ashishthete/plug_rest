defmodule PlugRest.Mixfile do
  use Mix.Project

  @version "0.10.0"
  @source_url "https://github.com/christopheradams/plug_rest"

  def project do
    [app: :plug_rest,
     version: @version,
     elixir: "~> 1.2",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     dialyzer: [plt_add_deps: true,
                plt_apps: [:erts, :kernel, :stdlib, :crypto, :public_key, :inets]],
     docs: docs(),
     description: description(),
     source_url: @source_url,
     package: package(),
     deps: deps()]
  end

  def application do
    [applications: [:plug, :cowboy, :logger]]
  end

  defp deps do
    [{:plug, "~> 1.0"},
     {:cowboy, "~> 1.0"},
     {:ex_doc, ">= 0.0.0", only: :dev},
     {:dialyxir, "~> 0.3.5", only: [:dev]}]
  end

  defp description do
    """
    REST behaviour and Plug router for hypermedia web applications
    """
  end

  defp docs() do
    [
      source_ref: "v#{@version}",
      main: "readme",
      extras: [
        "README.md": [title: "README"]
      ]
    ]
  end

  defp package do
    [
     name: :plug_rest,
     maintainers: ["Christopher Adams"],
     licenses: ["MIT"],
     links: %{github: "https://github.com/christopheradams/plug_rest"}
    ]
  end
end

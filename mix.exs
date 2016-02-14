defmodule PartyBot3000.Mixfile do
  use Mix.Project

  def project do
    [app: :party_bot_3000,
     version: "0.0.6",
     elixir: "~> 1.2.2",
     deps: deps]
  end

  def application do
    [applications: [:logger, :httpoison, :slack, :poison, :websocket_client],
     mod: {PartyBot3000, []}]
  end

  defp deps do
    [
      {:exrm, "~> 1.0.0-rc7"},
      {:slack, "~> 0.4.1"},
      {:httpoison, "~> 0.8.1"},
      {:poison, "~> 2.0"},
      {:sshex, "2.0.1"},
      {:websocket_client, git: "https://github.com/jeremyong/websocket_client"}
    ]
  end
end

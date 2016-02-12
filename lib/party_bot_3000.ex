defmodule PartyBot3000 do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      worker(PartyBot3000.Bot, [[]])
      # worker(PartyBot3000.Bot, [[]], function: start) #??
    ]

    opts = [strategy: :one_for_one, name: PartyBot3000.Supervisor]
    Supervisor.start_link(children, opts)
  end
end

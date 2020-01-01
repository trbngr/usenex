defmodule Usenex do
  use Application

  def start(_type, _args) do
    children = [
      {Usenex.Nntp.Supervisor, Application.get_env(:usenex, :nntp)}
    ]

    opts = [strategy: :one_for_one, name: Usenex.Supervisor]
    Supervisor.start_link(children, opts)
  end
end

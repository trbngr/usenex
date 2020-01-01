defmodule Usenex.Nntp.Supervisor do
  use Supervisor
  alias Usenex.Nntp

  def start_link(opts \\ []) do
    Supervisor.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def init(opts) do
    nntp_config = [
      {:name, {:local, Nntp.pool_name()}},
      {:worker_module, Nntp},
      {:size, Keyword.get(opts, :pool_size, 5)},
      {:max_overflow, 1}
    ]

    children = [
      :poolboy.child_spec(Nntp.pool_name(), nntp_config, opts)
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end

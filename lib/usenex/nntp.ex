defmodule Usenex.Nntp do
  use GenServer

  defmodule NntpError do
    defexception [:status, :message]
  end

  require Logger
  alias Usenex.Nntp.Group
  alias Usenex.Nntp.Command
  alias Usenex.Nntp.NntpConnection

  @port 119
  @timeout 5000

  def pool_name, do: :nttp_connection

  def start_link(opts), do: GenServer.start_link(__MODULE__, opts)

  def capabilities(), do: command(:capabilities)
  def group(group), do: command(:group, group)
  def xover(%Group{} = group), do: command(:xover, group)

  # ### Server API

  def init(opts) do
    state = %{
      host: Keyword.get(opts, :host),
      port: Keyword.get(opts, :port, @port),
      timeout: Keyword.get(opts, :timeout, @timeout),
      username: Keyword.get(opts, :username),
      password: Keyword.get(opts, :password)
    }

    {:ok, state, {:continue, :connect_and_auth}}
  end

  defp command(command, args \\ nil) do
    :poolboy.transaction(pool_name(), fn pid ->
      GenServer.call(pid, {:command, command, args})
    end)
  end

  def handle_call({:command, command, args}, _from, %{connection: connection} = state) do
    reply = Command.execute(command, connection, args)
    {:reply, reply, state}
  end

  def handle_continue(:connect_and_auth, state) do
    {:ok, connection} = struct(NntpConnection.State, state) |> connect()

    case Command.execute(:authenticate, connection, state) do
      {:ok, response} -> Logger.info(response)
      {:error, %NntpError{} = error} -> raise error
    end

    {:noreply, Map.put(state, :connection, connection)}
  end

  defp connect(%NntpConnection.State{} = state) do
    case NntpConnection.start_link(state) do
      {:ok, pid} ->
        {_, _data} = NntpConnection.recv(pid, 0, 1000)
        {:ok, pid}

      {:error, reason} ->
        {:error, reason}
    end
  end
end

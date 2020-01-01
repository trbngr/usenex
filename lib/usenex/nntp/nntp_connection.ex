defmodule Usenex.Nntp.NntpConnection do
  use Connection
  require Logger

  defmodule State do
    defstruct [:sock, :host, :port, :timeout, opts: [active: false, mode: :binary]]
  end

  def start_link(%State{} = state) do
    Connection.start_link(__MODULE__, %{state | host: String.to_charlist(state.host)})
  end

  def close(pid), do: Connection.call(pid, :close)
  def send(pid, data), do: Connection.call(pid, {:send, data <> "\r\n"})

  def recv(pid, bytes, timeout \\ 3000) do
    Connection.call(pid, {:recv, bytes, timeout})
  end

  def init(state), do: {:connect, :init, state}

  def connect(_, state) do
    case :gen_tcp.connect(state.host, state.port, state.opts, state.timeout) do
      {:ok, sock} -> {:ok, %{state | sock: sock}}
      {:error, _} -> {:backoff, 1000, state}
    end
  end

  def disconnect(info, %{sock: sock} = state) do
    :ok = :gen_tcp.close(sock)

    case info do
      {:close, from} -> Connection.reply(from, :ok)
      {:error, :closed} -> Logger.error("NNTP Connection closed")
      {:error, reason} -> Logger.error("NNTP Connection error: #{:inet.format_error(reason)}")
    end

    {:connect, :reconnect, %{state | sock: nil}}
  end

  def handle_call(_, _, %{sock: nil} = state) do
    {:reply, {:error, :closed}, state}
  end

  def handle_call({:send, data}, _from, %{sock: sock} = state) do
    case :gen_tcp.send(sock, data) do
      :ok -> {:reply, :ok, state}
      {:error, _} = error -> {:disconnect, error, error, state}
    end
  end

  def handle_call({:recv, bytes, timeout}, _, %{sock: sock} = state) do
    case :gen_tcp.recv(sock, bytes, timeout) do
      {:ok, _} = ok -> {:reply, ok, state}
      {:error, :timeout} = timeout -> {:reply, timeout, state}
      {:error, _} = error -> {:disconnect, error, error, state}
    end
  end

  def handle_call(:close, from, state) do
    {:disconnect, {:close, from}, state}
  end
end

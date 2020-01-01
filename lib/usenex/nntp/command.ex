defmodule Usenex.Nntp.Command do
  alias Usenex.Nntp.{Command, Group, NntpConnection}

  def execute(:authenticate, pid, %{username: username, password: password}) do
    exe = fn cmd -> send_command(pid, cmd) |> Command.Authenticate.process(pid) end

    with {:ok, _} <- exe.("AUTHINFO USER #{username}"),
         {:ok, response} <- exe.("AUTHINFO PASS #{password}") do
      {:ok, response}
    end
  end

  def execute(:capabilities, pid, _args) do
    pid
    |> send_command("CAPABILITIES")
    |> Command.Capabilities.process(pid)
  end

  def execute(:group, pid, group) do
    pid
    |> send_command("GROUP #{group}")
    |> Command.Group.process(pid)
  end

  def execute(:xover, pid, %Group{first: first}) do
    pid
    |> send_command("XOVER #{first}-")
    |> Command.Xover.process(pid)
  end

  defp send_command(pid, command) do
    NntpConnection.send(pid, command)
    NntpConnection.recv(pid, 0, 2000)
  end

  defmacro __using__(_opts) do
    quote do
      import Command, only: [nntp_response: 1, nntp_response: 2]
      @before_compile Command
    end
  end

  defmacro __before_compile__(_env) do
    quote do
      alias Usenex.Nntp.NntpError

      @spec process({:ok, response :: binary}, pid :: pid()) ::
              {:ok, binary()} | {:error, %NntpError{}}

      def process({:ok, <<code::binary-size(3), " ", response::binary>>}, _pid) do
        {:error, %NntpError{message: String.trim(response), status: code}}
      end
    end
  end

  defmacro nntp_response(status_code, resolver \\ nil)
           when is_integer(status_code) do
    status_code = to_string(status_code)

    quote generated: true do
      def process({:ok, <<unquote(status_code), " ", response::binary>>}, pid) do
        resolver =
          case unquote(resolver) do
            nil -> fn resp, _pid -> {:ok, String.trim(resp)} end
            fun -> fun
          end

        resolver.(response, pid)
      end
    end
  end
end

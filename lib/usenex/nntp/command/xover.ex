defmodule Usenex.Nntp.Command.Xover do
  use Usenex.Nntp.Command
  alias Usenex.Nntp.{Group, NntpConnection, NntpError}

  nntp_response 224, fn _response, conn ->
    reducer = fn {:ok, messages}, acc ->
      if String.ends_with?(messages, ".\r\n"),
        do: {:halt, acc <> messages},
        else: {:cont, acc <> messages}
    end

    response =
      Stream.cycle([0])
      |> Stream.map(fn _ -> NntpConnection.recv(conn, 0, 2000) end)
      |> Enum.reduce_while("", reducer)
      |> join_messages()
      |> Enum.into(%{}, fn [id | names] -> {id, names} end)

    {:ok, response}
  end

  def join_messages(messages) do
    [_terminator | messages] =
      messages
      |> String.trim_trailing("\r\n")
      |> String.split("\r\n")
      |> Enum.map(&String.trim(&1, "\""))
      |> Enum.map(&String.split(&1, "\t"))
      |> Enum.reverse()

    Enum.reverse(messages)
  end
end

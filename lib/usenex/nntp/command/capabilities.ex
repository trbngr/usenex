defmodule Usenex.Nntp.Command.Capabilities do
  use Usenex.Nntp.Command

  nntp_response 101, fn response, _conn ->
    [_term | caps] =
      response
      |> String.trim_leading("Capabilities list:\r\n")
      |> String.trim_trailing("\r\n")
      |> String.split("\r\n")
      |> Enum.flat_map(&String.split(&1, " "))
      |> Enum.reverse()

    {:ok, Enum.reverse(caps)}
  end
end

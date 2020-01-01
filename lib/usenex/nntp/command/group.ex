defmodule Usenex.Nntp.Command.Group do
  use Usenex.Nntp.Command
  alias Usenex.Nntp.{Group, NntpError}

  nntp_response 211, fn response, _conn ->
    [count, first, last, name] = response |> String.trim() |> String.split()

    group = %Group{
      count: String.to_integer(count),
      first: String.to_integer(first),
      last: String.to_integer(last),
      name: name
    }

    {:ok, group}
  end
end

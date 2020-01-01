defmodule Usenex.Nntp.Command.Authenticate do
  alias Usenex.Nntp.NntpError
  use Usenex.Nntp.Command

  nntp_response 281
  nntp_response 381
end

defmodule Usenex.NntpTest do
  alias Usenex.Nntp
  use Support.NntpCase

  describe "commands" do
    test "caps" do
      {:ok, caps} = Nntp.capabilities()
      assert is_list(caps)
    end

    test "group" do
      {:error, %Nntp.NntpError{}} = Nntp.group("alt.binaries.fuckshit")
      {:ok, %Nntp.Group{}} = Nntp.group("alt.binaries")
    end

    test "xover" do
      {:ok, group} = Nntp.group("alt.binaries")
      Nntp.xover(%{group | first: group.last - 12}) |> IO.inspect()
    end
  end
end

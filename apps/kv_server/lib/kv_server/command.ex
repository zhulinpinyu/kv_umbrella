defmodule KVServer.Command do

  @doc ~S"""
  Parse the given `line` into command
    iex> KVServer.Command.parse("CREATE shopping\r\n")
    {:ok, {:create, "shopping"}}

    iex> KVServer.Command.parse("PUT shopping milk 2\r\n")
    {:ok, {:put, "shopping", "milk", "2"}}

    iex> KVServer.Command.parse("GET shopping milk\r\n")
    {:ok, {:get, "shopping", "milk"}}

    iex> KVServer.Command.parse("DELETE shopping milk\r\n")
    {:ok, {:delete, "shopping", "milk"}}

    iex> KVServer.Command.parse("DELETE shopping\r\n")
    {:error, :unknown_command}
  """

  def parse(line) do
    case String.split(line) do
      ["CREATE", bucket] -> {:ok, {:create, bucket}}
      ["PUT", bucket, key, val] -> {:ok, {:put, bucket, key, val}}
      ["GET", bucket, key] -> {:ok, {:get, bucket, key}}
      ["DELETE", bucket, key] -> {:ok, {:delete, bucket, key}}
      _ -> {:error, :unknown_command}
    end
  end
end

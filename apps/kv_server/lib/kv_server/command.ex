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

  @doc """
  Runs the given command
  """
  def run(command)

  def run({:create, bucket}) do
    KV.Registry.create(KV.Registry, bucket)
    {:ok, "OK\r\n"}
  end

  def run({:put, bucket, key, value}) do
    lookup(bucket, fn pid ->
      KV.Bucket.put(pid, key, value)
      {:ok, "OK\r\n"}
    end)
  end

  def run({:get, bucket, key}) do
    lookup(bucket, fn pid ->
      value = KV.Bucket.get(pid, key)
      {:ok, "#{value}\r\nOK\r\n"}
    end)
  end

  def run({:delete, bucket, key}) do
    lookup(bucket, fn pid ->
      value = KV.Bucket.delete(pid, key)
      {:ok, "OK\r\n"}
    end)
  end

  defp lookup(bucket, callback) do
    case KV.Registry.lookup(KV.Registry, bucket) do
      {:ok, pid} -> callback.(pid)
      :error -> {:error, :not_found}
    end
  end
end

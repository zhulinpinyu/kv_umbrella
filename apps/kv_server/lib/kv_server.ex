defmodule KVServer do
  require Logger
  def accept(port) do
    {:ok, socket} = :gen_tcp.listen(port, [:binary, packet: :line, active: false, reuseaddr: true])
    Logger.info(fn -> "Accepting connections on port #{port}" end)
    loop_acceptor(socket)
  end

  defp loop_acceptor(socket) do
    {:ok, socket} = :gen_tcp.accept(socket)
    server(socket)
    loop_acceptor(socket)
  end

  defp server(socket) do
    socket
    |> read_line()
    |> write_line(socket)

    server(socket)
  end

  defp read_line(socket)  do
    {:ok, data} = :gen_tcp.recv(socket, 0)
    data
  end

  defp write_line(line, socket) do
    :gen_tcp.send(socket, line)
  end
end

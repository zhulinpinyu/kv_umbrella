defmodule KVServer do
  require Logger
  def accept(port) do
    {:ok, socket} = :gen_tcp.listen(port, [:binary, packet: :line, active: false, reuseaddr: true])
    Logger.info(fn -> "Accepting connections on port #{port}" end)
    loop_acceptor(socket)
  end

  defp loop_acceptor(socket) do
    {:ok, client} = :gen_tcp.accept(socket)
    {:ok, pid} = Task.Supervisor.start_child(
      KVServer.TaskSupervisor,
      fn -> server(client) end
    )
    :ok = :gen_tcp.controlling_process(client, pid)
    loop_acceptor(socket)
  end

  defp server(socket) do
    msg =
      with {:ok, data} <- read_line(socket),
        {:ok, command} <- KVServer.Command.parse(data)
      do
        KVServer.Command.run(command)
      else
        {:error, error} -> error
      end

    write_line(socket, msg)
    server(socket)
  end

  defp read_line(socket)  do
    :gen_tcp.recv(socket, 0)
  end

  defp write_line(socket, {:ok, text}) do
    :gen_tcp.send(socket, text)
  end

  defp write_line(socket, {:error, :unknown_command}) do
    :gen_tcp.send(socket, "UNKNOWN COMMAND\r\n")
  end

  defp write_line(_socket, {:error, :closed}) do
    exit(:shutdown)
  end

  defp write_line(socket, {:error, error}) do
    :gen_tcp.send(socket, "ERROR\r\n")
    exit(error)
  end
end

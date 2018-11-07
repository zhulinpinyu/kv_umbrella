defmodule KVServerTest do
  use ExUnit.Case

  @moduletag :capture_log

  setup do
    Application.stop(:kv)
    :ok = Application.start(:kv)
  end

  setup do
    opts = [:binary, packet: :line, active: false]
    {:ok, socket} = :gen_tcp.connect('localhost', 4040, opts)
    %{socket: socket}
  end

  test "Server Interaction", %{socket: socket} do
    assert send_and_recv(socket, "UNKNOWN shopping\r\n") == "UNKNOWN COMMAND\r\n"

    assert send_and_recv(socket, "GET shopping milk\r\n") == "NOT FOUND\r\n"

    assert send_and_recv(socket, "CREATE shopping\r\n") == "OK\r\n"

    assert send_and_recv(socket, "PUT shopping milk 2\r\n") == "OK\r\n"

    assert send_and_recv(socket, "GET shopping milk\r\n") == "2\r\n"
    assert send_and_recv(socket, "") == "OK\r\n"

    assert send_and_recv(socket, "DELETE shopping milk\r\n") == "OK\r\n"

    assert send_and_recv(socket, "GET shopping milk\r\n") == "\r\n"
    assert send_and_recv(socket, "") == "OK\r\n"
  end

  defp send_and_recv(socket, command) do
    :ok = :gen_tcp.send(socket, command)
    {:ok, data} = :gen_tcp.recv(socket, 0, 1000)
    data
  end
end

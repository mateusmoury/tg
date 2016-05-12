defmodule RequestHandlerTest do
  use ExUnit.Case
  doctest Server

  test "Server sends data back" do
    {:ok, socket} = :gen_tcp.connect(:localhost, Application.get_env(:server, :port), [:binary, active: false])
    :ok = :gen_tcp.send(socket, "olá")
    {:ok, data} = :gen_tcp.recv(socket, 0)
    assert data == "olá"
    :ok = :gen_tcp.close(socket)
  end

  test "Server handles multiple connections" do
    {:ok, socket1} = :gen_tcp.connect(:localhost, Application.get_env(:server, :port), [:binary, active: false])
    {:ok, socket2} = :gen_tcp.connect(:localhost, Application.get_env(:server, :port), [:binary, active: false])
    :ok = :gen_tcp.send(socket1, "olá")
    :ok = :gen_tcp.send(socket2, "oi")
    {:ok, data2} = :gen_tcp.recv(socket2, 0)
    {:ok, data1} = :gen_tcp.recv(socket1, 0)
    assert data2 == "oi"
    assert data1 == "olá"
    :ok = :gen_tcp.close(socket1)
    :ok = :gen_tcp.close(socket2)
  end
end

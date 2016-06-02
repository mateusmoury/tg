defmodule MessagingLayer.ClientRequestHandler do

  @timeout 2000

  def connect(host, port) do
    case :gen_tcp.connect(host, port, [:binary, active: false], @timeout) do
      {:ok, socket} ->
        {:ok, socket}
      error ->
        error
    end
  end

  def send_message(socket, message) do
    :gen_tcp.send(socket, message)
  end

  def receive_message(socket) do
    :gen_tcp.recv(socket, 0, @timeout)
  end

  def disconnect(socket) do
    :gen_tcp.close(socket)
  end
end
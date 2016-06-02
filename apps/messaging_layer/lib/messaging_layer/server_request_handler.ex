defmodule MessagingLayer.ServerRequestHandler do

  def listen(port) do
    :gen_tcp.listen(
      port,
      [:binary, active: false, reuseaddr: true]
    )
  end

  def accept(socket) do
    :gen_tcp.accept(socket)
  end

  def change_socket_process(client, new_process) do
    :gen_tcp.controlling_process(client, new_process)
  end

  def receive_msg(socket) do
    :gen_tcp.recv(socket, 0)
  end

  def send_msg(msg, socket) do
    :gen_tcp.send(socket, msg)
  end

  def disconnect(socket) do
    :gen_tcp.close(socket)
  end
end
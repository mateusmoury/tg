defmodule MessagingLayer.ServerRequestHandler do

  @timeout 10000
  @max_attempts 3

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

  def receive_message(socket) do
    :gen_tcp.recv(socket, 0, @timeout)
  end

  def send_message(message, socket) do
    _send_message(message, socket, 0)
  end

  defp _send_message(message, socket, attempt) do
    case :gen_tcp.send(socket, message) do
      error = {:error, _reason} ->
        if attempt == @max_attempts do
          error
        else
          _send_message(socket, message, attempt + 1)
        end
      _ ->
        :gen_tcp.close(socket)
        :ok
    end
  end
end

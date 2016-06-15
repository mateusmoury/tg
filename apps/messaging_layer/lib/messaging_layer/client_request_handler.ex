defmodule MessagingLayer.ClientRequestHandler do

  @timeout 10000
  @max_attempts 3

  def connect(host, port) do
    :gen_tcp.connect(host, port, [:binary, active: false], @timeout)
  end

  def send_message(socket, message) do
    _send_message(socket, message, 0)
  end

  defp _send_message(socket, message, attempt) do
    case :gen_tcp.send(socket, message) do
      error = {:error, _reason} ->
        if attempt == @max_attempts do
          error
        else
          _send_message(socket, message, attempt + 1)
        end
      _ ->
        :ok
    end
  end

  def receive_message(socket) do
    :gen_tcp.recv(socket, 0, @timeout)
  end

  def disconnect(socket) do
    :gen_tcp.close(socket)
  end
end
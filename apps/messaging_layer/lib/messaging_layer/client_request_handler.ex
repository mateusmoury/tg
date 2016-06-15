defmodule MessagingLayer.ClientRequestHandler do

  @timeout 10000
  @max_attempts 3

  def connect(host, port) do
    case :gen_tcp.connect(host, port, [:binary, active: false], @timeout) do
      {:error, _} ->
        {:error, :unable_to_connect_to_server}
      socket_info ->
        socket_info
    end
  end

  def send_message(socket, message) do
    _send_message(socket, message, 0)
  end

  defp _send_message(socket, message, attempt) do
    case :gen_tcp.send(socket, message) do
      {:error, _} ->
        if attempt == @max_attempts do
          :gen_tcp.close(socket)
          {:error, :unable_to_send_message}
        else
          _send_message(socket, message, attempt + 1)
        end
      _ ->
        :ok
    end
  end

  def receive_message(socket) do
    response = :gen_tcp.recv(socket, 0, @timeout)
    :gen_tcp.close(socket)
    case response do
      {:error, _} ->
        {:error, :unable_to_receive_message}
      response_data ->
        response_data
    end
  end
end
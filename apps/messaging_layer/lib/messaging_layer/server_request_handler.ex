defmodule MessagingLayer.ServerRequestHandler do

  @timeout 10000
  @max_attempts 10

  def listen(port) do
    case :gen_tcp.listen(port, [:binary, active: false, reuseaddr: true]) do
      {:error, _} ->
        {:error, :unable_to_use_port}
      socket ->
        socket
    end
  end

  def accept(socket) do
    :gen_tcp.accept(socket)
  end

  def change_socket_process(client, new_process) do
    :gen_tcp.controlling_process(client, new_process)
  end

  def receive_message(socket) do
    case :gen_tcp.recv(socket, 0, @timeout) do
      {:error, _} ->
        :gen_tcp.close(socket)
        {:error, :unable_to_receive_message}
      data ->
        data
    end
  end

  def send_message(message, socket) do
    _send_message(message, socket, 0)
  end

  defp _send_message(message, socket, attempt) do
    case :gen_tcp.send(socket, message) do
      {:error, _} ->
        if attempt == @max_attempts do
          :gen_tcp.close(socket)
          {:error, :unable_to_send_message}
        else
          :timer.sleep(1000)
          _send_message(socket, message, attempt + 1)
        end
      _ ->
        :gen_tcp.close(socket)
        :ok
    end
  end
end

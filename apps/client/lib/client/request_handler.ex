defmodule Client.RequestHandler do

  @timeout Application.get_env(:client, :timeout)

  def connect(host, port) do
    case :gen_tcp.connect(host, port, [:binary, active: false], @timeout) do
      {:ok, socket} ->
        Agent.start_link(fn -> socket end)
      error ->
        error
    end
  end

  def send_message(pid, message) do
    socket = Agent.get(pid, &(&1))
    :gen_tcp.send(socket, message)
  end

  def receive_message(pid) do
    socket = Agent.get(pid, &(&1))
    :gen_tcp.recv(socket, 0, @timeout)
  end

  def disconnect(pid) do
    socket = Agent.get(pid, &(&1))
    :gen_tcp.close(socket)
  end
end
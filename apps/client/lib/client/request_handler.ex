defmodule Client.RequestHandler do
  
  def send_and_receive(host, port, message) do
    {:ok, socket} = :gen_tcp.connect(host, port, [:binary, active: false], Application.get_env(:client, :timeout))
    :ok = :gen_tcp.send(socket, message)
    {:ok, data} = :gen_tcp.recv(socket, 0)
    :ok = :gen_tcp.close(socket)
    data
  end
end
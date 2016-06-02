defmodule NamingService.RequestHandler do

  def listen(port) do
    {:ok, socket} = :gen_tcp.listen(
      port,
      [:binary, active: false, reuseaddr: true]
    )
    connection_loop(socket)
  end

  defp connection_loop(socket) do
    {:ok, client} = :gen_tcp.accept(socket)
    process_request(client)
    connection_loop(socket)
  end

  defp process_request(client) do
    {:ok, data} = :gen_tcp.recv(client, 0)
    response = NamingService.Invoker.process_request(data)
    :ok = :gen_tcp.send(client, response)
    :ok = :gen_tcp.close(client)
  end
end
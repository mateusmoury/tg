defmodule Server.RequestHandler do

  def listen(port) do
    {:ok, socket} = :gen_tcp.listen(
      port,
      [:binary, active: false, reuseaddr: true]
    )
    connection_loop(socket)
  end

  defp connection_loop(socket) do
    {:ok, client} = :gen_tcp.accept(socket)
    create_process_for(client)
    connection_loop(socket)
  end

  defp create_process_for(client) do
    {:ok, pid} = Task.Supervisor.start_child(Server.RequestHandler.TaskSupervisor, fn -> process_request(client) end)
    :ok = :gen_tcp.controlling_process(client, pid)
    send(pid, :proceed)
  end

  defp process_request(client) do
    receive do
      :proceed ->
        {:ok, data} = :gen_tcp.recv(client, 0)
        response = Server.Invoker.process_request(data)
        :ok = :gen_tcp.send(client, response)
        :ok = :gen_tcp.close(client)
    end
  end
end
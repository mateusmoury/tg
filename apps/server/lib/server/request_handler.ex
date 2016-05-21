defmodule Server.RequestHandler do

  def accept(port) do
    {:ok, socket} = :gen_tcp.listen(
      port,
      [:binary, active: false, reuseaddr: true]
    )
    connection_loop(socket)
  end

  defp connection_loop(socket) do
    {:ok, client} = :gen_tcp.accept(socket)
    {:ok, pid} = Task.Supervisor.start_child(Server.RequestHandler.TaskSupervisor, fn -> process_request(client) end)
    :ok = :gen_tcp.controlling_process(client, pid)
    send(pid, :proceed)
    connection_loop(socket)
  end

  defp process_request(client) do
    receive do
      :proceed ->
        {:ok, data} = :gen_tcp.recv(client, 0)
        :ok = :gen_tcp.send(client, data)
        :ok = :gen_tcp.close(client)
    end
  end
end
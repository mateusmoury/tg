defmodule Server.Invoker do

  def invoke(port) do
    {:ok, socket} = MessagingLayer.ServerRequestHandler.listen(port)
    connection_loop(socket)
  end

  defp connection_loop(socket) do
    {:ok, client} = MessagingLayer.ServerRequestHandler.accept(socket)
    create_process_for(client)
    connection_loop(socket)
  end

  defp create_process_for(client) do
    {:ok, pid} =
      Task.Supervisor.start_child(Server.Invoker.TaskSupervisor, fn -> process_request(client) end)
    :ok = MessagingLayer.ServerRequestHandler.change_socket_process(client, pid)
    send(pid, :proceed)
  end

  def process_request(client) do
    receive do
      :proceed ->
        {:ok, marshalled_data} = MessagingLayer.ServerRequestHandler.receive_msg(client)

        marshalled_data
        |> Server.Marshaller.unmarshall
        |> call_function
        |> Server.Marshaller.marshall
        |> MessagingLayer.ServerRequestHandler.send_msg(client)

        MessagingLayer.ServerRequestHandler.disconnect(client)
    end
  end

  defp call_function({functionName, args}) do
    apply(Server.Application, String.to_atom(functionName), args)
  end
end
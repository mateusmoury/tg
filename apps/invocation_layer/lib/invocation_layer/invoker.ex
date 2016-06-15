defmodule InvocationLayer.Invoker do
  
  def invoke(port, supervisor_pid) do
    {:ok, socket} = MessagingLayer.ServerRequestHandler.listen(port)
    connection_loop(socket, supervisor_pid)
  end

  defp connection_loop(socket, supervisor_pid) do
    {:ok, client} = MessagingLayer.ServerRequestHandler.accept(socket)
    create_process_for(client, supervisor_pid)
    connection_loop(socket, supervisor_pid)
  end

  defp create_process_for(client, supervisor_pid) do
    {:ok, pid} =
      Task.Supervisor.start_child(supervisor_pid, fn -> process_request(client) end)
    :ok = MessagingLayer.ServerRequestHandler.change_socket_process(client, pid)
    send(pid, :proceed)
  end

  defp process_request(client) do
    receive do
      :proceed ->
        {:ok, marshalled_data} = MessagingLayer.ServerRequestHandler.receive_message(client)

        marshalled_data
        |> MessagingLayer.Marshaller.unmarshall
        |> call_function
        |> MessagingLayer.Marshaller.marshall
        |> MessagingLayer.ServerRequestHandler.send_message(client)

        MessagingLayer.ServerRequestHandler.disconnect(client)
    end
  end

  defp call_function({mod_name, func_name, args}) do
    apply(mod_name, func_name, args)
  end
end
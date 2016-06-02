defmodule Client.Requestor do

  def invoke({host, port}, functionName, args) do
    case Client.RequestHandler.connect(host, port) do
      {:ok, pid} ->
        handle_communication(pid, functionName, args)
      error ->
        error
    end
  end

  defp handle_communication(socket_pid, functionName, args) do
    marshalledMessage = Client.Marshaller.marshall({functionName, args})
    response_data =
      case Client.RequestHandler.send_message(socket_pid, marshalledMessage) do
        :ok ->
          Client.RequestHandler.receive_message(socket_pid)
        error ->
          error
      end
    return_to_proxy(response_data)
  end

  defp return_to_proxy({:ok, data}) do
    {:ok, Client.Marshaller.unmarshall(data)}
  end

  defp return_to_proxy(error) do
    error
  end
end
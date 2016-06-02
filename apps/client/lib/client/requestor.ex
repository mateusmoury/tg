defmodule Client.Requestor do

  def invoke({host, port}, functionName, args) do
    case MessagingLayer.ClientRequestHandler.connect(host, port) do
      {:ok, socket} ->
        handle_communication(socket, functionName, args)
      error ->
        error
    end
  end

  defp handle_communication(socket, functionName, args) do
    marshalledMessage = Client.Marshaller.marshall({functionName, args})
    response_data =
      case MessagingLayer.ClientRequestHandler.send_message(socket, marshalledMessage) do
        :ok ->
          MessagingLayer.ClientRequestHandler.receive_message(socket)
        error ->
          error
      end
    MessagingLayer.ClientRequestHandler.disconnect(socket)
    return_to_proxy(response_data)
  end

  defp return_to_proxy({:ok, data}) do
    {:ok, Client.Marshaller.unmarshall(data)}
  end

  defp return_to_proxy(error) do
    error
  end
end
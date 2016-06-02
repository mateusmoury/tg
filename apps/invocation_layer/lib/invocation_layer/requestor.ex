defmodule InvocationLayer.Requestor do

  def invoke({host, port}, {moduleName, functionName, args}) do
    case MessagingLayer.ClientRequestHandler.connect(host, port) do
      {:ok, socket} ->
        handle_communication(socket, moduleName, functionName, args)
      error ->
        error
    end
  end

  defp handle_communication(socket, moduleName, functionName, args) do
    marshalledMessage = InvocationLayer.Marshaller.marshall({moduleName, functionName, args})
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
    {:ok, InvocationLayer.Marshaller.unmarshall(data)}
  end

  defp return_to_proxy(error) do
    error
  end
end
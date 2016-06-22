defmodule InvocationLayer.Requestor do

  def invoke({host, port}, {mod_name, func_name, args}) do
    case MessagingLayer.ClientRequestHandler.connect(host, port) do
      {:ok, socket} ->
        handle_communication(socket, mod_name, func_name, args)
      error ->
        IO.puts error
        error
    end
  end

  defp handle_communication(socket, mod_name, func_name, args) do
    marshalled_message = MessagingLayer.Marshaller.marshall({mod_name, func_name, args})
    response_data =
      case MessagingLayer.ClientRequestHandler.send_message(socket, marshalled_message) do
        :ok ->
          MessagingLayer.ClientRequestHandler.receive_message(socket)
        error ->
          error
      end
    return_to_proxy(response_data)
  end

  defp return_to_proxy({:ok, data}) do
    {:ok, MessagingLayer.Marshaller.unmarshall(data)}
  end

  defp return_to_proxy(error) do
    error
  end
end
defmodule InvocationLayer.Invoker do
  
  def invoke(port) do
    MessagingLayer.ServerRequestHandler.listen(port, self)
    manage_connections
  end

  def manage_connections do
    receive do
      {:new_connection, handler_pid} ->
        send handler_pid, :receive

      {:received, handler_pid, data} ->
        reply =
          data
          |> MessagingLayer.Marshaller.unmarshall
          |> call_function
          |>  MessagingLayer.Marshaller.marshall
        send handler_pid, {:send, reply}

      {:sent, handler_pid} ->
        send handler_pid, :close
    end
    manage_connections
  end

  def call_function({mod_name, func_name, args}) do
    apply(mod_name, func_name, args)
  end
end
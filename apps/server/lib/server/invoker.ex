defmodule Server.Invoker do

  def process_request(byteArray) do
    byteArray
    |> Server.Marshaller.unmarshall
    |> call_function
    |> Server.Marshaller.marshall
  end

  defp call_function({functionName, args}) do
    apply(Server.Application, String.to_atom(functionName), args)
  end
end
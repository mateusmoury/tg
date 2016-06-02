defmodule NamingService.Invoker do

  def process_request(byteArray) do
    byteArray
    |> NamingService.Marshaller.unmarshall
    |> call_function
    |> NamingService.Marshaller.marshall
  end

  defp call_function({functionName, args}) do
    apply(NamingService.LookupTable, String.to_atom(functionName), args)
  end
end
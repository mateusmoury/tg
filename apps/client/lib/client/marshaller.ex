defmodule Client.Marshaller do

  def marshall(_functionName, args) do
    :erlang.term_to_binary(args)
  end

  def unmarshall(byteArray) do
    :erlang.binary_to_term(byteArray)
  end
end
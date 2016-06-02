defmodule Client.Marshaller do

  def marshall(functionName, args) do
    :erlang.term_to_binary({functionName, args})
  end

  def unmarshall(byteArray) do
    :erlang.binary_to_term(byteArray)
  end
end
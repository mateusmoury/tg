defmodule InvocationLayer.Marshaller do

  def marshall(request) do
    :erlang.term_to_binary(request)
  end

  def unmarshall(byteArray) do
    :erlang.binary_to_term(byteArray)
  end
end
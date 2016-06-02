defmodule Server.Marshaller do

  def marshall(result) do
    :erlang.term_to_binary(result)
  end

  def unmarshall(byteArray) do
    :erlang.binary_to_term(byteArray)
  end
end
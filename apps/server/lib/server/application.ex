defmodule Server.Application do

  def pmap(collection, func) do
    me = self
    collection
    |> Enum.map(fn elem -> spawn_link(fn -> send me, {self, func.(elem)} end) end)
    |> Enum.map(fn pid -> receive do {^pid, result} -> result end end)
  end

  def map(collection, func) do
    Enum.map(collection, func)
  end
end
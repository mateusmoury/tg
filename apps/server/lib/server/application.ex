defmodule Server.Application do

  def arithmetic_op(x, y, func) do
    func.(x,y)
  end
end
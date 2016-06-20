defmodule Utils do

  def fib(0), do: 0
  def fib(1), do: 1
  def fib(2), do: 1
  def fib(n), do: fib(n-1) + fib(n-2)

  def sq(n), do: n * n
end

defmodule Server.Application do

  def arithmetic_op(x, y, func) do
    func.(x,y)
  end

  def parallel_prime_numbers(numbers_range, num_threads) do
    me = self
    first..last = numbers_range
    sz = (last - first + 1) / num_threads

    1..num_threads
    |> Enum.map(fn(x) ->
        spawn_link fn -> (send me, {self, prime_numbers(round((x-1) * sz + 1)..round(x * sz))}) end
      end)
    |> Enum.map(fn(pid) ->
        receive do {^pid, result} -> result end
      end)
    |> List.flatten
  end

  def prime_numbers(numbers_range) do
    Enum.filter(numbers_range, fn(x) -> is_prime(x) end)
  end

  def is_prime(num) do
    Enum.count(1..(round :math.sqrt(num)), fn(x) -> (num != x && rem(num, x) == 0) end) == 1
  end
end
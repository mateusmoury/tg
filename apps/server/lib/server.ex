defmodule Server do
  use Supervisor

  def start(_type, _args) do
    result = {:ok, sup} = Supervisor.start_link(__MODULE__, [])
    start_workers(sup)
    result
  end

  def start_workers(sup) do
    {:ok, invoker_sup} =
      Supervisor.start_child(sup, supervisor(Task.Supervisor, []))
    Supervisor.start_child(sup, worker(Task, [InvocationLayer.Invoker, :invoke, [4040, invoker_sup]]))
  end

  def init(_) do
    supervise [], strategy: :one_for_one
  end
end

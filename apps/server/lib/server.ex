defmodule Server do
  use Supervisor

  @port Application.get_env(:server, :port)

  def start(_type, _args) do
    result = {:ok, sup} = Supervisor.start_link(__MODULE__, [])
    start_workers(sup)
    result
  end

  def start_workers(sup) do
    {:ok, invoker_sup} =
      Supervisor.start_child(sup, supervisor(Task.Supervisor, []))
    Supervisor.start_child(sup, worker(Task, [InvocationLayer.Invoker, :invoke, [@port, invoker_sup]]))
  end

  def init(_) do
    supervise [], strategy: :one_for_one
  end
end

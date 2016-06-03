defmodule Server do
  use Supervisor

  def start(_type, _args) do
    result = {:ok, sup} = Supervisor.start_link(__MODULE__, [])
    start_workers(sup)
    bind_services
    result
  end

  def start_workers(sup) do
    {:ok, invoker_sup} =
      Supervisor.start_child(sup, supervisor(Task.Supervisor, []))
    Supervisor.start_child(sup, worker(Task, [InvocationLayer.Invoker, :invoke, [4040, invoker_sup]]))
  end

  def bind_services do
    naming_service_address = {:localhost, 5050}
    naming_service_bind = {NamingService.LookupTable, :bind, [&is_bitstring/1, &is_tuple/1]}
    remote_bind = InvocationLayer.ClientProxy.generate_function({naming_service_address, naming_service_bind})
    remote_bind.(["add", {{:localhost, 4040}, {Server.Application, :add, [&is_number/1, &is_number/1]}}])
  end

  def init(_) do
    supervise [], strategy: :one_for_one
  end
end

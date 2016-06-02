defmodule Server do

  def start(_type, _args) do
    import Supervisor.Spec

    children = [
      supervisor(Task.Supervisor, [[name: Server.Invoker.TaskSupervisor]]),
      worker(Task, [Server.Invoker, :invoke, [Application.get_env(:server, :port)]])
    ]

    opts = [strategy: :one_for_one, name: Server.Invoker.Supervisor]
    Supervisor.start_link(children, opts)
  end
end

defmodule Server do

  def start(_type, _args) do
    import Supervisor.Spec

    children = [
      supervisor(Task.Supervisor, [[name: Server.RequestHandler.TaskSupervisor]]),
      worker(Task, [Server.RequestHandler, :listen, [Application.get_env(:server, :port)]])
    ]

    opts = [strategy: :one_for_one, name: Server.RequestHandler.Supervisor]
    Supervisor.start_link(children, opts)
  end
end

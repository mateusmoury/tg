defmodule Server do
  use Supervisor

  def start(_type, _args) do
    Supervisor.start_link(__MODULE__, [], name: Server.Supervisor)
  end

  def init(_) do
    supervise [], strategy: :one_for_one
  end
end

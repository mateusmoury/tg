defmodule NamingService do
  use Application

  def start(_type, _args) do
    {:ok, _pid} = NamingService.Supervisor.start_link
  end
end

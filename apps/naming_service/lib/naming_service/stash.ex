defmodule NamingService.Stash do
  use GenServer

  #####
  # External API

  def start_link do
    {:ok, _pid} = GenServer.start_link(__MODULE__, [])
  end

  def save_table(pid, table) do
    GenServer.cast pid, {:save_table, table}
  end

  def get_table(pid) do
    GenServer.call pid, :get_table
  end

  #####
  # GenServer implementation
  def handle_call(:get_table, _from, current_table) do
    {:reply, current_table, current_table}
  end

  def handle_cast({:save_table, table}, _current_table) do
    {:noreply, table}
  end
end
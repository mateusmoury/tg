defmodule NamingService.LookupTable do
  use GenServer

  #####
  # External API

  def start_link(stash_pid) do
    {:ok, _pid} = GenServer.start_link(__MODULE__, stash_pid, name: __MODULE__)
  end

  def lookup(name) do
    GenServer.call __MODULE__, {:lookup, name}
  end

  def bind(name, {location, interface}) do
    GenServer.cast __MODULE__, {:bind, name, location, interface}
  end

  #####
  # GenServer implementation
  def init(stash_pid) do
    current_lookup_table = NamingService.Stash.get_table stash_pid
    {:ok, {current_lookup_table, stash_pid}}
  end

  def handle_call({:lookup, name}, _from, {current_table, stash_pid}) do
    {:reply, Keyword.get(current_table, String.to_atom(name)), {current_table, stash_pid}}
  end

  def handle_cast({:bind, name, location, interface}, {current_table, stash_pid}) do
    {:noreply, {Keyword.put(current_table, String.to_atom(name), {location, interface}), stash_pid}}  
  end

  def terminate(_reason, {current_table, stash_pid}) do
    NamingService.Stash.save_table stash_pid, current_table
  end
end
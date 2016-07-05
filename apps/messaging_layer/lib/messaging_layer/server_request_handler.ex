defmodule MessagingLayer.ServerRequestHandler do
  require Logger

  @acceptors 128
  @timeout 10000

  def listen(port, invoker_id) do
    :ranch.start_listener(:ServerListener, @acceptors, :ranch_tcp, [port: port], MessagingLayer.ServerRequestHandler, [invoker_id])
  end

  def start_link(ref, socket, transport, opts) do
    pid = spawn_link(__MODULE__, :init, [ref, socket, transport, opts])
    {:ok, pid}
  end

  def init(ref, socket, transport, opts) do
    :ok = :ranch.accept_ack(ref)
    [invoker_id | _] = opts
    send invoker_id, {:new_connection, self}
    {time, result} = :timer.tc(&process_request/3, [socket, transport, invoker_id])
    transport.send(socket, result)
    send invoker_id, {:sent, self}
    receive do
      :close ->
        :ok = transport.close(socket)
    end
    Logger.info "#{time}"
  end

  def process_request(socket, transport, invoker_id) do
    receive do
      :receive ->
        {:ok, data} = transport.recv(socket, 0, @timeout)
        send invoker_id, {:received, self, data}
        process_request(socket, transport, invoker_id)

      {:send, data} ->
        data
    end
  end
end

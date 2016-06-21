defmodule Client.CLI do

  @moduledoc """
    Cliente escrito em Elixir para testar o middleware desenvolvido.
    Pode ser executado da seguinte maneira:

    $ ./client --naming-host {naming_ip_address} --naming-port {naming_port} --service {service} --clients {clients_number}

    O naming_host e a naming_port devem conter a localização do serviço de nomes,
    Que é a máquina onde o cliente vai buscar as funções assim que for
    inicializado. O serviço de nomes deve estar disponível no momento da inicialização.

    O parametro naming_host deve ser um endereço ip válido ou localhost, para localizar o serviço de nomes.
    O parametro naming_port deve ser uma porta válida, contendo apenas números, que o serviço de nomes escuta.
    O pametro service deve ser o nome de um servico que o cliente quer utilizar
    O paraemntro clients_number deve ser o numero de clientes a serem executados
  """

  def main(args) do
    args
    |> parse_args
    |> build_paths
  end

  defp parse_args(args) do
    case OptionParser.parse(args) do
      {[help: true], _, _} ->
        :help
      {[naming_host: naming_host, naming_port: naming_port, service: service, clients: clients_number], _, _} ->
        {{parse_host(naming_host), parse_port(naming_port)}, {service, parse_client_number(clients_number)}}
      _ ->
        {:error, :invalid_number_of_args}
    end
  end

  defp parse_host("localhost"), do: {:ok, :localhost}
  defp parse_host(ip_address) do
    ip_address
    |> String.to_char_list
    |> :inet.parse_address
  end

  defp parse_port(port) do
    if valid_integer(port) do
      elem(Integer.parse(port), 0)
    else
      :port_error
    end
  end

  defp valid_integer(port) do
    String.length(port) != 0 && Regex.match?(~r/^[0-9]*$/, port)
  end

  defp parse_client_number(clients_number) do
    if valid_integer(clients_number) do
      elem(Integer.parse(clients_number), 0)
    else
      :clients_number_error
    end
  end

  defp build_paths(:help) do
    IO.puts @moduledoc
    System.halt(0)
  end

  defp build_paths({:error, :invalid_number_of_args}) do
    IO.puts "Erro! Número inválido de argumentos. Use a opção --help para saber como usar o executavel"
  end

  defp build_paths({{_, :port_error}, _}) do
    IO.puts "Erro! Porta do serviço de nomes está inválida."
    System.halt(0)
  end

  defp build_paths({{:error, _}, _}) do
    IO.puts "Erro! Hostname inválido para o serviço de nomes."
  end

  defp build_paths({{{:ok, naming_host}, naming_port}, {service, clients_number}}) do
    naming_service_address = {naming_host, naming_port}
    naming_service_lookup = {NamingService.LookupTable, :lookup, [&is_bitstring/1]}
    lookup = InvocationLayer.ClientProxy.remote_function({naming_service_address, naming_service_lookup})
    apply(__MODULE__, String.to_atom(service), [lookup, clients_number])
  end

  def pmap(lookup, clients_number) do
    pmap_description = check_validity("pmap", lookup.(["pmap"]))
    pmap_func = InvocationLayer.ClientProxy.remote_function(pmap_description)
    me = self
    Enum.each(1..clients_number, fn(_) ->
      spawn(fn -> 
        send(me, {:answer, :timer.tc(pmap_func, [[Enum.to_list(1..50), &Utils.sq/1]])})
      end) 
    end)
    {answers, _} = receive_answers(clients_number, [], [])
    acc =
      answers
      |> Enum.map(fn {time, _} -> time end)
      |> Enum.reduce(fn(x, acc) -> x + acc end)
    IO.puts(length(answers))
    IO.puts(acc / length(answers))
  end

  def map(lookup, clients_number) do
    map_description = check_validity("map", lookup.(["map"]))
    map_func = InvocationLayer.ClientProxy.remote_function(map_description)
    me = self
    Enum.each(1..clients_number, fn(_) ->
      spawn(fn ->
        send(me, {:answer, :timer.tc(map_func, [[Enum.to_list(1..50), &Utils.sq/1]])})
      end)
    end)
    {answers, _} = receive_answers(clients_number, [], [])
    acc =
      answers
      |> Enum.map(fn {time, _} -> time end)
      |> Enum.reduce(fn(x, acc) -> x + acc end)
    IO.puts(length(answers))
    IO.puts(acc / length(answers))
  end

  def receive_answers(number_of_concurrents, answers, failures) do
    receive do
      {:answer, {time, {:ok, ans}}} ->
        if number_of_concurrents > 1 do
          receive_answers(number_of_concurrents - 1, [{time / 1000000, ans} | answers], failures)
        else
          {[{time / 1000000, ans} | answers], failures}
        end

      {:answer, {time, {:error, error}}} ->
        if number_of_concurrents > 1 do
          receive_answers(number_of_concurrents - 1, answers, [{time / 1000000, error} | failures])
        else
          {answers, [{time / 1000000, error} | failures]}
        end
    end
  end

  def check_validity(name, {:ok, desc}) do
    IO.puts "Função #{name} captada com sucesso no serviço de nomes"
    desc
  end

  def check_validity(name, {:error, _}) do
    IO.puts "Erro! Não foi possivel usar o serviço #{name}"
    System.halt(0)
  end
end
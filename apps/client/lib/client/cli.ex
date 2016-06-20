defmodule Client.CLI do

  @moduledoc """
    Cliente escrito em Elixir para testar o middleware desenvolvido.
    Pode ser executado da seguinte maneira:

    $ ./client --naming-host {naming_ip_address} --naming-port {naming_port} --service {service}

    O naming_host e a naming_port devem conter a localização do serviço de nomes,
    Que é a máquina onde o cliente vai buscar as funções assim que for
    inicializado. O serviço de nomes deve estar disponível no momento da inicialização.

    O parametro naming_host deve ser um endereço ip válido ou localhost, para localizar o serviço de nomes.
    O parametro naming_port deve ser uma porta válida, contendo apenas números, que o serviço de nomes escuta.
    O pametro service deve ser o nome de um servico que o cliente quer utilizar
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
      {[naming_host: naming_host, naming_port: naming_port, service: service], _, _} ->
        {{parse_host(naming_host), parse_port(naming_port)}, service}
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
    if valid_port(port) do
      elem(Integer.parse(port), 0)
    else
      :port_error
    end
  end

  defp valid_port(port) do
    String.length(port) != 0 && Regex.match?(~r/^[0-9]*$/, port)
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

  defp build_paths({{{:ok, naming_host}, naming_port}, service}) do
    naming_service_address = {naming_host, naming_port}
    naming_service_lookup = {NamingService.LookupTable, :lookup, [&is_bitstring/1]}
    lookup = InvocationLayer.ClientProxy.remote_function({naming_service_address, naming_service_lookup})
    apply(__MODULE__, String.to_atom(service), [lookup])
  end

  def pmap(lookup) do
    pmap_description = check_validity("pmap", lookup.(["pmap"]))
    pmap_func = InvocationLayer.ClientProxy.remote_function(pmap_description)
    {time, {:ok, result}} = :timer.tc(pmap_func, [[[35, 36, 37, 38], &Utils.fib/1]])
    IO.inspect(result, char_lists: false)
    IO.puts time / 1000000
  end

  def map(lookup) do
    map_description = check_validity("map", lookup.(["map"]))
    map_func = InvocationLayer.ClientProxy.remote_function(map_description)
    {time, {:ok, result}} = :timer.tc(map_func, [[[35, 36, 37, 38], &Utils.fib/1]])
    IO.inspect(result, char_lists: false)
    IO.puts time / 1000000
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
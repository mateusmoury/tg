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

  def add(lookup) do
    add_description = check_validity(lookup.(["add"]))
    add_func = InvocationLayer.ClientProxy.remote_function(add_description)
    IO.puts(add_func.([3, 4]))
  end

  def check_validity({:ok, desc}), do: desc
  def check_validity({:error, _}) do
    IO.puts "Erro! Não foi possivel usar o serviço add"
    System.halt(0)
  end
end
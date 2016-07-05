defmodule Client.CLI do

  @moduledoc """
    Cliente escrito em Elixir para testar o middleware desenvolvido. Pode ser usado para executar dois experimentos diferentes.
    O primeiro experimento utiliza a função de Operação Aritmética e varia o número de clientes para ver como o middleware
    se comporta quando aumenta o número de conexões paralelas. Para executar esse experimento basta executar:

    $ ./client --naming-host {naming_ip_address} --naming-port {naming_port} --service arithmetic_op --clients {clients_number}

    O naming_host e a naming_port devem conter a localização do serviço de nomes,
    Que é a máquina onde o cliente vai buscar as funções assim que for
    inicializado. O serviço de nomes deve estar disponível no momento da inicialização.

    O parametro naming_host deve ser um endereço ip válido ou localhost, para localizar o serviço de nomes.
    O parametro naming_port deve ser uma porta válida, contendo apenas números, que o serviço de nomes escuta.
    O parametro service deve ser o nome de um servico. No caso do experimento, o serviço é o arithmetic_op
    O parametro clients_number deve ser o numero de clientes a serem executados de forma paralela. (2, 4, ... 128)

    Já o segundo experimento utiliza a função Números Primos para verificar qual é o ganho em se paralelizar uma função remota,
    dependo da sua granularidade, em termos do tempo médio de resposta aos clientes. Por isso, o número é fixado em 16 clientes
    e o que varia é o tamanho do intervalo da função. Para executar:


    $ ./client --naming-host {naming_ip_address} --naming-port {naming_port} --service {service_name} --range {interval_range}

    O naming_host e a naming_port devem conter a localização do serviço de nomes,
    Que é a máquina onde o cliente vai buscar as funções assim que for
    inicializado. O serviço de nomes deve estar disponível no momento da inicialização.

    O parametro naming_host deve ser um endereço ip válido ou localhost, para localizar o serviço de nomes.
    O parametro naming_port deve ser uma porta válida, contendo apenas números, que o serviço de nomes escuta.
    O parametro service_name deve ser o nome do servico. No caso do experimento, escolhe-se entre:
      - prime_numbers: Versão não paralelizada
      - parallel_prime_numbers: Versão paralelizada
    O parametro interval_range deve o tamanho do intervalo no qual a função será aplicada. Basta passa o último número do
    intervalo, que sempre começará em 1.
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
        {{parse_host(naming_host), parse_port(naming_port)}, {service, parse_client_or_range(clients_number)}}
      {[naming_host: naming_host, naming_port: naming_port, service: service, range: range], _, _} ->
        {{parse_host(naming_host), parse_port(naming_port)}, {service, parse_client_or_range(range)}}
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

  defp parse_client_or_range(clients_number) do
    if valid_integer(clients_number) do
      elem(Integer.parse(clients_number), 0)
    else
      :clients_or_range_number_error
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

  defp build_paths({{{:ok, naming_host}, naming_port}, {service, clients_or_range}}) do
    naming_service_address = {naming_host, naming_port}
    naming_service_lookup = {NamingService.LookupTable, :lookup, [&is_bitstring/1]}
    lookup = InvocationLayer.ClientProxy.remote_function({naming_service_address, naming_service_lookup})
    apply(__MODULE__, String.to_atom(service), [lookup, clients_or_range])
  end

  def arithmetic_op(lookup, clients_number) do
    arithmetic_op_description = check_validity("arithmetic_op", lookup.(["arithmetic_op"]))
    arithmetic_op_func = InvocationLayer.ClientProxy.remote_function(arithmetic_op_description)
    run_multiple_clients(arithmetic_op_func, clients_number, [3, 5, &Utils.mult/2])
    {success, failure} = receive_answers(clients_number * 5000, 0, 0)
    IO.puts("Quantidade de invocações bem sucedidas: #{success}")
    IO.puts("Quantidade de invocações mal sucedidas: #{failure}")
  end

  def parallel_prime_numbers(lookup, range) do
    parallel_prime_numbers_desc = check_validity("parallel_prime_numbers", lookup.(["parallel_prime_numbers"]))
    parallel_prime_numbers_func = InvocationLayer.ClientProxy.remote_function(parallel_prime_numbers_desc)
    run_multiple_clients(parallel_prime_numbers_func, 16, [1..range, 32])
    {success, failure} = receive_answers(16 * 5000, 0, 0)
    IO.puts("Quantidade de invocações bem sucedidas: #{success}")
    IO.puts("Quantidade de invocações mal sucedidas: #{failure}")
  end

  def prime_numbers(lookup, range) do
    prime_numbers_desc = check_validity("prime_numbers", lookup.(["prime_numbers"]))
    prime_numbers_func = InvocationLayer.ClientProxy.remote_function(prime_numbers_desc)
    run_multiple_clients(prime_numbers_func, 16, [1..range])
    {success, failure} = receive_answers(16 * 5000, 0, 0)
    IO.puts("Quantidade de invocações bem sucedidas: #{success}")
    IO.puts("Quantidade de invocações mal sucedidas: #{failure}")
  end

  def run_multiple_clients(func, clients_number, args) do
    me = self
    Enum.each(1..clients_number, fn(_) ->
      spawn(fn ->
        Enum.each(1..5000, fn(_) ->
          send(me, {:answer, func.(args)})
        end)
      end)
    end)
  end

  def receive_answers(number_of_concurrents, answers, failures) do
    receive do
      {:answer, {:ok, _}} ->
        if number_of_concurrents > 1 do
          receive_answers(number_of_concurrents - 1, answers + 1, failures)
        else
          {answers + 1, failures}
        end

      {:answer, {:error, _}} ->
        if number_of_concurrents > 1 do
          receive_answers(number_of_concurrents - 1, answers, failures + 1)
        else
          {answers, failures + 1}
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
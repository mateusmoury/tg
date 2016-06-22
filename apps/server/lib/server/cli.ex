defmodule Server.CLI do

  @moduledoc """
    Servidor Elixir que roda em cima de um middleware RPC. Quando iniciado,
    escuta suas requisições numa porta definida pelo usuário.
    Pode ser executado da seguinte maneira:

    $ ./server --port {server_port} --naming-host {naming_ip_address} --naming-port {naming_port}

    O naming_host e a naming_port devem conter a localização do serviço de nomes,
    Que é a máquina onde o servidor vai cadastrar suas funções assim que for
    inicializado. O serviço de nomes deve estar disponível no momento da inicialização

    O parametro server_port deve ser uma porta válida para o servidor que está sendo inicalizado escutar requisições.
    O parametro naming_host deve ser um endereço ip válido ou localhost, para localizar o serviço de nomes.
    O parametro naming_port deve ser uma porta válida, contendo apenas números, que o serviço de nomes escuta.
  """

  def main(args) do
    args
    |> parse_args
    |> build_paths

    :timer.sleep :infinity
  end

  defp parse_args(args) do
    case OptionParser.parse(args) do
      {[help: true], _, _} ->
        :help
      {[port: port, naming_host: naming_host, naming_port: naming_port], _, _} ->
        {parse_port(port), {parse_host(naming_host), parse_port(naming_port)}}
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
    IO.puts "Erro! Número inválido de argumentos. Use a opção --help para saber como usar o executável."
    System.halt(0)
  end

  defp build_paths({:port_error, _}) do
    IO.puts "Erro! Porta inválida para escutar requisições neste servidor."
    System.halt(0)
  end

  defp build_paths({_, {{:error, _}, _}}) do
    IO.puts "Erro! Hostname inválido para o serviço de nomes. Escreva um endereço IP válido."
    System.halt(0)
  end

  defp build_paths({_, {_, :port_error}}) do
    IO.puts "Erro! Porta inválida para se comunicar com o serviço de nomes. Forneça uma porta válida."
    System.halt(0)
  end

  defp build_paths({port, {{:ok, naming_host}, naming_port}}) do
    start_workers(port)
    bind_services(port, naming_host, naming_port)
  end

  defp start_workers(port) do
    import Supervisor.Spec

    Supervisor.start_child(Server.Supervisor, worker(Task, [InvocationLayer.Invoker, :invoke, [port]]))
  end

  defp bind_services(port, naming_host, naming_port) do
    naming_service_address = {naming_host, naming_port}
    naming_service_bind = {NamingService.LookupTable, :bind, [&is_bitstring/1, &is_tuple/1]}
    remote_bind = InvocationLayer.ClientProxy.remote_function({naming_service_address, naming_service_bind})
    {:ok, [{server_ip, _, _}, _]} = :inet.getif()

    ## Adding services
    check_validity(
      "arithmetic_op",
      remote_bind.(["arithmetic_op", {
        {server_ip, port},
        {Server.Application, :arithmetic_op, [&is_number/1, &is_number/1, &is_function/1]}
      }])
    )

    check_validity(
      "parallel_prime_numbers",
      remote_bind.(["parallel_prime_numbers", {
        {server_ip, port},
        {Server.Application, :parallel_prime_numbers, [&Range.range?/1, &is_number/1]}
      }])
    )

    check_validity(
      "prime_numbers",
      remote_bind.(["prime_numbers", {
        {server_ip, port},
        {Server.Application, :prime_numbers, [&Range.range?/1]}
      }])
    )
  end

  defp check_validity(name, {:error, _}) do
    IO.puts "Erro! Não conseguiu cadastrar função #{name} no serviço de nomes!"
    System.halt(0)
  end

  defp check_validity(name, resp = {:ok, _}) do
    IO.puts "Função #{name} adicionada com sucesso ao serviço de nomes"
    resp
  end
end
defmodule NamingService.CLI do
  @moduledoc """
    Esse servidor implementa o serviço de nomes de um middleware RPC.
    Ele guarda uma lookup table, que servidores externos podem acessar através das funções
    bind e lookup. Pode ser executado da seguinte maneira:

    $ ./naming_service --port {server_port}

    Onde server_port é a porta que o serviço de nomes vai escutar requisições.
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
      {[port: port], _, _} ->
        parse_port(port)
      _ ->
        {:error, :invalid_number_of_args}
    end
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

  defp build_paths(:port_error) do
    IO.puts "Erro! Porta inválida para escutar requisições neste servidor."
    System.halt(0)
  end

  defp build_paths(port) do
    {:ok, _pid} = NamingService.Supervisor.start_link(port)
  end
end
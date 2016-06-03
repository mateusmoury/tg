defmodule Server.CLI do

  @port Application.get_env(:server, :port)

  def main(args) do
    args
    |> parse_args
    |> bind_services

    :timer.sleep :infinity
  end

  defp parse_args(args) do
    case OptionParser.parse(args) do
      {[host: host, port: port], _, _} ->
        {parse_host(host), parse_port(port)}
      _ ->
        {:error, :invalid_arguments}
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
      :error
    end
  end

  defp valid_port(port) do
    String.length(port) != 0 && Regex.match?(~r/^[0-9]*$/, port)
  end

  defp bind_services({:error, _}) do
    IO.puts "Error! Invalid arguments"
    System.halt(0)
  end

  defp bind_services({{:error, :einval}, _port}) do
    IO.puts "Error! Invalid IP Address for Naming Service"
    System.halt(0)
  end

  defp bind_services({_, :error}) do
    IO.puts "Error! Invalid port"
    System.halt(0)
  end

  defp bind_services({{:ok, host}, port}) do
    naming_service_address = {host, port}
    naming_service_bind = {NamingService.LookupTable, :bind, [&is_bitstring/1, &is_tuple/1]}
    remote_bind = InvocationLayer.ClientProxy.generate_function({naming_service_address, naming_service_bind})

    ## Adding services
    remote_bind.(["add", {{:localhost, @port}, {Server.Application, :add, [&is_number/1, &is_number/1]}}])
  end
end
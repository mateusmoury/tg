defmodule InvocationLayer.ClientProxy do

  def remote_function({{host, port}, {mod_name, func_name, args_checker}}) do
    fn args ->
      if length(args) != length(args_checker) do
        {:error, :invalid_number_of_arguments}
      else
        if type_check(args, args_checker) do
          InvocationLayer.Requestor.invoke({host, port}, {mod_name, func_name, args})
        else
          {:error, :invalid_arguments_types}
        end
      end
    end
  end

  defp type_check([], []), do: true
  defp type_check([], [_hd | _]), do: false
  defp type_check([_hd | _], []), do: false
  defp type_check([arg | tail_args], [arg_checker | tail_args_checker]) do
    arg_checker.(arg) && type_check(tail_args, tail_args_checker)
  end
end
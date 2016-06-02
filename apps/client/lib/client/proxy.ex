defmodule Client.Proxy do

  def generate_function({{host, port}, functionName}) do
    fn args ->
      Client.Requestor.invoke({host, port}, functionName, args)
    end
  end
end
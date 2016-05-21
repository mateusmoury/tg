defmodule RequestHandlerTest do
  use ExUnit.Case
  doctest Client

  import Client.RequestHandler

  test "Connection refused when trying to connect to disabled port" do
    assert connect(:localhost, 1010) == {:error, :econnrefused}
  end

  test "Time out when trying to connect to host that doens't answer" do
    assert connect(:"1.2.3.4", 4040) == {:error, :timeout}
  end

  test "When server is listening" do
    {:ok, _} = :gen_tcp.listen(
      5050,
      [:binary, active: false, reuseaddr: true]
    )

   assert elem(connect(:localhost, 5050), 0) == :ok
  end
end

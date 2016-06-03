# ExMiddleware

É necessário ter Elixir instalado na máquina.

Para utilizar:

1. Acesse o app do NamingService: $ cd apps/naming_service
2. Ative-o: $ iex -S mix
3. Abra uma nova aba no terminal
4. Acesse o app do Server: $ cd apps/server
5. Ative-o: $ iex -S mix
6. Todas as funções atualmente implementadas no server já estão cadastradas no NamingService a partir desse momento.
6. Abra uma nova aba no terminal
7. Acesse o app do InvocationLayer: $ cd apps/invocation_layer
8. Ative-o: $ iex -S mix
9. Nessa aba, dentro do iex, você pode requisitar a função lookup do serviço de nomes, assim como pegar os serviços remotos.
10. $ lookup = InvocationLayer.ClientProxy.generate_function({{:localhost, 5050}, {NamingService.LookupTable, :lookup,       [&is_bitstring/1, &is_tuple/1]}})
11. $ {:ok, add_prop} = lookup.(["add"]) # Esse comando, por exemplo, vai retornar o endereço e a interface da função add.
12. $ add = InvocationLayer.ClientProxy.generate_function(add_prop)
13. $ add.([3, 4]) # = 7
14. $ add.([5,10]) # = 15

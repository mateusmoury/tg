# ExMiddleware

É necessário ter Elixir instalado na máquina.

Para utilizar:

1. Acesse o app do NamingService: $ cd apps/naming_service
2. Rode o executável do serviço de nomes com o pariametro help e aprenda a utilizá-lo: $ ./naming_service --help
3. Abra uma nova aba no terminal
4. Acesse o app do Server: $ cd apps/server
5. Rode o executável do servidor com o parâmetro help e aprenda a utilizá-lo: $ ./server --help
6. As funções implementadas no server serão cadastradas no serviço de nomes quando o executável do servidor rodar.
7. Abra uma nova aba no terminal
8. Acesse o app do InvocationLayer: $ cd apps/invocation_layer
9. Ative-o: $ iex -S mix
10. Nessa aba, dentro do iex, você pode requisitar a função lookup do serviço de nomes, assim como pegar os serviços remotos.

### Exemplo
Se tudo estiver sendo executado no localhost e o servidor de nomes estiver na porta 5050: 
```elixir
lookup = InvocationLayer.ClientProxy.generate_remote_function(
  {{:localhost, 5050}, 
  {NamingService.LookupTable, :lookup, [&is_bitstring/1]}}
)

{:ok ,add_description} = lookup.(["add"]) # Obtendo endereço e interface da função remota que atende pelo serviço "add"
add = InvocationLayer.ClientProxy.generate_remote_function(add_description) # ClientProxy cria função que abstrai invocação remota
add.([3,4]) # Operação remota acontece de forma transparente.

```

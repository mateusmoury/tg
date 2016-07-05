# ExMiddleware

É necessário ter Elixir instalado na máquina: http://elixir-lang.org/install.html
Ao entrar no diretório do projeto, instale as dependências: 


$ mix deps.get

$ mix deps.compile

## Para executar os experimentos de paralelismo:

1. Acesse o app do NamingService: $ cd apps/naming_service
2. Rode o executável do serviço de nomes com o parametro help e aprenda a utilizá-lo: $ ./naming_service --help
3. Abra uma nova aba no terminal
4. Acesse o app do Server: $ cd apps/server
5. Rode o executável do servidor com o parâmetro help e aprenda a utilizá-lo: $ ./server --help
6. As funções implementadas no server serão cadastradas no serviço de nomes quando o executável do servidor rodar.
7. Abra uma nova aba no terminal
8. Acesse o app do Cliente: $ cd apps/client
9. Rode o executável do cliente com o parâmetro help e aprenda a utilizá-lo: $ ./client --help
10. Os logs do servidor, que dizem quanto ele demorou para responder cada cliente, foi usado para os resultados.


## Para executar o experimento de tolerância a falhas.

1. Repita os passos 1,2 e 3 da abordagem anterior.
2. Na aba nova do terminal, acesse o app da InvocationLayer: $ cd apps/invocation_layer
3. Rode o modo interativo de elixir: iex -S mix
4. Execute o código descrito abaixo e observe os logs do serviço de nomes na primeira aba aberta.

Para o serviço de nomes na porta 5050: 

```elixir
naming_service_loc = {:localhost, 5050} # Serviço de nomes
bind_loc = {NamingService.LookupTable, :bind, [&is_bitstring/1, &is_tuple/1]} # Localização da função bind dentro do SN.
dest_loc = {NamingService.LookupTable, :destroy, []} # Localização da função destroy dentro do SN.
fake_function_server_loc = {:fake_host, :fake_port} # Falsa localização do servidor da Fake Function
fake_function_loc = {Fake.Module, :fake_function, []} # Falsa localização da Fake function dentro do servidor
bind = InvocationLayer.ClientProxy.remote_function({naming_service_loc, bind_loc}) # bind como func. local
dest = InvocationLayer.ClientProxy.remote_function({naming_service_loc, dest_loc}) # destroy como func. local
bind.(["Fake Function", {fake_function_server_loc, fake_function_loc}]) # Cadastro da fake function
dest.([]) # Destruicao do servico de nomes
lookup_loc = {NamingService.LookupTable, :lookup, [&is_bitstring/1]} # Localização da função lookup dentro do SN.
lookup = InvocationLayer.ClientProxy.remote_function({naming_service_loc, lookup_loc}) # lookup como func. local
lookup.(["Fake Function"]) # Checagem da existencia da Fake Function cadastrada na tabela de serviços.
```

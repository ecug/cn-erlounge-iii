-module(messenger_app).
-export([
  app_loop/2, % main()
  rpc/2,
  start_server/0, start_server/1,
  stop_server/0,
  update_server/1
]).

rpc(Name, Args) ->
    Name ! {self(), Args},
    receive
      {_From, Result} -> Result
    end.

app_loop(Mod, User_List) ->
    receive
	{update, NewMod} ->
		app_loop(NewMod, User_List);
	{From, Args} ->
		%所有handle的接口应返回一个维护过的UserList
		{Result, User_List2} = Mod:handle(Args, User_List),
		%向客户机(消息发出者)返回包括Result值的消息
		From ! {messenger, Result},
		app_loop(Mod, User_List2);
	{stop} ->
		exit(normal);
	_Else  ->
		% clear unknow messages
		io:format("~p~n in messenger else", [_Else]),
		app_loop(Mod, User_List)
    end.

%%% Start the server
start_server() ->
    start_server(messenger).

start_server(Mod) ->
    register(messenger, spawn(?MODULE, app_loop, [Mod, []])).

%%% Stop the server
stop_server() ->
    messenger ! {stop}.

%%% Hot update
update_server(Mod) ->
    messenger ! {update, Mod}.
-module(messenger_cli).
-import(messenger_app, [rpc/2]).
-export([
  client/2, % main()
  logon/1, logoff/0,
  message/2
]).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%% Change the function below to return the name of the node where the
%%% messenger server runs
%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
server_node() ->
    messenger@AIMINGPAD.

%
%process_id() ->
%    messenger.
%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%%  for messenger client
%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% User Commands
logon(Name) ->
    case whereis(mess_client) of 
        undefined ->
            register(mess_client, 
                     spawn(?MODULE, client, [server_node(), Name]));
        _ -> already_logged_on
    end.

logoff() ->
    mess_client ! logoff.

message(ToName, Message) ->
    case whereis(mess_client) of % Test if the client is running
        undefined ->
            not_logged_on;
        _ -> mess_client ! {message_to, ToName, Message},
             ok
end.


%%% The client process which runs on each server node
client(Server_Node, Name) ->
    %%% {messenger, Server_Node} ! {self(), logon, Name},
    rpc({messenger, Server_Node} , {self(), logon, Name}),
    await_result(),
    client(Server_Node).

client(Server_Node) ->
    receive
        logoff ->
            rpc({messenger, Server_Node} , {self(), logoff}),
            exit(normal);
        {message_to, ToName, Message} ->
            rpc({messenger, Server_Node} , {self(), message_to, ToName, Message}),
            await_result();
        {message_from, FromName, Message} ->
            io:format("Message from ~p: ~p~n", [FromName, Message])
    end,
    client(Server_Node).

%%% wait for a response from the server
await_result() ->
    % From = {process_id(), server_node()},
    receive
        {messenger, stop, Why} -> % Stop the client 
            io:format("~p~n", [Why]),
            exit(normal);
        {messenger, What} ->  % Normal response
            io:format("~p~n", [What])
    end.

-module(messenger_m).
-export([handle/2]).

%% change a_process_loop to a rpc/handle func.
%%   server(Mod, User_List)
%%    -->
%%   handle(Args, User_List)
handle(Args, User_List) ->
    io:format("handled arguments: ~p~n", [Args]),
    case Args of
      {From, logon, Name} ->
            {ok, server_logon(From, Name, User_List)};
      {From, logoff} ->
            {ok, server_logoff(From, User_List)};
      {From, message_to, To, Message} ->
            io:format("list is now: ~p~n", [User_List]),
            server_transfer(From, To, Message, User_List),
            {ok, User_List};
      {_From, user_list} ->
            {User_List, User_List};
      _Else ->
            {unknow_cmd, User_List}
    end.

%%% Server adds a new user to the user list
server_logon(From, Name, User_List) ->
    %% check if logged on anywhere else
    case lists:keymember(Name, 2, User_List) of
        true ->
            From ! {messenger, stop, user_exists_at_other_node},  %reject logon
            User_List;
        false ->
            From ! {messenger, logged_on},
            [{From, Name} | User_List]        %add user to the list
    end.

%%% Server deletes a user from the user list
server_logoff(From, User_List) ->
    lists:keydelete(From, 1, User_List).


%%% Server transfers a message between user
server_transfer(From, To, Message, User_List) ->
    %% check that the user is logged on and who he is
    case lists:keysearch(From, 1, User_List) of
        false ->
            From ! {messenger, stop, you_are_not_logged_on};
        {value, {From, Name}} ->
            server_transfer(From, Name, To, Message, User_List)
    end.
%%% If the user exists, send the message
server_transfer(From, Name, To, Message, User_List) ->
    %% Find the receiver and send the message
    case lists:keysearch(To, 2, User_List) of
        false ->
            From ! {messenger, receiver_not_found};
        {value, {ToPid, To}} ->
            ToPid ! {message_from, Name, Message}, 
            From ! {messenger, sent} 
    end.

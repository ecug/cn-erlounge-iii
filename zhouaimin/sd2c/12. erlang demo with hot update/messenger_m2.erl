-module(messenger_m2).
-export([handle/2]).
-define(DEPEND_MODULE, messenger).

%% hook chain
handle(Args, User_List) ->
    case Args of
      {_From, user_list} ->
            {User_List, User_List};
      _Else ->
            ?DEPEND_MODULE:handle(Args, User_List)
    end.
-module(messenger_m).
-export([handle/2]).

-import(preformat, [preformat/1]).
-import(rfc4627, [encode/1]).
% -import(json, [encode/1]).

-define(DEPEND_MODULE, messenger).
-define(OLD_HANDLE, {?DEPEND_MODULE, handle}).

%% hook chain
handle(Args, User_List) ->
    case Args of
      {_From, user_list} ->
        % {encode({obj, preformat(User_List)}), User_List};
        {encode(preformat(User_List)), User_List};
      _Else ->
            %%% ?DEPEND_MODULE:handle(Args, User_List)
	    ?OLD_HANDLE(Args, User_List)
    end.
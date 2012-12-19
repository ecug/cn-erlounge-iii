%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%% for test
%%% > preformat:preformat([{self(), "hello"}, {self(), "hi"}]).
%%% > preformat:preformat({obj, [{self(), "hello"}, {self(), "hi"}]}).
%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

-module(preformat).
-export([preformat/1]).

conv({K,V}=T) when is_tuple(T)-> {conv(K), conv(V)};
conv(S) when is_list(S)-> list_to_bitstring(S);
% if you want convert pid to string at here.
%   conv(P) when is_pid(P) -> conv(pid_to_list(P));
conv(V) -> V.

preformat(User_List) ->
  lists:map(fun(Elem)->conv(Elem) end, User_List).
rpc(Name, Args) ->
    Name ! {self(), Args},
    receive
      {_From, Result} -> Result   % From is PID:messenger always, if success, Result is ok, or data.
    end.

server_node() ->
    'messenger@aimingoo-desktop'.

%
%process_id() ->
%    messenger.
%

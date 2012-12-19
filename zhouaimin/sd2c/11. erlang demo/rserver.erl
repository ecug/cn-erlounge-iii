-module(rserver). 
-author('gregoire.lejeune@free.fr'). 
-compile(export_all). 
 
start_server(Port) -> 
  {ok, ListenSocket} = gen_tcp:listen(Port, [binary, {packet, 0}, {active, false}]), 
  io:format("** Server Started~n"), 
  loop(ListenSocket). 
 
loop(ListenSocket) -> 
  case gen_tcp:accept(ListenSocket) of 
    {ok, Socket} -> 
      spawn(fun() -> 
        handle_connection(Socket) 
      end), 
      loop(ListenSocket); 
    {error, Reason} -> 
      io:format("Error: ~p~n", [Reason]) 
  end. 
 
handle_connection(Socket) -> 
  try communication(Socket) 
  catch 
    error:Reason -> 
      {gen_tcp:send(Socket, io_lib:format("Error: ~p~n", [Reason]))} 
  end, 
  ok = gen_tcp:close(Socket). 
 
communication(Socket) -> 
  {ok, Binary} = gen_tcp:recv(Socket, 0), 
  % Do some stuff with Binary 
  {ok, [R|_Z]} = regexp:split( binary_to_list(Binary), "\r\n" ), 
  {ok, [_M,F,_P]} = regexp:split( R, " " ), 
  case F =:= "/" of 
    true -> File = "index.html"; 
    false -> {ok, File, _} = regexp:gsub(F, "^/", "") 
  end, 
  {WD, JJ, MD, AA, HH, MN, SS} = get_local_time(), 
  case file:read_file(File) of 
    {ok, Html} -> 
      gen_tcp:send(Socket, io_lib:format("HTTP/1.1 200 OK~nDate: ~s, ~p ~s ~p ~p:~p:~p GMT~nServer: Rserver/1.0.0~n~n~s", [WD, JJ, MD, AA, HH, MN, SS, binary_to_list(Html)])); 
    {error, _} -> 
      gen_tcp:send(Socket, io_lib:format("HTTP/1.1 404 Not Found~nDate: ~s, ~p ~s ~p ~p:~p:~p GMT~nServer: Rserver/1.0.0~n~n~s", [WD, JJ, MD, AA, HH, MN, SS, "<html><body>404 error</body></html>"])) 
  end.   
 
%%%%%%%%%%%%%%%%%%%%%%%%%%% 
  
day(0) -> "Mon"; 
day(1) -> "Tue"; 
day(2) -> "Wed"; 
day(3) -> "Thu"; 
day(4) -> "Fri"; 
day(5) -> "Sat"; 
day(6) -> "Sun". 
 
month(1) -> "Jan"; 
month(2) -> "Feb"; 
month(3) -> "Mar"; 
month(4) -> "Apr"; 
month(5) -> "May"; 
month(6) -> "Jun"; 
month(7) -> "Jul"; 
month(8) -> "Aug"; 
month(9) -> "Sep"; 
month(10) -> "Oct"; 
month(11) -> "Nov"; 
month(12) -> "Dec". 
 
get_local_time() -> 
  D = calendar:local_time(), 
  [{{AA,MM,JJ},{HH,MN,SS}}] = calendar:local_time_to_universal_time_dst(D), 
  WD = day(calendar:day_of_the_week(AA, MM, JJ)), 
  MD = month(MM), 
  {WD, JJ, MD, AA, HH, MN, SS}.
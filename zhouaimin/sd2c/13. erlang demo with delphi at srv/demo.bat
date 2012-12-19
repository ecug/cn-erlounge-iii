@echo off
if "%1"=="-clear" goto CLEAR
md srv
md cli1

@echo on
@echo code:add_patha("./ebin"). > .erlang

@echo messenger_app:start_server().    >  srv/.erlang
@echo messenger_cli:logon("aimingoo"). >> srv/.erlang
@echo messenger_cli:logon("cat").      >  cli1/.erlang

@echo io:format("startup:: logon as aimingoo.~n~n", []). >> srv/.erlang
@echo io:format("startup:: logon as cat.~n~n", []).      >> cli1/.erlang
@echo off

start /d srv  cmd /c erl -sname messenger -pa ../ebin
start /wait /d cli1 cmd /c erl -sname cli1 -pa ../ebin

:CLEAR
if exist .erlang del .erlang
if exist cli1    rd /q /s cli1
if exist srv     rd /q /s srv

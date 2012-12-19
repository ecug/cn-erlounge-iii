@echo off
if "%1"=="-clear" goto CLEAR
md srv
md cli1
md cli2

@echo on
@echo code:add_patha("./ebin"). > .erlang

@echo messenger:start_server().    > srv/.erlang
@echo messenger:logon("aimingoo"). > cli1/.erlang
@echo messenger:logon("cat").      > cli2/.erlang

@echo io:format("startup:: logon as aimingoo.~n~n", []). >> cli1/.erlang
@echo io:format("startup:: logon as cat.~n~n", []).      >> cli2/.erlang
@echo off

start /d srv  cmd /c erl -sname messenger -pa ../ebin
start /d cli1 cmd /c erl -sname cli1 -pa ../ebin
start /wait /d cli2 cmd /c erl -sname cli2 -pa ../ebin

:CLEAR
if exist .erlang del .erlang
if exist cli2    rd /q /s cli2
if exist cli1    rd /q /s cli1
if exist srv     rd /q /s srv

@if "%1"=="/C" goto DOIT

@if not exist ebin @md ebin
@for %%f in (*.erl) do @CALL %0 /C %%f %1 %2 %3
@GOTO DONE

:DOIT
@echo Compile %2 ...
@erlc -o ./ebin %2 %3 %4 %5

:DONE
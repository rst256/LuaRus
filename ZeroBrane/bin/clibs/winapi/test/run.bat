@echo off

echo -------- Translate en to ru ---------
..\lua53 ..\transl.lua ru 1.c 1ru.c

echo -------- Translate ru to en ---------
..\lua53 ..\transl.lua en 1ru.c 1en.c

echo ---- Compare 1ru.c and 1ru.ans -----
FC 1ru.c 1ru.ans
IF %ERRORLEVEL% EQU 0 GOTO cmp2_l

:cmp2_l
echo ------ Compare 1.c and 1en.c -------
FC 1.c 1en.c
IF %ERRORLEVEL% EQU 0 GOTO ok_l

echo Failed 
GOTO end_l

:ok_l
echo    Ok
:end_l
pause

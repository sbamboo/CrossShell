set ver=1.0
set name=Win11.regchange



:code
echo off
title %name% (v.%ver%)
set pathr=
set regvalname=
set regtochangetoval= 
cls
echo This program is a tool to change reg values.
echo [%name%] : Write the reg path to the DWORD you want to change.
set /p pathr= ^> 
echo.
echo [%name%] : Write the name of the reg key/DWORD you want to change.
set /p regvalname= ^> 
echo.
echo [%name%] : Write the value to set for the new key/DWORD
set /p regtochangetoval= ^> 
echo. 
echo Path=%pathr%
echo Name=%regvalname%
echo Value=%regtochangetoval%
echo.
echo Everything correct???
set /p correctask=[Y/N/E]? 
if "%correttask%" EQU "N" goto :code
if "%correttask%" EQU "E" goto :eof

echo.
echo.
echo Changing...
reg add %pathr% /v %regvalname% /t REG_DWORD /d %regtochangetoval% /f
echo ...
echo.
if "%ERRORLEVEL%" NEQ "0" echo Change Failed!   && pause && goto :new20
echo Changed "name%" to "%regtochangetoval%" successfully!   && pause && goto :new20
:new20
goto :code
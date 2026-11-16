@echo off
chcp 65001 >nul
title Cline (D: Izole Profili)
echo ============================================================
echo   CLINE BASLATILIYOR (IZOLE D: PROFILI)
echo ============================================================
echo.

set "CODE_CMD=D:\Programs\Microsoft VS Code\bin\code.cmd"
set "USER_DATA=D:\Cline-Development\Isolated-Profile\user-data"
set "EXT_DIR=D:\Cline-Development\Isolated-Profile\extensions"

if exist "%CODE_CMD%" (
    start "" "%CODE_CMD%" --user-data-dir "%USER_DATA%" --extensions-dir "%EXT_DIR%"
) else (
    start "" code
)

exit

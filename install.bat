@echo off
chcp 65001 >nul
title Cline + Ollama Pascal Fix Kurulum Aracı
echo ============================================================
echo   CLINE + OLLAMA PASCAL (GTX 1060) KURULUM ARACI
echo ============================================================
echo.

set "SCRIPT_DIR=%~dp0"
set "VSIX_PATH=%SCRIPT_DIR%bin\Cline-4.1.26-WireResponse-Capture.vsix"
set "ALT_VSIX=%SCRIPT_DIR%Cline-4.1.26-WireResponse-Capture.vsix"
set "CODE_CMD=D:\Programs\Microsoft VS Code\bin\code.cmd"
set "USER_DATA=D:\Cline-Development\Isolated-Profile\user-data"
set "EXT_DIR=D:\Cline-Development\Isolated-Profile\extensions"

if not exist "%VSIX_PATH%" (
    if exist "%ALT_VSIX%" (
        set "VSIX_PATH=%ALT_VSIX%"
    ) else if exist "E:\Utilities\Cline-4.1.26-WireResponse-Capture.vsix" (
        set "VSIX_PATH=E:\Utilities\Cline-4.1.26-WireResponse-Capture.vsix"
    )
)

if not exist "%VSIX_PATH%" (
    echo [HATA] Kurulum VSIX paketi bulunamadi!
    echo Aranan yol: %VSIX_PATH%
    pause
    exit /b 1
)

echo [1/3] VSIX Kurulum paketi dogrulandi:
echo       %VSIX_PATH%
echo.

if exist "%CODE_CMD%" (
    echo [2/3] D: Surucusundeki izole VS Code bulundu, kuruluyor...
    call "%CODE_CMD%" --user-data-dir "%USER_DATA%" --extensions-dir "%EXT_DIR%" --install-extension "%VSIX_PATH%" --force
) else (
    echo [2/3] Standart sistem VS Code 'code' komutu ile kuruluyor...
    where code >nul 2>nul
    if %ERRORLEVEL% EQU 0 (
        call code --install-extension "%VSIX_PATH%" --force
    ) else (
        echo [UYARI] VS Code sistem yolunda bulunamadi.
        echo Lutfen VS Code acip Eklentiler (Extensions) kismindan 'Install from VSIX' secin.
    )
)

echo.
echo [3/3] Baslaticilar hazirlaniyor...
echo ============================================================
echo KURULUM BASARIYLA TAMAMLANDI!
echo.
echo Modelleri D: surucusunde calistirmak icin: start-ollama.bat
echo Cline'i izole baslatmak icin:             start-cline.bat
echo ============================================================
pause

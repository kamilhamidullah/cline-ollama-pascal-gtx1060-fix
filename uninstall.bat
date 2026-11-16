@echo off
chcp 65001 >nul
title Cline Guvenli Kaldirma (Uninstall) Araci
echo ============================================================
echo   CLINE (D SURUCUSU) GUVENLI KALDIRMA ARACI
echo ============================================================
echo.
echo Bu islem:
echo 1. VS Code icindeki Cline eklentisini guvenle kaldirir.
echo 2. Masaustundeki 'Cline (D Surucusu).bat' kisayolunu siler.
echo.
echo [GUVENLIK GARANTISI]:
echo - D:\Ollama\Models altindaki modelleriniz SILINMEZ.
echo - Kod projeleriniz ve calisma dosyalariniz ASLA SILINMEZ.
echo.

set /p ONAY="Kaldirma islemini baslatmak istiyor musunuz? (E/H): "
if /i not "%ONAY%"=="E" (
    echo [IPTAL] Islem kullanici tarafindan iptal edildi.
    pause
    exit /b 0
)

echo.
echo [1/3] Calisan VS Code veya bagli surecler kontrol ediliyor...
set "CODE_CMD=D:\Programs\Microsoft VS Code\bin\code.cmd"
set "USER_DATA=D:\Cline-Development\Isolated-Profile\user-data"
set "EXT_DIR=D:\Cline-Development\Isolated-Profile\extensions"

if exist "%CODE_CMD%" (
    echo [2/3] D: Surucusundeki izole VS Code profilinden eklenti kaldiriliyor...
    call "%CODE_CMD%" --user-data-dir "%USER_DATA%" --extensions-dir "%EXT_DIR%" --uninstall-extension saoudrizwan.claude-dev >nul 2>nul
) else (
    where code >nul 2>nul
    if %ERRORLEVEL% EQU 0 (
        echo [2/3] Sistem VS Code profilinden eklenti kaldiriliyor...
        call code --uninstall-extension saoudrizwan.claude-dev >nul 2>nul
    )
)

echo [3/3] Masaustu kisayolu kaldiriliyor...
set "DESKTOP_BAT=%USERPROFILE%\Desktop\Cline (D Sürücüsü).bat"
set "ONEDRIVE_BAT=%USERPROFILE%\OneDrive\Desktop\Cline (D Sürücüsü).bat"

if exist "%DESKTOP_BAT%" del /f /q "%DESKTOP_BAT%" >nul 2>nul
if exist "%ONEDRIVE_BAT%" del /f /q "%ONEDRIVE_BAT%" >nul 2>nul

echo.
echo ============================================================
echo KALDIRMA ISLEMI GUVELE TAMAMLANDI!
echo - Cline eklentisi ve masaustu baslaticisi temizlendi.
echo - D:\Ollama\Models klasorundeki yapay zeka modelleriniz korundu.
echo ============================================================
pause

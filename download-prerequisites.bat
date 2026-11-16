@echo off
chcp 65001 >nul
title Onkosul Indirme ve Baglanti Yardimcisi
echo ============================================================
echo   ONKOSULLAR RESMI INDIRME YARDIMCISI
echo ============================================================
echo.
echo Bu betik, resmi ve guvenli uretici baglantilarini sunar:
echo.
echo [1] NVIDIA GTX 1060 Pascal Surucusu (572.70+) Indirme Sayfasi
echo [2] Git for Windows Resmi Indirme Sayfasi
echo [3] Bun Runtime (Windows x64) Resmi Sayfasi
echo [4] Ollama for Windows Resmi Indirme Sayfasi
echo [5] Ollama ile qwen2.5-coder:7b Modelini Indir (Terminalde)
echo [0] Cikis
echo.
set /p SECIM="Lutfen bir secim yapin (0-5): "

if "%SECIM%"=="1" (
    start https://www.nvidia.com/en-us/drivers/details/280050/
    goto son
)
if "%SECIM%"=="2" (
    start https://git-scm.com/download/win
    goto son
)
if "%SECIM%"=="3" (
    start https://bun.sh/
    goto son
)
if "%SECIM%"=="4" (
    start https://ollama.com/download
    goto son
)
if "%SECIM%"=="5" (
    set "OLLAMA_MODELS=D:\Ollama\Models"
    echo Model D:\Ollama\Models altina indiriliyor...
    ollama pull qwen2.5-coder:7b
    pause
    goto son
)

:son
exit

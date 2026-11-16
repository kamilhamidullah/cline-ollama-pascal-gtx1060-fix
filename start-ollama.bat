@echo off
chcp 65001 >nul
title Ollama (D: Modelleri Ile Calisiyor)
echo ============================================================
echo   OLLAMA BASLATICISI (D: SURUCUSU MODEL DEPOSU)
echo ============================================================
echo.

set "OLLAMA_MODELS=D:\Ollama\Models"
set "OLLAMA_HOST=127.0.0.1:11434"

echo Model Klasoru: %OLLAMA_MODELS%
echo API Adresi:    http://%OLLAMA_HOST%
echo.
echo Ollama baslatiliyor... Bu pencereyi kapatmayiniz!
echo.

ollama serve
pause

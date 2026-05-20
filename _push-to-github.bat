@echo off
chcp 65001 >nul
title AI Fluency 학습 허브 - GitHub Upload
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0_push-to-github.ps1"

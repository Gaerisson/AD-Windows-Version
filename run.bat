@echo off
SET mypath=%~dp0
cd %mypath:~0,-1%

powershell -ExecutionPolicy Bypass -File get_winver.ps1

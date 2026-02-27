@echo off
setlocal EnableExtensions

echo [hello] Example app started.
echo [hello] Computer: %COMPUTERNAME%
echo [hello] User: %USERNAME%
echo [hello] Timestamp: %DATE% %TIME%

if not "%~1"=="" (
  echo [hello] Arguments: %*
) else (
  echo [hello] No arguments supplied.
)

echo [hello] Example app finished successfully.
exit /b 0


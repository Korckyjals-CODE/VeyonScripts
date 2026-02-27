@echo off
setlocal EnableExtensions EnableDelayedExpansion

if "%~1"=="" (
  echo Usage: %~nx0 ^<app-id^> [args...]
  exit /b 64
)

set "APP_ID=%~1"
shift

set "BASE_DIR=%~dp0"
set "APPS_DIR=%BASE_DIR%apps"
set "APP_ROOT=%APPS_DIR%\%APP_ID%"
set "CURRENT_FILE=%APP_ROOT%\current.txt"

if not exist "%APP_ROOT%\" (
  echo [runner] App not found: %APP_ID%
  exit /b 2
)

if not exist "%CURRENT_FILE%" (
  echo [runner] Missing current version pointer: %CURRENT_FILE%
  exit /b 3
)

set /p APP_VERSION=<"%CURRENT_FILE%"
if "%APP_VERSION%"=="" (
  echo [runner] Empty current version pointer for app: %APP_ID%
  exit /b 4
)

set "VERSION_DIR=%APP_ROOT%\%APP_VERSION%"
set "MANIFEST_PATH=%VERSION_DIR%\manifest.json"

if not exist "%VERSION_DIR%\" (
  echo [runner] Version folder not found: %VERSION_DIR%
  exit /b 5
)

if not exist "%MANIFEST_PATH%" (
  echo [runner] Manifest not found: %MANIFEST_PATH%
  exit /b 6
)

set "ENTRYPOINT="
for /f "usebackq tokens=1,* delims==" %%A in (`powershell -NoProfile -ExecutionPolicy Bypass -Command "$m = Get-Content -Raw -LiteralPath $env:MANIFEST_PATH | ConvertFrom-Json; if (-not $m.entrypoint) { exit 9 }; Write-Output ('entrypoint=' + $m.entrypoint)"`) do (
  if /i "%%A"=="entrypoint" set "ENTRYPOINT=%%B"
)

if "%ENTRYPOINT%"=="" (
  echo [runner] Manifest is missing entrypoint: %MANIFEST_PATH%
  exit /b 7
)

set "ENTRYPOINT_PATH=%VERSION_DIR%\%ENTRYPOINT%"
if not exist "%ENTRYPOINT_PATH%" (
  echo [runner] Entrypoint not found: %ENTRYPOINT_PATH%
  exit /b 8
)

set "LOG_DIR=%BASE_DIR%logs"
if not exist "%LOG_DIR%\" mkdir "%LOG_DIR%"

for /f %%T in ('powershell -NoProfile -ExecutionPolicy Bypass -Command "Get-Date -Format ''yyyyMMdd-HHmmss''"') do set "STAMP=%%T"
set "LOG_FILE=%LOG_DIR%\%APP_ID%-%STAMP%.log"

for %%I in ("%ENTRYPOINT_PATH%") do set "ENTRY_EXT=%%~xI"
set "RUN_EXIT=0"

if /i "%ENTRY_EXT%"==".cmd" (
  call "%ENTRYPOINT_PATH%" %* >> "%LOG_FILE%" 2>&1
  set "RUN_EXIT=%ERRORLEVEL%"
) else if /i "%ENTRY_EXT%"==".bat" (
  call "%ENTRYPOINT_PATH%" %* >> "%LOG_FILE%" 2>&1
  set "RUN_EXIT=%ERRORLEVEL%"
) else if /i "%ENTRY_EXT%"==".ps1" (
  powershell -NoProfile -ExecutionPolicy Bypass -File "%ENTRYPOINT_PATH%" %* >> "%LOG_FILE%" 2>&1
  set "RUN_EXIT=%ERRORLEVEL%"
) else if /i "%ENTRY_EXT%"==".exe" (
  "%ENTRYPOINT_PATH%" %* >> "%LOG_FILE%" 2>&1
  set "RUN_EXIT=%ERRORLEVEL%"
) else (
  echo [runner] Unsupported entrypoint extension: %ENTRY_EXT%
  exit /b 9
)

echo [runner] app=%APP_ID% version=%APP_VERSION% exit=%RUN_EXIT% log="%LOG_FILE%"
exit /b %RUN_EXIT%


@echo off
setlocal EnableExtensions EnableDelayedExpansion

for %%I in ("%~dp0..") do set "PACKAGE_ROOT=%%~fI"
set "TARGET_ROOT=%USERPROFILE%\VeyonTools"
set "TARGET_APPS=%TARGET_ROOT%\apps"
set "TARGET_LOGS=%TARGET_ROOT%\logs"
set "SRC_RUNNER=%PACKAGE_ROOT%\runner\runner.cmd"
set "SRC_APPS=%PACKAGE_ROOT%\apps"

echo [bootstrap] Package root: %PACKAGE_ROOT%
echo [bootstrap] Target root: %TARGET_ROOT%

if not exist "%TARGET_ROOT%\" mkdir "%TARGET_ROOT%"
if not exist "%TARGET_APPS%\" mkdir "%TARGET_APPS%"
if not exist "%TARGET_LOGS%\" mkdir "%TARGET_LOGS%"

if not exist "%SRC_RUNNER%" (
  echo [bootstrap] Missing runner source file: %SRC_RUNNER%
  exit /b 11
)

copy /Y "%SRC_RUNNER%" "%TARGET_ROOT%\runner.cmd" >nul
if errorlevel 1 (
  echo [bootstrap] Failed to copy runner.cmd
  exit /b 12
)

if exist "%SRC_APPS%\" (
  xcopy "%SRC_APPS%\*" "%TARGET_APPS%\" /E /I /Y >nul
  if errorlevel 4 (
    echo [bootstrap] Failed to copy apps payload.
    exit /b 13
  )
) else (
  echo [bootstrap] Apps source not found, skipping copy.
)

for /d %%A in ("%TARGET_APPS%\*") do (
  set "APP_DIR=%%~fA"
  set "LATEST="
  for /f "delims=" %%V in ('dir /b /ad "!APP_DIR!" ^| sort /R') do (
    if /i not "%%V"=="current" if not defined LATEST set "LATEST=%%V"
  )
  if defined LATEST (
    > "!APP_DIR!\current.txt" echo !LATEST!
    echo [bootstrap] Set current for %%~nxA to !LATEST!
  )
)

echo [bootstrap] Install/update complete.
exit /b 0

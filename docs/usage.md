# Veyon Scripts Usage

This document provides copy/paste commands for classroom operators using Veyon.

## 1) Transfer Package to Managed Computers

Transfer the repository contents (or packaged equivalent) to each student account, for example:

- `%USERPROFILE%\VeyonScripts\`

If you use a different folder name, update the install command accordingly.

## 2) Install or Update Tools (run via Veyon Start application)

Veyon Start requires PowerShell wrappers for reliable execution; cmd commands with arguments can fail.

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "& (Join-Path $env:USERPROFILE 'VeyonScripts\bootstrap\install-or-update.cmd')"
```

Expected result:

- `%USERPROFILE%\VeyonTools\runner.cmd`
- `%USERPROFILE%\VeyonTools\apps\...`
- `%USERPROFILE%\VeyonTools\logs\`

## 3) Run an App (daily classroom use)

Run the example app:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "& (Join-Path $env:USERPROFILE 'VeyonTools\runner.cmd') hello"
```

Run with arguments:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "& (Join-Path $env:USERPROFILE 'VeyonTools\runner.cmd') hello --mode demo"
```

## 4) Add or Update an App Version

1. Add new version payload to package source, for example:
   - `apps\hello\1.1.0\...`
2. Transfer updated package via Veyon File Transfer.
3. Run install/update command again:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "& (Join-Path $env:USERPROFILE 'VeyonScripts\bootstrap\install-or-update.cmd')"
```

The bootstrap script updates each app's `current.txt` pointer to the highest version folder name.

## 5) Troubleshooting Quick Checks

- App not found:
  - Confirm `%USERPROFILE%\VeyonTools\apps\<app-id>\` exists.
- Wrong version running:
  - Check `%USERPROFILE%\VeyonTools\apps\<app-id>\current.txt`.
- Entrypoint errors:
  - Check `manifest.json` has `entrypoint` and file exists.
- Runtime failures:
  - Open latest log in `%USERPROFILE%\VeyonTools\logs\`.

## 6) Recommended Stable Command Pattern

For any app, use:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "& (Join-Path $env:USERPROFILE 'VeyonTools\runner.cmd') <app-id> [args]"
```

Keep this command stable; update app payloads behind the scenes.


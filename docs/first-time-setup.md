# Veyon Scripts First-Time Setup

This guide explains how to deploy this repository to managed computers for the first time.

## Goal

Create two folders on each managed computer:

- `%USERPROFILE%\VeyonScripts\` (transferred package source)
- `%USERPROFILE%\VeyonTools\` (installed runtime used by Veyon Start application)

After first setup, daily execution should use the PowerShell-wrapped runner command (see Step 4 and Daily use).

## Step 1: Prepare the package on teacher PC

Use one of these approaches:

- Recommended: create `VeyonScripts.zip`.
- Alternative: transfer the unzipped `VeyonScripts` folder directly.

If using ZIP, either layout works:

- **Layout A (preferred):** ZIP contains top-level `VeyonScripts\...`.
- **Layout B:** ZIP root directly contains `bootstrap`, `runner`, `apps`, `docs`.

## Step 2: Transfer package with Veyon File Transfer

Transfer to each managed computer's `%USERPROFILE%` folder (default Veyon File Transfer destination).

Examples of target paths:

- `%USERPROFILE%\VeyonScripts.zip` (default)
- `%USERPROFILE%\Downloads\VeyonScripts.zip` (if you chose Downloads manually)
- `%USERPROFILE%\Desktop\VeyonScripts.zip` (if you chose Desktop manually)

If you transfer unzipped content, ensure the final folder is:

- `%USERPROFILE%\VeyonScripts\...`

## Step 3: Install/update tools using Start application

Veyon Start executes PowerShell reliably; cmd commands with arguments can fail. All commands below use PowerShell.

### Option A (ZIP transfer)

If the ZIP was transferred to `%USERPROFILE%` (default), run this in Veyon Start application:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "$zip = Join-Path $env:USERPROFILE 'VeyonScripts.zip'; $root = Join-Path $env:USERPROFILE 'VeyonScripts'; Expand-Archive -LiteralPath $zip -DestinationPath $env:USERPROFILE -Force; if (-not (Test-Path (Join-Path $root 'bootstrap\install-or-update.cmd'))) { New-Item -ItemType Directory -Path $root -Force | Out-Null; foreach ($name in 'bootstrap','runner','apps','docs') { $src = Join-Path $env:USERPROFILE $name; if (Test-Path $src) { Move-Item -Path $src -Destination $root -Force } } }; & (Join-Path $root 'bootstrap\install-or-update.cmd')"
```

If your ZIP is in another folder, update the `$zip` value accordingly (for example `Join-Path $env:USERPROFILE 'Downloads\VeyonScripts.zip'`).

This command handles both ZIP layouts:

- ZIP already has `VeyonScripts\...` (Layout A).
- ZIP extracted folders into profile root (Layout B), then moves them into `%USERPROFILE%\VeyonScripts\`.

### Option B (already unzipped transfer)

If `%USERPROFILE%\VeyonScripts\` already exists, run:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "& (Join-Path $env:USERPROFILE 'VeyonScripts\bootstrap\install-or-update.cmd')"
```

### Post-extract quick check

Before running tests, confirm this file exists:

- `%USERPROFILE%\VeyonScripts\bootstrap\install-or-update.cmd`

If missing, your ZIP layout/path is wrong. Re-run Option A with the correct ZIP location.

## Step 4: Run the first test app

In the Veyon Run program dialog, paste this command (PowerShell invokes the runner with arguments):

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "& (Join-Path $env:USERPROFILE 'VeyonTools\runner.cmd') hello"
```

Optional argument test:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "& (Join-Path $env:USERPROFILE 'VeyonTools\runner.cmd') hello --mode demo"
```

## Step 5: Verify success on managed computers

Confirm these exist:

- `%USERPROFILE%\VeyonScripts\bootstrap\install-or-update.cmd`
- `%USERPROFILE%\VeyonTools\runner.cmd`
- `%USERPROFILE%\VeyonTools\apps\hello\current.txt`
- `%USERPROFILE%\VeyonTools\logs\`

Confirm a new log file appears after running `hello`.

## Daily use after first setup

Use only the stable runtime command pattern:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "& (Join-Path $env:USERPROFILE 'VeyonTools\runner.cmd') <app-id> [args]"
```

## Troubleshooting

- **`VeyonScripts` not found**
  - Recheck transfer destination and ZIP extraction path.
  - Use Option A command from Step 3 (it creates/normalizes `%USERPROFILE%\VeyonScripts\`).
- **Files extracted into `%USERPROFILE%` root (not inside `VeyonScripts`)**
  - Run this recovery command in Start application:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "$root = Join-Path $env:USERPROFILE 'VeyonScripts'; New-Item -ItemType Directory -Path $root -Force | Out-Null; foreach ($name in 'bootstrap','runner','apps','docs') { $src = Join-Path $env:USERPROFILE $name; if (Test-Path $src) { Move-Item -Path $src -Destination $root -Force } }"
```

  - Then run:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "& (Join-Path $env:USERPROFILE 'VeyonScripts\bootstrap\install-or-update.cmd')"
```
- **`runner.cmd` not found**
  - Re-run install command from Step 3.
- **App not found**
  - Confirm `%USERPROFILE%\VeyonTools\apps\<app-id>\` exists.
- **No logs created**
  - Verify `%USERPROFILE%\VeyonTools\logs\` exists and rerun app.
- **Logs created outside `VeyonTools` (for example `%USERPROFILE%\logs`)**
  - This usually means a different `runner.cmd` was executed.
  - Find all runner copies:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "Get-ChildItem -Path $env:USERPROFILE -Filter runner.cmd -Recurse -ErrorAction SilentlyContinue | Select-Object -ExpandProperty FullName"
```

  - Reinstall to normalize paths:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "& (Join-Path $env:USERPROFILE 'VeyonScripts\bootstrap\install-or-update.cmd')"
```

  - Run only this command going forward:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "& (Join-Path $env:USERPROFILE 'VeyonTools\runner.cmd') hello"
```

  - Optional cleanup of accidental root-level log folder:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "if (Test-Path (Join-Path $env:USERPROFILE 'logs')) { Remove-Item -Path (Join-Path $env:USERPROFILE 'logs') -Recurse -Force }"
```

  - Optional cleanup of accidentally extracted root-level folders (outside `VeyonScripts`):

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "$folders = 'apps','bootstrap','docs','runner'; foreach ($d in $folders) { $p = Join-Path $env:USERPROFILE $d; if (Test-Path $p) { Remove-Item -Path $p -Recurse -Force } }"
```

  - Run this only after confirming `%USERPROFILE%\VeyonScripts\` has the expected folders.


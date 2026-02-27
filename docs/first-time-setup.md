# Veyon Scripts First-Time Setup

This guide explains how to deploy this repository to managed computers for the first time.

## Goal

Create two folders on each managed computer:

- `%USERPROFILE%\VeyonScripts\` (transferred package source)
- `%USERPROFILE%\VeyonTools\` (installed runtime used by Veyon Start application)

After first setup, daily execution should use `%USERPROFILE%\VeyonTools\runner.cmd`.

## Step 1: Prepare the package on teacher PC

Use one of these approaches:

- Recommended: create `VeyonScripts.zip` containing this repo's folders (`bootstrap`, `runner`, `apps`, `docs`).
- Alternative: transfer the unzipped `VeyonScripts` folder directly.

## Step 2: Transfer package with Veyon File Transfer

Transfer to each managed computer's user profile area (for example `Downloads`).

Examples of likely target paths:

- `%USERPROFILE%\Downloads\VeyonScripts.zip`
- `%USERPROFILE%\Desktop\VeyonScripts.zip`

If you transfer unzipped content, ensure the final folder is:

- `%USERPROFILE%\VeyonScripts\...`

## Step 3: Install/update tools using Start application

### Option A (ZIP transfer)

If the ZIP was transferred to `Downloads`, run this in Veyon Start application:

```cmd
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "Expand-Archive -LiteralPath \"$env:USERPROFILE\Downloads\VeyonScripts.zip\" -DestinationPath \"$env:USERPROFILE\" -Force; & \"$env:USERPROFILE\VeyonScripts\bootstrap\install-or-update.cmd\""
```

If your ZIP is in another folder (for example Desktop), change `Downloads` accordingly.

### Option B (already unzipped transfer)

If `%USERPROFILE%\VeyonScripts\` already exists, run:

```cmd
cmd.exe /c "%USERPROFILE%\VeyonScripts\bootstrap\install-or-update.cmd"
```

## Step 4: Run the first test app

Run:

```cmd
cmd.exe /c "%USERPROFILE%\VeyonTools\runner.cmd hello"
```

Optional argument test:

```cmd
cmd.exe /c "%USERPROFILE%\VeyonTools\runner.cmd hello --mode demo"
```

## Step 5: Verify success on managed computers

Confirm these exist:

- `%USERPROFILE%\VeyonTools\runner.cmd`
- `%USERPROFILE%\VeyonTools\apps\hello\current.txt`
- `%USERPROFILE%\VeyonTools\logs\`

Confirm a new log file appears after running `hello`.

## Daily use after first setup

Use only the stable runtime command pattern:

```cmd
cmd.exe /c "%USERPROFILE%\VeyonTools\runner.cmd <app-id> [args]"
```

## Troubleshooting

- **`VeyonScripts` not found**
  - Recheck transfer destination and ZIP extraction path.
- **`runner.cmd` not found**
  - Re-run install command from Step 3.
- **App not found**
  - Confirm `%USERPROFILE%\VeyonTools\apps\<app-id>\` exists.
- **No logs created**
  - Verify `%USERPROFILE%\VeyonTools\logs\` exists and rerun app.


# Veyon Classroom Script Strategy

This repository is intended to hold tools that can be transferred to student computers and executed repeatedly through Veyon's **Start application** UI.

## Goal

Make deployment and execution predictable:

- **Deploy once or update occasionally** via Veyon File Transfer.
- **Run many times** via one stable command in Veyon's Start application dialog.

## Core Approach

1. Use a fixed per-user install path on managed machines:
   - `%USERPROFILE%\VeyonTools\`
2. Always execute tools through one launcher script (`runner.cmd` or `runner.ps1`).
3. Keep app payloads versioned and immutable.
4. Use manifests to describe each app's entrypoint and runtime behavior.

## Recommended Target Layout on Managed Computers

```text
%USERPROFILE%\VeyonTools\
  runner.cmd
  apps\
    <app-id>\
      <version>\
        ...payload files...
      current\
        ...or a small pointer file...
  logs\
```

## Why This Works Well With Veyon

- Use PowerShell wrappers for Start application—Veyon handles them reliably; cmd commands with arguments can fail.
- Veyon Start application can keep using the same command forever.
- App updates do not require changing teacher-side run commands.
- Rollback is easy by switching a version pointer.
- Logging and troubleshooting become centralized.

## Execution Pattern (Teacher UI)

Use one stable command in Start application:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "Set-Location (Join-Path $env:USERPROFILE 'VeyonTools'); & '.\runner.cmd' <app-id>"
```

With arguments:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "Set-Location (Join-Path $env:USERPROFILE 'VeyonTools'); & '.\runner.cmd' <app-id> --mode quiz"
```

If launching PowerShell payloads inside the runner, use:

```powershell
powershell.exe -ExecutionPolicy Bypass -File "<script-path>" <args>
```

## Deployment and Update Pattern

1. Package files from this repo (runner + app payload + manifest).
2. Transfer package with Veyon File Transfer to user folder.
3. Run bootstrap once to install/update `%USERPROFILE%\VeyonTools`.
4. Use Start application for day-to-day execution.
5. For updates, transfer only new version files and switch `current`.

## Versioning Strategy

- Store versions as immutable folders:
  - `apps/toolA/1.0.0/`
  - `apps/toolA/1.1.0/`
- Do not edit old versions in place.
- Switch active version via a pointer (`current` directory or file).

## Runner Responsibilities

The runner should:

- Resolve app ID to current version.
- Validate entrypoint exists.
- Launch `.cmd`, `.ps1`, `.exe`, etc.
- Capture stdout/stderr to `%USERPROFILE%\VeyonTools\logs\`.
- Return clear exit codes for troubleshooting.

## Suggested Repository Structure

```text
docs/
  veyon-script-strategy.md
bootstrap/
runner/
apps/
  <app-id>/
    <version>/
      manifest.json
      ...payload...
```

## Operational Guidelines

- Keep teacher commands short and copy/paste friendly.
- Test on a standard non-admin student account.
- Prefer wrappers that avoid hard-coded absolute paths.
- Document each app's expected arguments and side effects.
- Keep scripts idempotent when possible for safe reruns.


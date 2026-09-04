# PowerShell Codex Install Test

This repository records hands-on installation and troubleshooting of the Codex CLI in Windows PowerShell and Windows PowerShell ISE.

## Test environment

- Windows PowerShell 5.1
- Codex installed through the Codex Windows app
- Codex CLI alias: `%LOCALAPPDATA%\Microsoft\WindowsApps\codex.exe`
- Version observed on September 4, 2026: `codex-cli 0.144.0-alpha.4`

## Errors observed

Inside PowerShell ISE:

```text
codex : Error: stdout is not a terminal
```

When ISE tried to load the PowerShell profile:

```text
profile.ps1 cannot be loaded because running scripts is disabled on this system
```

## Why this happens

PowerShell ISE has an editor/output pane, but it is not a true interactive terminal (TTY). Codex CLI uses an interactive terminal interface, so it cannot render directly inside the ISE output pane.

The practical solution is to define a `codex` PowerShell function. In normal PowerShell it starts Codex directly. In ISE it opens a normal PowerShell console and starts Codex there.

Windows also includes 64-bit and 32-bit ISE shortcuts. Their execution-policy settings may use separate registry views, so the setup script configures `RemoteSigned` for the current user through both versions of Windows PowerShell.

## Installation

Download this repository, open a normal PowerShell window in its folder, and run:

```powershell
Set-ExecutionPolicy -Scope Process Bypass
.\setup-codex-ise.ps1
```

Close every PowerShell and PowerShell ISE window. Reopen the 64-bit **Windows PowerShell ISE** shortcut—not the shortcut ending in **(x86)**—and enter:

```powershell
codex
```

A separate standard PowerShell console should open with Codex. This handoff is expected because the Codex terminal UI cannot run inside ISE itself.

## Diagnostics used

```powershell
Get-Command codex -All
Get-ExecutionPolicy -List
Test-Path "$env:LOCALAPPDATA\Microsoft\WindowsApps\codex.exe"
```

## Removal

Run:

```powershell
Set-ExecutionPolicy -Scope Process Bypass
.\remove-codex-ise.ps1
```

The scripts affect only the current user and do not change the machine-wide execution policy.

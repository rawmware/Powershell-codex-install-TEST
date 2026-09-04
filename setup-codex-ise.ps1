[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'

$codexExe = Join-Path $env:LOCALAPPDATA 'Microsoft\WindowsApps\codex.exe'
if (-not (Test-Path -LiteralPath $codexExe)) {
    throw "Codex CLI was not found at '$codexExe'. Install or repair the Codex Windows app first."
}

# Configure the native Windows PowerShell registry view.
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned -Force

# Windows PowerShell ISE (x86) uses the 32-bit registry view. Configure it too.
$x86PowerShell = Join-Path $env:SystemRoot 'SysWOW64\WindowsPowerShell\v1.0\powershell.exe'
if (Test-Path -LiteralPath $x86PowerShell) {
    & $x86PowerShell -NoLogo -NoProfile -Command `
        'Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned -Force'
    if ($LASTEXITCODE -ne 0) {
        throw 'Failed to set the 32-bit CurrentUser execution policy.'
    }
}

$profileDirectory = Split-Path -Parent $PROFILE.CurrentUserAllHosts
New-Item -ItemType Directory -Path $profileDirectory -Force | Out-Null

$profileBlock = @'
# BEGIN CODEX ISE LAUNCHER
function codex {
    $codexExe = Join-Path $env:LOCALAPPDATA 'Microsoft\WindowsApps\codex.exe'

    if (-not (Test-Path -LiteralPath $codexExe)) {
        Write-Error "Codex CLI was not found at '$codexExe'."
        return
    }

    if ($null -ne $psISE) {
        $quotedArguments = foreach ($argument in $args) {
            "'" + ([string]$argument).Replace("'", "''") + "'"
        }
        $command = "& '$codexExe' " + ($quotedArguments -join ' ')
        Start-Process -FilePath "$env:SystemRoot\System32\WindowsPowerShell\v1.0\powershell.exe" `
            -ArgumentList @('-NoLogo', '-NoProfile', '-NoExit', '-Command', $command)
        return
    }

    & $codexExe @args
}
# END CODEX ISE LAUNCHER
'@

$profilePath = $PROFILE.CurrentUserAllHosts
$existingProfile = if (Test-Path -LiteralPath $profilePath) {
    Get-Content -Raw -LiteralPath $profilePath
} else {
    ''
}

$pattern = '(?s)# BEGIN CODEX ISE LAUNCHER.*?# END CODEX ISE LAUNCHER\s*'
$preservedProfile = [regex]::Replace($existingProfile, $pattern, '').TrimEnd()
$newProfile = if ($preservedProfile) {
    $preservedProfile + [Environment]::NewLine + [Environment]::NewLine + $profileBlock
} else {
    $profileBlock
}

Set-Content -LiteralPath $profilePath -Value $newProfile -Encoding UTF8

Write-Host "Installed the Codex ISE launcher in: $profilePath"
Write-Host 'Close all PowerShell/ISE windows, reopen 64-bit Windows PowerShell ISE, and type: codex'

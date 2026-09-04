[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$profilePath = $PROFILE.CurrentUserAllHosts

if (-not (Test-Path -LiteralPath $profilePath)) {
    Write-Host 'No all-hosts PowerShell profile exists; nothing to remove.'
    return
}

$content = Get-Content -Raw -LiteralPath $profilePath
$pattern = '(?s)# BEGIN CODEX ISE LAUNCHER.*?# END CODEX ISE LAUNCHER\s*'
$updated = [regex]::Replace($content, $pattern, '').TrimEnd()

if ($updated) {
    Set-Content -LiteralPath $profilePath -Value ($updated + [Environment]::NewLine) -Encoding UTF8
} else {
    Remove-Item -LiteralPath $profilePath
}

Write-Host "Removed the Codex ISE launcher from: $profilePath"

# Run from PowerShell. Does not install software or request Apple credentials.
$ErrorActionPreference = 'Stop'
$Root = Split-Path $PSScriptRoot -Parent
$Ipa = Join-Path $Root 'downloads\RestTimer-resign-required.ipa'
$Manifest = Join-Path $Root 'downloads\SHA256SUMS.txt'
if (!(Test-Path $Ipa) -or !(Test-Path $Manifest)) { throw 'IPA or SHA256SUMS.txt missing. Download the full package.' }
$Expected = ((Get-Content $Manifest | Select-Object -First 1) -split '\s+')[0].ToLowerInvariant()
$Actual = (Get-FileHash $Ipa -Algorithm SHA256).Hash.ToLowerInvariant()
if ($Expected -ne $Actual) { throw 'SHA256 mismatch. Download the package again.' }
Write-Host 'SHA256 OK. This checks file integrity, not code signing.'
Write-Host 'Next: follow docs/windows-iphone.md and sign the IPA with your own Apple account in Sideloadly.'

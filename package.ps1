# Zip the built tools into per-repo release artifacts
# 04/08/2026
#
#   pwsh -File package.ps1                 # one zip per tool, for its own repo's release
#   pwsh -File package.ps1 -Only parser    # just modbldr-tools
#   pwsh -File package.ps1 -Only browser   # just FoxBrowser
#
# One zip PER TOOL, because they are uploaded to separate repos. Takes what
# sync.ps1 already built — it never builds anything itself, so a stale run
# packages stale binaries. Run sync.ps1 first.
param(
    [ValidateSet('both', 'parser', 'browser')][string]$Only = 'both',
    [string]$OutDir
)
$ErrorActionPreference = 'Stop'
$root = $PSScriptRoot
$OutDir = if ($OutDir) { $OutDir } else { $root }

# folder under FoxClaude -> zip name (the repo it belongs to)
$tools = @(
    @{ Key = 'parser';  Dir = 'Fox_parser';  Zip = 'Fox_Parser-tools.zip' }
    @{ Key = 'browser'; Dir = 'FoxBrowser';  Zip = 'FoxBrowser.zip' }
)

foreach ($t in $tools) {
    if ($Only -ne 'both' -and $Only -ne $t.Key) { continue }
    $src = Join-Path $root $t.Dir
    if (-not (Test-Path $src)) { throw "$($t.Dir) is not built — run sync.ps1 first" }

    $out = Join-Path $OutDir $t.Zip
    if (Test-Path $out) { Remove-Item $out -Force }
    Compress-Archive -Path (Join-Path $src '*') -DestinationPath $out -CompressionLevel Optimal

    $mb = (Get-Item $out).Length / 1MB
    $raw = (Get-ChildItem $src -Recurse -File | Measure-Object -Property Length -Sum).Sum / 1MB
    Write-Host ("{0,-24} {1,6:N1} MB  (from {2:N1} MB, {3:N0}% saved)" -f $t.Zip, $mb, $raw, (100 - $mb / $raw * 100))
}

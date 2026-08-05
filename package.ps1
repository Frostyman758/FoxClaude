# Zip the built tools into a release artifact
# 04/08/2026
#
#   pwsh -File package.ps1                 # release.zip with both tools
#   pwsh -File package.ps1 -Only parser    # just modbldr-tools
#   pwsh -File package.ps1 -Only browser   # just FoxBrowser
#
# Takes what sync.ps1 already built — it never builds anything itself, so a stale
# run packages stale binaries. Run sync.ps1 first.
param(
    [ValidateSet('both', 'parser', 'browser')][string]$Only = 'both',
    [string]$Out
)
$ErrorActionPreference = 'Stop'
$root = $PSScriptRoot
$Out = if ($Out) { $Out } else { Join-Path $root 'release.zip' }

$parts = @()
if ($Only -in 'both', 'parser') { $parts += 'Fox_parser' }
if ($Only -in 'both', 'browser') { $parts += 'FoxBrowser' }

foreach ($p in $parts) {
    $dir = Join-Path $root $p
    if (-not (Test-Path $dir)) { throw "$p is not built — run sync.ps1 first" }
}

# Stage rather than zipping in place: the dict folders are shared by name and a
# flat archive would collide them.
$stage = Join-Path ([IO.Path]::GetTempPath()) ("foxclaude_pkg_" + [guid]::NewGuid().ToString('N').Substring(0, 8))
New-Item -ItemType Directory -Force $stage | Out-Null
try {
    foreach ($p in $parts) {
        Copy-Item (Join-Path $root $p) (Join-Path $stage $p) -Recurse -Force
    }
    Copy-Item (Join-Path $root 'README.md') $stage -Force -ErrorAction SilentlyContinue

    if (Test-Path $Out) { Remove-Item $Out -Force }
    Compress-Archive -Path (Join-Path $stage '*') -DestinationPath $Out -CompressionLevel Optimal

    $mb = (Get-Item $Out).Length / 1MB
    $raw = (Get-ChildItem $stage -Recurse -File | Measure-Object -Property Length -Sum).Sum / 1MB
    Write-Host ("{0}  {1:N1} MB  (from {2:N1} MB, {3:N0}% saved)" -f `
        (Split-Path $Out -Leaf), $mb, $raw, (100 - $mb / $raw * 100))
}
finally { Remove-Item $stage -Recurse -Force -ErrorAction SilentlyContinue }

# Refresh the built tools, then commit and push any doc/skill/wiki changes.
# 03/08/2026
#
#   pwsh -File sync.ps1              # rebuild tools + commit + push
#   pwsh -File sync.ps1 -NoBuild     # commit + push only
#   pwsh -File sync.ps1 -NoPush      # local commit only
#
# Nothing is pushed unless an 'origin' remote exists and there is something to
# commit. The built exes stay untracked (see .gitignore) — rebuilding them only
# keeps this folder usable, it never touches git.
param([switch]$NoBuild, [switch]$NoPush)
$ErrorActionPreference = 'Stop'
$root = $PSScriptRoot

function Step($m) { Write-Host "== $m" }

if (-not $NoBuild) {
    $parserRepo = 'C:\rsearch\Fox_parser'
    if (Test-Path $parserRepo) {
        Step 'building modbldr-tools'
        dotnet publish "$parserRepo\MgsvModBldr.Tools.App" -c Release -r win-x64 `
            --self-contained -p:PublishSingleFile=true --nologo | Out-Null
        if ($LASTEXITCODE -ne 0) { throw "modbldr-tools build failed ($LASTEXITCODE)" }
        $exe = "$parserRepo\MgsvModBldr.Tools.App\bin\Release\net10.0\win-x64\publish\modbldr-tools.exe"
        Copy-Item $exe "$root\Fox_parser\modbldr-tools.exe" -Force
        Write-Host "   modbldr-tools.exe refreshed"
    } else { Write-Host "   (no Fox_parser checkout — skipped)" }

    $browserRepo = 'C:\rsearch\FoxBrowser'
    if (Test-Path "$browserRepo\publish.ps1") {
        Step 'building FoxBrowser'
        # publish.ps1 mirrors its release folder here itself.
        pwsh -NoProfile -File "$browserRepo\publish.ps1" -Mirror "$root\FoxBrowser" | Out-Null
        if ($LASTEXITCODE -ne 0) { throw "FoxBrowser publish failed ($LASTEXITCODE)" }
        Write-Host "   FoxBrowser mirrored"
    } else { Write-Host "   (no FoxBrowser checkout — skipped)" }
}

Step 'git'
Push-Location $root
try {
    if (-not (Test-Path "$root\.git")) { throw "not a git repo yet — run: git init" }
    git add -A
    if (git status --porcelain) {
        $stamp = Get-Date -Format 'dd/MM/yyyy HH:mm'
        git commit -q -m "sync $stamp"
        Write-Host "   committed"
    } else {
        Write-Host "   nothing to commit"
    }
    if (-not $NoPush) {
        if (git remote) {
            git push -q origin HEAD
            Write-Host "   pushed"
        } else {
            Write-Host "   no remote — skipped push"
        }
    }
}
finally { Pop-Location }

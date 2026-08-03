# Fix Claude Code's Bash tool on this hardened box.  (run elevated)
#
# Root cause: system-wide Mandatory ASLR ("Force randomization for images",
# ForceRelocateImages = ON) relocates msys-2.0.dll to a different base per process.
# MSYS fork() needs that DLL at the SAME address in parent and child, so every
# forked child dies (0xC0000142 / "Resource temporarily unavailable"), killing the
# Bash tool.
#
# Fix (surgical): exempt every binary in the Git-for-Windows install from ASLR
# (ForceRelocateImages AND BottomUp). ForceRelocateImages lets msys-2.0.dll load at
# its preferred base; disabling BottomUp keeps the cygheap at a stable address so a
# forked child can map its parent's (otherwise: intermittent "cygheap read copy
# failed / Win32 error 299"). Everything ELSE on the box keeps Mandatory ASLR;
# DEP/CFG/SEHOP untouched. Writes HKLM Image File Execution Options (needs admin).
# RE-RUN after a Git update adds new binaries.
$ErrorActionPreference = 'Continue'
$GitRoot = 'C:\Users\Blue\AppData\Local\Programs\Git'
$log     = 'C:\rsearch\FoxClaude\fix-bash-result.txt'
try { Stop-Transcript | Out-Null } catch {}
Start-Transcript -LiteralPath $log -Force | Out-Null

$admin = [Security.Principal.WindowsPrincipal]::new(
    [Security.Principal.WindowsIdentity]::GetCurrent()
).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
Write-Host "elevated=$admin  user=$(whoami)"
if (-not $admin) { Write-Host 'RESULT: NOT ELEVATED'; Stop-Transcript | Out-Null; exit 5 }

$ifeo  = 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options'
$dirs  = @("$GitRoot\usr\bin","$GitRoot\bin","$GitRoot\mingw64\bin","$GitRoot\usr\lib\p11-kit") |
         Where-Object { Test-Path $_ }
$names = Get-ChildItem $dirs -Filter *.exe -File -ErrorAction SilentlyContinue |
         Select-Object -ExpandProperty Name -Unique
Write-Host "found $($names.Count) unique binaries across: $($dirs -join '; ')"

$written = 0
foreach ($n in $names) {
    Set-ProcessMitigation -Name $n -Disable ForceRelocateImages,BottomUp -WarningAction SilentlyContinue -ErrorAction SilentlyContinue
    if (Test-Path -LiteralPath "$ifeo\$n") { $written++ }   # ground truth: the IFEO key now exists
}
Write-Host "IFEO keys present after run: $written / $($names.Count)"
Write-Host "spot-check: cygpath=$(Test-Path "$ifeo\cygpath.exe")  ls=$(Test-Path "$ifeo\ls.exe")  uname=$(Test-Path "$ifeo\uname.exe")"

# Ground-truth verification: a forked child (cygpath) inside a login shell.
$probe = & "$GitRoot\bin\bash.exe" -lc 'echo FORK_OK:$(uname -o):[$(/usr/bin/cygpath -S -w | tr -d "\r\n")]' 2>&1 | Out-String
Write-Host "bash probe: $($probe.Trim())"
$fixed = $probe -match 'FORK_OK:.*\[.+\]'
Write-Host "RESULT: $(if ($fixed) { 'BASH FIXED' } else { 'STILL FAILING' })"
Stop-Transcript | Out-Null
exit ([int](-not $fixed))

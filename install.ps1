# Install the Pocock workflow pack into a target repo.
#   ./install.ps1 -TargetRepo C:\path\to\repo
param(
    [Parameter(Mandatory = $true)]
    [string]$TargetRepo
)

$ErrorActionPreference = 'Stop'
$src = $PSScriptRoot

if (-not (Test-Path (Join-Path $TargetRepo '.git'))) {
    Write-Error "$TargetRepo is not a git repository"
}

# Workflows and commands (pocock-* only — never touch the repo's other files)
New-Item -ItemType Directory -Force (Join-Path $TargetRepo '.archon\workflows') | Out-Null
New-Item -ItemType Directory -Force (Join-Path $TargetRepo '.archon\commands') | Out-Null
Copy-Item (Join-Path $src '.archon\workflows\pocock-*.yaml') (Join-Path $TargetRepo '.archon\workflows') -Force
Copy-Item (Join-Path $src '.archon\commands\pocock-*.md')   (Join-Path $TargetRepo '.archon\commands') -Force

# Skills (v1.1.0 snapshot). Copy, don't symlink — Windows-safe.
New-Item -ItemType Directory -Force (Join-Path $TargetRepo '.claude\skills') | Out-Null
Get-ChildItem (Join-Path $src '.claude\skills') -Directory | ForEach-Object {
    $dest = Join-Path $TargetRepo ".claude\skills\$($_.Name)"
    if (Test-Path $dest) { Remove-Item $dest -Recurse -Force }
    Copy-Item $_.FullName $dest -Recurse
}

Write-Host "Installed: 6 workflows, 10 commands, 18 skills -> $TargetRepo"
Write-Host "Next steps:"
Write-Host "  1. cd $TargetRepo"
Write-Host "  2. archon validate workflows"
Write-Host "  3. archon workflow run pocock-init --no-worktree `"`""

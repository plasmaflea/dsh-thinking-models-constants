# state.ps1 — 常量库状态：仓库信息 + 三库版本 + 与消费方的漂移
# 用法: .\scripts\state.cmd [-Verify] [-SkillsRepo <path>] [-InstallDir <path>]
# 兼容 Windows PowerShell 5.1（本文件须以 UTF-8 with BOM 保存）

param(
    [switch]$Verify,
    [string]$SkillsRepo = 'D:\DeepSeek-levelup\dsh-thinking-models',
    [string]$InstallDir = "$env:USERPROFILE\.dsh\skills"
)

$ErrorActionPreference = 'Continue'
$root = Split-Path -Parent $PSScriptRoot

$libs = @(
    @{ Name = 'knowledge-tree'; Skill = 'forest-hierarchical-backtracking' },
    @{ Name = 'relation-table'; Skill = 'web-association-exhaustive' },
    @{ Name = 'structure-tree'; Skill = 'structure-isomorphism-pointmass-substitution' }
)

function Get-MdHashMap([string]$dir) {
    $map = @{}
    if (-not (Test-Path -LiteralPath $dir)) { return $map }
    Get-ChildItem -LiteralPath $dir -File | Where-Object { $_.Name -like '*.md' } | ForEach-Object {
        $map[$_.Name] = (Get-FileHash -LiteralPath $_.FullName -Algorithm SHA256).Hash
    }
    return $map
}

function Compare-LibAgainst([string]$libDir, [string]$targetDir) {
    $src = Get-MdHashMap $libDir
    $dst = Get-MdHashMap $targetDir
    $issues = @()
    foreach ($k in $src.Keys) {
        if (-not $dst.ContainsKey($k)) { $issues += "missing: $k" }
        elseif ($src[$k] -ne $dst[$k]) { $issues += "differs: $k" }
    }
    foreach ($k in $dst.Keys) {
        if (-not $src.ContainsKey($k)) { $issues += "extra: $k" }
    }
    return $issues
}

Write-Host '=== REPO ===' -ForegroundColor Cyan
Write-Host ("path    : " + $root)
$remote = git -C $root remote get-url origin 2>$null
Write-Host ("remote  : " + $(if ($remote) { $remote } else { '(none)' }))
$branch = git -C $root rev-parse --abbrev-ref HEAD 2>$null
Write-Host ("branch  : " + $(if ($branch) { $branch } else { '(no commits)' }))
$head = git -C $root log -1 --oneline 2>$null
Write-Host ("head    : " + $(if ($head) { $head } else { '(no commits)' }))
$dirty = @(git -C $root status --porcelain 2>$null)
Write-Host ("dirty   : " + $dirty.Count + ' file(s)')
$verFile = Join-Path $root 'VERSION'
Write-Host ("VERSION : " + $(if (Test-Path $verFile) { (Get-Content -LiteralPath $verFile -Raw).Trim() } else { '(missing)' }))

Write-Host ''
Write-Host '=== LIBS ===' -ForegroundColor Cyan
foreach ($lib in $libs) {
    $libDir = Join-Path $root $lib.Name
    $idx = Join-Path $libDir 'index.md'
    $ver = ''
    if (Test-Path -LiteralPath $idx) {
        $head2 = @(Get-Content -LiteralPath $idx -TotalCount 6)
        $line = $head2 | Where-Object { $_ -match '版本\*\*：' } | Select-Object -First 1
        if ($line) { $ver = $line.Trim() }
    }
    $count = 0
    if (Test-Path -LiteralPath $libDir) { $count = @(Get-ChildItem -LiteralPath $libDir -File).Count }
    Write-Host ("{0,-16} files={1,-3} {2}" -f $lib.Name, $count, $ver)
}

Write-Host ''
Write-Host '=== COPIES (repo lib <-> skills repo <-> installed) ===' -ForegroundColor Cyan
$drift = 0
foreach ($lib in $libs) {
    $libDir = Join-Path $root $lib.Name
    $repoTree = Join-Path $SkillsRepo ($lib.Skill + '\tree')
    $instTree = Join-Path $InstallDir ($lib.Skill + '\tree')
    foreach ($pair in @(@{ Label = 'skills-repo'; Dir = $repoTree }, @{ Label = 'installed'; Dir = $instTree })) {
        if (-not (Test-Path -LiteralPath $pair.Dir)) {
            Write-Host ("MISSING {0,-12} {1,-16} {2}" -f $pair.Label, $lib.Name, $pair.Dir) -ForegroundColor Yellow
            $drift++
            continue
        }
        $issues = Compare-LibAgainst $libDir $pair.Dir
        if ($issues.Count -eq 0) {
            Write-Host ("OK      {0,-12} {1,-16}" -f $pair.Label, $lib.Name) -ForegroundColor Green
        } else {
            $drift++
            Write-Host ("DRIFT   {0,-12} {1,-16} {2}" -f $pair.Label, $lib.Name, ($issues -join '; ')) -ForegroundColor Red
        }
    }
}

Write-Host ''
if ($Verify) {
    if ($drift -eq 0) {
        Write-Host 'RESULT: libraries and copies are identical' -ForegroundColor Green
        exit 0
    } else {
        Write-Host ("RESULT: $drift drift item(s) — run scripts\sync.cmd") -ForegroundColor Red
        exit 1
    }
}
Write-Host 'RESULT: overview only (use -Verify to fail on drift)'
exit 0

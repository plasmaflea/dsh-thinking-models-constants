# sync.ps1 — 把三个常量库单向同步到消费方（技能仓库 + 本机安装位）
# 用法: .\scripts\sync.cmd [-Check] [-SkillsRepo <path>] [-InstallDir <path>]
#   -Check  只比对不写盘，有漂移 exit 1
# 兼容 Windows PowerShell 5.1（本文件须以 UTF-8 with BOM 保存）

param(
    [switch]$Check,
    [string]$SkillsRepo = 'D:\DeepSeek-levelup\dsh-thinking-models',
    [string]$InstallDir = "$env:USERPROFILE\.dsh\skills"
)

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot

$libs = @(
    @{ Name = 'knowledge-tree'; Skill = 'forest-hierarchical-backtracking' },
    @{ Name = 'relation-table'; Skill = 'web-association-exhaustive' },
    @{ Name = 'structure-tree'; Skill = 'structure-isomorphism-pointmass-substitution' }
)

function Get-FileMap([string]$dir) {
    $map = @{}
    if (-not (Test-Path -LiteralPath $dir)) { return $map }
    Get-ChildItem -LiteralPath $dir -File | Where-Object { $_.Name -like '*.md' } | ForEach-Object {
        $map[$_.Name] = (Get-FileHash -LiteralPath $_.FullName -Algorithm SHA256).Hash
    }
    return $map
}

Write-Host '=== SYNC ===' -ForegroundColor Cyan
if ($Check) { Write-Host 'mode: check only (no writes)' -ForegroundColor Yellow }

$drift = 0
$copied = 0

foreach ($lib in $libs) {
    $libDir = Join-Path $root $lib.Name
    if (-not (Test-Path -LiteralPath $libDir)) {
        Write-Host ("SKIP    {0,-16} (library not found)" -f $lib.Name) -ForegroundColor Yellow
        continue
    }
    $targets = @(
        @{ Label = 'skills-repo'; Dir = (Join-Path $SkillsRepo ($lib.Skill + '\tree')) },
        @{ Label = 'installed'; Dir = (Join-Path $InstallDir ($lib.Skill + '\tree')) }
    )
    foreach ($t in $targets) {
        $srcMap = Get-FileMap $libDir
        $dstMap = Get-FileMap $t.Dir
        $issues = @()
        foreach ($k in $srcMap.Keys) {
            if (-not $dstMap.ContainsKey($k)) { $issues += "missing: $k" }
            elseif ($srcMap[$k] -ne $dstMap[$k]) { $issues += "differs: $k" }
        }
        foreach ($k in $dstMap.Keys) {
            if (-not $srcMap.ContainsKey($k)) { $issues += "extra: $k" }
        }

        if ($issues.Count -eq 0) {
            Write-Host ("OK      {0,-12} {1,-16} ({2} file(s))" -f $t.Label, $lib.Name, $srcMap.Count) -ForegroundColor Green
            continue
        }

        if ($Check) {
            $drift++
            Write-Host ("DRIFT   {0,-12} {1,-16} {2}" -f $t.Label, $lib.Name, ($issues -join '; ')) -ForegroundColor Red
            continue
        }

        if (-not (Test-Path -LiteralPath $t.Dir)) {
            New-Item -ItemType Directory -Force -Path $t.Dir | Out-Null
        }
        Get-ChildItem -LiteralPath $libDir -File | Where-Object { $_.Name -like '*.md' } | ForEach-Object {
            Copy-Item -LiteralPath $_.FullName -Destination (Join-Path $t.Dir $_.Name) -Force
        }
        $copied++
        Write-Host ("COPIED  {0,-12} {1,-16} ({2})" -f $t.Label, $lib.Name, ($issues -join '; ')) -ForegroundColor Cyan
    }
}

Write-Host ''
if ($Check) {
    if ($drift -eq 0) {
        Write-Host 'RESULT: no drift' -ForegroundColor Green
        exit 0
    } else {
        Write-Host ("RESULT: $drift drifting target(s)") -ForegroundColor Red
        exit 1
    }
}
Write-Host ("RESULT: $copied target(s) updated")
exit 0

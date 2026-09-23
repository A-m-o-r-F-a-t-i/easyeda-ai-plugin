[CmdletBinding()]
param(
    [switch]$SkipTests
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path

function Invoke-Checked {
    param(
        [Parameter(Mandatory)] [string]$Label,
        [Parameter(Mandatory)] [scriptblock]$Action
    )
    Write-Host "== $Label =="
    & $Action
    if ($LASTEXITCODE -ne 0) {
        throw "$Label failed with exit code $LASTEXITCODE."
    }
}

$plugin = Get-Content -Raw -Encoding UTF8 (Join-Path $repoRoot 'plugin.json') | ConvertFrom-Json
$mcpConfig = Get-Content -Raw -Encoding UTF8 (Join-Path $repoRoot 'mcp.json') | ConvertFrom-Json
$components = Get-Content -Raw -Encoding UTF8 (Join-Path $repoRoot 'components.json') | ConvertFrom-Json

if ($plugin.name -ne 'easyeda' -or $plugin.version -ne $components.plugin.version) {
    throw 'plugin.json and components.json disagree on plugin identity or version.'
}
if ($mcpConfig.mcpServers.'easyeda-pcb'.cwd -ne './mcp/easyeda-pcb') {
    throw 'mcp.json does not point to the aggregated PCB MCP directory.'
}
if (@($components.components).Count -ne 6) {
    throw 'Exactly five Skills and one MCP are required.'
}

Invoke-Checked -Label 'Synchronize submodule URLs' -Action {
    & git -C $repoRoot submodule sync --recursive
}
Invoke-Checked -Label 'Initialize pinned submodules' -Action {
    & git -C $repoRoot submodule update --init --recursive
}

$submoduleLines = @(& git -C $repoRoot submodule status --recursive)
if ($LASTEXITCODE -ne 0) {
    throw 'Unable to read submodule status.'
}
if ($submoduleLines.Count -ne 6) {
    throw "Expected 6 submodules, found $($submoduleLines.Count)."
}
foreach ($line in $submoduleLines) {
    if ($line[0] -in @('-', '+', 'U')) {
        throw "Submodule is missing or does not match the parent commit: $line"
    }
}

$requiredFiles = @(
    'skills/easyeda-api/SKILL.md',
    'skills/easyeda-eprj3/SKILL.md',
    'skills/easyeda-pcb-layout-routing/SKILL.md',
    'skills/easyeda-pro-format-skill/SKILL.md',
    'skills/easyeda-schematic-net-fanout/SKILL.md',
    'mcp/easyeda-pcb/package.json',
    'mcp/easyeda-pcb/src/server.mjs'
)
foreach ($relativePath in $requiredFiles) {
    if (-not (Test-Path (Join-Path $repoRoot $relativePath))) {
        throw "Required component file is missing: $relativePath"
    }
}

$mcpPackage = Get-Content -Raw -Encoding UTF8 (Join-Path $repoRoot 'mcp/easyeda-pcb/package.json') | ConvertFrom-Json
$declaredMcp = @($components.components | Where-Object type -eq 'mcp')
if ($declaredMcp.Count -ne 1 -or $declaredMcp[0].version -ne $mcpPackage.version) {
    throw 'PCB MCP version does not match components.json.'
}
foreach ($component in @($components.components | Where-Object type -eq 'skill')) {
    $text = Get-Content -Raw -Encoding UTF8 (Join-Path $repoRoot "$($component.path)/SKILL.md")
    if ($text -notmatch '(?m)^\s*version:\s*([^\r\n]+)' -or $Matches[1].Trim() -ne $component.version) {
        throw "Skill version does not match components.json: $($component.name)"
    }
}

if (-not $SkipTests) {
    Invoke-Checked -Label 'EasyEDA API Skill syntax' -Action {
        & node --check (Join-Path $repoRoot 'skills/easyeda-api/scripts/bridge-server.mjs')
    }

    Invoke-Checked -Label 'PCB layout Skill tests' -Action {
        Push-Location (Join-Path $repoRoot 'skills/easyeda-pcb-layout-routing')
        try { & node --test 'tests/*.test.mjs' }
        finally { Pop-Location }
    }

    Invoke-Checked -Label 'eprj3 Skill tests' -Action {
        Push-Location (Join-Path $repoRoot 'skills/easyeda-eprj3')
        try { & npm test }
        finally { Pop-Location }
    }

    Invoke-Checked -Label 'EasyEDA format Skill validation' -Action {
        Push-Location (Join-Path $repoRoot 'skills/easyeda-pro-format-skill')
        try {
            & npm ci
            if ($LASTEXITCODE -ne 0) { return }
            $formatSmokeScript = "const {validateFormat}=require('./validate.js');const result=validateFormat('FONT',{width:50,height:40,path:[[2,5,'L',2,35,48,35,48,5,2,5]]});console.log(JSON.stringify(result,null,2));process.exit(result.valid?0:1);"
            & node -e $formatSmokeScript
        }
        finally { Pop-Location }
    }

    Invoke-Checked -Label 'PCB MCP tests' -Action {
        Push-Location (Join-Path $repoRoot 'mcp/easyeda-pcb')
        try {
            & npm ci
            if ($LASTEXITCODE -ne 0) { return }
            & npm test
        }
        finally { Pop-Location }
    }
}

Write-Host "Verified EasyEDA AI plugin $($plugin.version) with 6 pinned components."

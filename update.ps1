#!/usr/bin/env pwsh
# Weekly refresh: pulls live issue counts from the private P1 CRM repo
# and writes them into data.json. Run from this repo root, with `gh` already
# authenticated for VS-Prod-Code/p1_crm.
#
# Usage:
#   ./update.ps1            # update + commit + push
#   ./update.ps1 -DryRun    # update file in-place, no git ops
#
# Friday PM cadence: run before posting the weekly report so the dashboard
# shows the same numbers as the Notion report.

[CmdletBinding()]
param(
  [switch]$DryRun
)

$ErrorActionPreference = 'Stop'
Set-Location $PSScriptRoot

$dataFile = Join-Path $PSScriptRoot 'data.json'
$data = Get-Content $dataFile -Raw | ConvertFrom-Json
$repo = $data.repo
$today = (Get-Date).ToString('yyyy-MM-dd')

Write-Host "Refreshing evidence for $repo · $today" -ForegroundColor Cyan

$labels = $data.phases | Where-Object { $_.label } | Select-Object -ExpandProperty label | Select-Object -Unique

foreach ($label in $labels) {
  $closed = (gh api "search/issues?q=repo:$repo+is:issue+is:closed+label:$label" --jq '.total_count' | Out-String).Trim()
  $open = (gh api "search/issues?q=repo:$repo+is:issue+is:open+label:$label" --jq '.total_count' | Out-String).Trim()
  if ($LASTEXITCODE -ne 0) {
    Write-Error "gh api failed for label '$label' — is gh authenticated for $repo?"
    exit 1
  }
  Write-Host ("  {0,-12} {1,3} closed / {2,3} open" -f $label, $closed, $open)

  foreach ($phase in $data.phases | Where-Object { $_.label -eq $label }) {
    if (-not $phase.evidence) {
      $phase | Add-Member -NotePropertyName evidence -NotePropertyValue ([PSCustomObject]@{}) -Force
    }
    $phase.evidence | Add-Member -NotePropertyName closed -NotePropertyValue ([int]$closed) -Force
    $phase.evidence | Add-Member -NotePropertyName open -NotePropertyValue ([int]$open) -Force
  }
}

$data.updated = $today

# Append (or refresh) today's aggregate snapshot for the Momentum sparkline.
$totClosed = ($data.phases | ForEach-Object { $_.evidence.closed } | Where-Object { $_ -ne $null } | Measure-Object -Sum).Sum
$totOpen   = ($data.phases | ForEach-Object { $_.evidence.open }   | Where-Object { $_ -ne $null } | Measure-Object -Sum).Sum
if (-not $data.PSObject.Properties['history']) {
  $data | Add-Member -NotePropertyName history -NotePropertyValue @() -Force
}
$snapshots = @($data.history | Where-Object { $_.date -ne $today })
$snapshots += [PSCustomObject]@{ date = $today; closed = [int]$totClosed; open = [int]$totOpen }
$data.history = @($snapshots | Sort-Object date)
Write-Host ("  history     {0,3} points · today {1} closed / {2} open" -f $data.history.Count, $totClosed, $totOpen)

$json = $data | ConvertTo-Json -Depth 20
[System.IO.File]::WriteAllText($dataFile, $json + "`n", [System.Text.UTF8Encoding]::new($false))

Write-Host "Wrote $dataFile · updated=$today" -ForegroundColor Green

if ($DryRun) {
  Write-Host "Dry run — skipping git commit/push." -ForegroundColor Yellow
  exit 0
}

git add $dataFile | Out-Null
git diff --cached --quiet
if ($LASTEXITCODE -eq 0) {
  Write-Host "No changes to commit." -ForegroundColor Yellow
  exit 0
}

git commit -m "chore: weekly data refresh — $today" | Out-Null
git push
Write-Host "Pushed to origin." -ForegroundColor Green

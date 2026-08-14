<#
  publish.ps1 — publish the EPROM Business Profile so every copy already sent
  out by e-mail / WhatsApp updates itself the next time it is opened online.

  It does three things and nothing else:
    1. copies the deliverable to index.html in this repo,
    2. writes version.json from the <meta> tags inside that file,
    3. commits and pushes.

  THE VERSION LIVES IN THE HTML, NOT HERE. Before running, bump both tags in
  the deliverable's <head>:

      <meta name="profile-version"  content="2026.08.14-2">
      <meta name="profile-released" content="15 August 2026">

  Because version.json is DERIVED from those tags, the manifest can never
  claim a version the published file does not carry.

  Usage:   .\publish.ps1
           .\publish.ps1 -Notes "Added the terminal services chapter"
#>
param(
  [string]$Source = "C:\Users\tariq\Desktop\work\Work laptop\BD\EPROM Business Profile\1_Final_Deliverables\EPROM Business Profile 2026.html",
  [string]$Notes  = ""
)

$ErrorActionPreference = "Stop"
Set-Location $PSScriptRoot

if (-not (Test-Path $Source)) { throw "Source file not found: $Source" }

$html = Get-Content -Path $Source -Raw -Encoding UTF8

$vMatch = [regex]::Match($html, '<meta\s+name="profile-version"\s+content="([^"]+)"')
$dMatch = [regex]::Match($html, '<meta\s+name="profile-released"\s+content="([^"]+)"')
if (-not $vMatch.Success) { throw 'No <meta name="profile-version"> tag in the source file.' }
if (-not $dMatch.Success) { throw 'No <meta name="profile-released"> tag in the source file.' }

$version  = $vMatch.Groups[1].Value
$released = $dMatch.Groups[1].Value

# refuse to republish the same version — recipients compare version strings,
# so shipping new content under an old stamp would reach nobody
if (Test-Path "version.json") {
  $prev = (Get-Content "version.json" -Raw | ConvertFrom-Json).version
  if ($prev -eq $version) {
    throw "version.json already publishes $version. Bump <meta name=""profile-version""> in the source file first."
  }
}

Copy-Item -Path $Source -Destination "index.html" -Force

$manifest = [ordered]@{
  version   = $version
  released  = $released
  file      = "index.html"
  notes     = $Notes
  published = (Get-Date).ToString("yyyy-MM-dd HH:mm")
}
# UTF-8 with NO BOM — a BOM in front of the JSON breaks strict parsers
[System.IO.File]::WriteAllText(
  (Join-Path $PSScriptRoot "version.json"),
  ($manifest | ConvertTo-Json),
  (New-Object System.Text.UTF8Encoding($false)))

git add index.html version.json
$msg = "Publish version $version"
if ($Notes -ne "") { $msg = "$msg - $Notes" }
git commit -m $msg
git push

Write-Host ""
Write-Host "Published version $version" -ForegroundColor Green
Write-Host "  raw:   https://raw.githubusercontent.com/tariqmu7/eprom-business-profile/main/index.html"
Write-Host "  pages: https://tariqmu7.github.io/eprom-business-profile/"
Write-Host "Copies already sent out will offer this version on their next online open."

param(
    [Parameter(Mandatory = $true)]
    [string]$projectName,

    [Parameter(Mandatory = $true)]
    [string]$description,

    [switch]$NoBuild,

    [switch]$SkipGitInit
)

$ErrorActionPreference = 'Stop'

$descriptionText = $description.Trim()
if ([string]::IsNullOrWhiteSpace($descriptionText)) {
    throw 'description cannot be empty.'
}

$templatePath = $PSScriptRoot
$parentPath = 'C:\temp'
$targetPath = Join-Path $parentPath $projectName

Set-Location $parentPath

if (Test-Path $targetPath) {
    Remove-Item -Recurse -Force $targetPath
}

New-Item -ItemType Directory -Path $targetPath | Out-Null
Copy-Item -Recurse -Force -Path (Join-Path $templatePath '*') -Destination $targetPath

Set-Location $targetPath

Remove-Item -Recurse -Force .git -ErrorAction SilentlyContinue
if (-not $SkipGitInit) {
    git init
}

$launchJsonPath = Join-Path $targetPath '.vscode\launch.json'
if (Test-Path $launchJsonPath) {
    $launchJson = Get-Content -Path $launchJsonPath -Raw
    $launchJson = [regex]::Replace(
        $launchJson,
        '(?<="program"\s*:\s*"\$\{workspaceFolder\}/)[^"/\\]+(?=\.exe")',
        { param($m) $projectName }
    )
    Set-Content -Path $launchJsonPath -Value $launchJson -Encoding utf8
}

$dubJsonPath = Join-Path $targetPath 'dub.json'
$dubJson = Get-Content -Path $dubJsonPath -Raw | ConvertFrom-Json
$dubJson.name = $projectName
$dubJson.description = $descriptionText
$dubJson | ConvertTo-Json -Depth 20 | Set-Content -Path $dubJsonPath -Encoding utf8

if (-not $NoBuild) {
    dub build
}
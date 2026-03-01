param(
    [Parameter(Mandatory = $true)]
    [string]$projectName,

    [Parameter(Mandatory = $true)]
    [string]$description,

    [switch]$NoBuild,

    [switch]$SkipGitInit,

    [string]$TemplateRepoUrl = 'https://github.com/brotherbill/c01_p1_my_first_app_windows.git'
)

$ErrorActionPreference = 'Stop'

$descriptionText = $description.Trim()
if ([string]::IsNullOrWhiteSpace($descriptionText)) {
    throw 'description cannot be empty.'
}

$templateRepoUrlText = $TemplateRepoUrl.Trim()
if ([string]::IsNullOrWhiteSpace($templateRepoUrlText)) {
    throw 'TemplateRepoUrl cannot be empty.'
}

if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    throw 'git is required but was not found in PATH. Install Git and retry.'
}

$parentPath = (Get-Location).Path
$targetPath = Join-Path $parentPath $projectName

Set-Location $parentPath

if (Test-Path $targetPath) {
    Remove-Item -Recurse -Force $targetPath
}

git clone --depth 1 $templateRepoUrlText $projectName
if ($LASTEXITCODE -ne 0 -or -not (Test-Path $targetPath)) {
    throw "Failed to clone template repository: $templateRepoUrlText"
}

Set-Location $targetPath

Remove-Item -Recurse -Force .git -ErrorAction SilentlyContinue
if (-not $SkipGitInit) {
    git init
    if ($LASTEXITCODE -ne 0) {
        throw 'git init failed in the generated project.'
    }
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
    if ($LASTEXITCODE -ne 0) {
        throw 'dub build failed in the generated project.'
    }
}
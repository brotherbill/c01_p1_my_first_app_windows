# `new-project-from-template.ps1` — Detailed Guide for Beginners

This document explains **exactly what `new-project-from-template.ps1` does**, line by line in practical terms, for someone who is not familiar with PowerShell.

---

## What this script is for

`new-project-from-template.ps1` automates creating a new D project from a GitHub template repository.

At a high level, it:

1. Validates the input you provide.
2. Clones a template repo into `<current-working-directory>\<projectName>`.
3. Optionally initializes a fresh Git repository.
4. Updates project config files (`dub.json`, and `.vscode/launch.json` if present).
5. Optionally runs `dub build`.

---

## The script’s parameters (inputs)

At the top, the script declares parameters with `param(...)`:

- `-projectName` (**required**)  
  The name of your new project folder and D package name.

- `-description` (**required**)  
  Human-readable description written into `dub.json`.

- `-NoBuild` (optional switch)  
  If included, the script **skips** `dub build`.

- `-SkipGitInit` (optional switch)  
  If included, the script **does not run** `git init` after cloning.

- `-TemplateRepoUrl` (optional string)  
  URL to clone from. Defaults to:  
  `https://github.com/brotherbill/c01_p1_my_first_app_windows.git`

### What “Mandatory = $true” means

For `projectName` and `description`, `[Parameter(Mandatory = $true)]` means PowerShell requires those arguments. If you forget one, PowerShell prompts or errors.

### What a “switch” means

`[switch]$NoBuild` and `[switch]$SkipGitInit` are boolean flags:

- Not provided → `False`
- Provided (e.g., `-NoBuild`) → `True`

No extra value is needed.

---

## Safety behavior: stop on first error

The line:

```powershell
$ErrorActionPreference = 'Stop'
```

tells PowerShell to treat non-terminating errors as terminating errors. In plain terms: **fail fast**. If something important goes wrong, the script stops instead of silently continuing.

---

## Input cleanup and validation

### Description validation

```powershell
$descriptionText = $description.Trim()
if ([string]::IsNullOrWhiteSpace($descriptionText)) {
    throw 'description cannot be empty.'
}
```

- `.Trim()` removes spaces at the beginning/end.
- `IsNullOrWhiteSpace(...)` rejects empty text or only spaces.
- `throw` stops the script with a clear error message.

### Template URL validation

```powershell
$templateRepoUrlText = $TemplateRepoUrl.Trim()
if ([string]::IsNullOrWhiteSpace($templateRepoUrlText)) {
    throw 'TemplateRepoUrl cannot be empty.'
}
```

Same idea: it trims then validates the URL string.

---

## Dependency check: Git must exist

```powershell
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    throw 'git is required but was not found in PATH. Install Git and retry.'
}
```

- `Get-Command git` checks if `git` is available.
- `-ErrorAction SilentlyContinue` hides command-not-found noise.
- `-not (...)` flips the result.
- If Git isn’t found, script throws a helpful message.

This avoids failing later with a confusing clone error.

---

## Folder setup and navigation

```powershell
$parentPath = (Get-Location).Path
$targetPath = Join-Path $parentPath $projectName

Set-Location $parentPath
```

- New projects are created under your **current working directory**.
- `Join-Path` safely combines paths (`<current directory>` + project name).
- `Set-Location` changes current working directory.

### Existing target folder behavior

```powershell
if (Test-Path $targetPath) {
    Remove-Item -Recurse -Force $targetPath
}
```

- `Test-Path` checks if destination already exists.
- If it exists, script **deletes it recursively and forcefully**.

⚠️ Important: this is destructive for that folder path. If `<current-working-directory>\my-project` already contains work, it will be removed.

---

## Clone template repository

```powershell
git clone --depth 1 $templateRepoUrlText $projectName
if ($LASTEXITCODE -ne 0 -or -not (Test-Path $targetPath)) {
    throw "Failed to clone template repository: $templateRepoUrlText"
}
```

- `git clone --depth 1 ...` performs a shallow clone (latest snapshot, less history).
- `$LASTEXITCODE` is the exit code of the last native command (`git`).
  - `0` usually means success.
  - non-zero means failure.
- Script also checks that destination folder actually exists.

If either check fails, it throws a clear error.

---

## Enter new project directory

```powershell
Set-Location $targetPath
```

From here onward, operations target the newly cloned project.

---

## Remove old Git history and optionally initialize new repo

```powershell
Remove-Item -Recurse -Force .git -ErrorAction SilentlyContinue
if (-not $SkipGitInit) {
    git init
    if ($LASTEXITCODE -ne 0) {
        throw 'git init failed in the generated project.'
    }
}
```

- Removes the cloned `.git` folder to detach from the template repo history.
- Unless `-SkipGitInit` is used, script runs `git init` to create a fresh repository.

Why this matters:
- You get template files, but your project starts with its own independent Git history.

---

## Update VS Code debug executable name (`.vscode/launch.json`)

```powershell
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
```

What this does:

1. Builds path to `.vscode\launch.json`.
2. Only proceeds if the file exists.
3. Reads full file as one string (`-Raw`).
4. Uses regex to replace the executable filename in `"program": "${workspaceFolder}/... .exe"` with your `projectName`.
5. Writes file back as UTF-8.

### Regex intent in plain English

The pattern:

`(?<="program"\s*:\s*"\$\{workspaceFolder\}/)[^"/\\]+(?=\.exe")`

means “find the filename part after `${workspaceFolder}/` and before `.exe` inside the `program` setting, then replace that filename with `projectName`.”

This helps F5 debugging point to the newly named executable.

---

## Update `dub.json` name and description

```powershell
$dubJsonPath = Join-Path $targetPath 'dub.json'
$dubJson = Get-Content -Path $dubJsonPath -Raw | ConvertFrom-Json
$dubJson.name = $projectName
$dubJson.description = $descriptionText
$dubJson | ConvertTo-Json -Depth 20 | Set-Content -Path $dubJsonPath -Encoding utf8
```

Step-by-step:

1. Load `dub.json` text.
2. Convert JSON text into a PowerShell object.
3. Set `.name` to your project name.
4. Set `.description` to your cleaned description.
5. Convert object back to JSON and write it out.

`-Depth 20` prevents nested data from being truncated during JSON conversion.

---

## Optional build step

```powershell
if (-not $NoBuild) {
    dub build
    if ($LASTEXITCODE -ne 0) {
        throw 'dub build failed in the generated project.'
    }
}
```

- By default, it runs `dub build` in the new project.
- If you pass `-NoBuild`, this section is skipped.
- On build failure, it throws an explicit error.

---

## Typical usage examples

Run the script from the folder where you want the new project folder to be created.

### Minimal required usage

```powershell
.\new-project-from-template.ps1 -projectName "my_app" -description "My first D app"
```

### Skip build

```powershell
.\new-project-from-template.ps1 -projectName "my_app" -description "My first D app" -NoBuild
```

### Keep without new git init

```powershell
.\new-project-from-template.ps1 -projectName "my_app" -description "My first D app" -SkipGitInit
```

### Use a custom template repo

```powershell
.\new-project-from-template.ps1 -projectName "my_app" -description "My first D app" -TemplateRepoUrl "https://github.com/your-org/your-template.git"
```

---

## What files are changed by this script

Inside the new project folder (`<current-working-directory>\<projectName>`), it can modify:

- `.vscode\launch.json` (if it exists)
- `dub.json`

It also removes and/or creates Git metadata:

- Removes `.git` from cloned template
- Creates new `.git` with `git init` unless skipped

---

## Common failure cases and meaning

- **"git is required but was not found in PATH"**  
  Git is not installed or not available in environment PATH.

- **"Failed to clone template repository"**  
  URL invalid, network issue, permissions issue, or clone failed.

- **"git init failed in the generated project"**  
  Git command failed in target folder.

- **"dub build failed in the generated project"**  
  D toolchain/dub issue or project build issue.

- **"description cannot be empty"**  
  Provided description is blank or only whitespace.

---

## Practical notes for beginners

- Run this script in **PowerShell**, not Command Prompt.
- If PowerShell blocks script execution, check your execution policy and organizational policy constraints.
- Be careful with `projectName`: script deletes `<current-working-directory>\<projectName>` if it already exists.
- If you want to inspect generated files before building, use `-NoBuild`.

---

## Quick “mental model” summary

Think of this script as a pipeline:

1. Validate input and prerequisites.
2. Create clean target folder under your current working directory.
3. Clone template snapshot.
4. Detach from template history.
5. Personalize project metadata and debug settings.
6. Build (unless told not to).

That’s it: a reproducible way to turn a template repo into a fresh, personalized D project.

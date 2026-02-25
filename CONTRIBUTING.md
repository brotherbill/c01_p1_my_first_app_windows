# Contributing

Thanks for improving this D debugging starter project.

## Contents

- [Goal](#goal).
- [Developer Checklist](#developer-checklist).
- [Local Checks Before Opening a PR](#local-checks-before-opening-a-pr).
- [Scope Guidelines](#scope-guidelines).
- [VS Code Config Expectations](#vs-code-config-expectations).
- [Template Script Details](#template-script-details).
- [Common PowerShell Issues](#common-powershell-issues).
- [Advanced Debug Notes](#advanced-debug-notes).

## Goal

Keep this repository minimal, beginner-friendly, and focused on the VS Code build/debug workflow.

## Developer Checklist

Before development or release prep, verify:

### Daily Development Checks

1. `dub build` succeeds in the template folder.
2. `dub run` prints `Greetings D!`.
3. `F5` starts **Debug D project** in the template project.

### Pre-Release Checks

1. `new-project-from-template.ps1` creates a test project from `C:\temp`.
2. The generated project builds successfully.
3. `F5` starts **Debug D project** in the generated project.

## Local Checks Before Opening a PR

1. Build: `dub build`
2. Run: `dub run`
3. Debug sanity:
  - `F5` runs regular debug (`Debug D project`).
  - `Debug D project (Stop at entry)` still works.

## Scope Guidelines

- Prefer small, focused changes.
- Keep sample code simple for new users.
- Update `README.md` whenever behavior or commands change.
- Avoid adding extra tooling unless it clearly improves onboarding.

## VS Code Config Expectations

Keep project-level settings in `.vscode/` files.

Note: keyboard shortcuts are user-level in VS Code. Document custom bindings (like `Alt+F5`) instead of trying to enforce them from the repository.

### Markdown Preview Workflow (Optional)

- Typora is an optional Markdown tool for quick visual QA.
- It is paid software, but easy to use for editing and previewing `.md` files.
- VS Code remains the source-of-truth editor for repo changes.

---

## Template Script Details

Script: `new-project-from-template.ps1`

GitHub source: `https://github.com/brotherbill/c01_p1_my_first_app_windows/blob/main/new-project-from-template.ps1`

Required parameters:

- `-projectName` (example: `my-new-project`).
- `-description` (quote if multiple words).

Run from any folder (for example `C:\temp`):

```powershell
$scriptUrl = "https://raw.githubusercontent.com/brotherbill/c01_p1_my_first_app_windows/main/new-project-from-template.ps1"
$scriptPath = Join-Path $env:TEMP "new-project-from-template.ps1"
Invoke-WebRequest -Uri $scriptUrl -OutFile $scriptPath
& $scriptPath -projectName "my-new-project" -description "my description"
```

What the script does:

1. Clones the template project from GitHub into `C:\temp\<projectName>`.
2. Removes old `.git` metadata.
3. Runs `git init` (unless `-SkipGitInit` is used).
4. Updates `.vscode/launch.json` to use `<projectName>.exe`.
5. Updates `dub.json` (`name` and `description`).
6. Runs `dub build`.

Optional switches:

- `-NoBuild` (skip build).
- `-SkipGitInit` (skip `git init`).
- `-TemplateRepoUrl` (use a different GitHub template repo URL).

Example:

```powershell
$scriptUrl = "https://raw.githubusercontent.com/brotherbill/c01_p1_my_first_app_windows/main/new-project-from-template.ps1"
$scriptPath = Join-Path $env:TEMP "new-project-from-template.ps1"
Invoke-WebRequest -Uri $scriptUrl -OutFile $scriptPath
& $scriptPath -projectName "my-new-project" -description "my description" -NoBuild -SkipGitInit
```

Example using a different template repository:

```powershell
$scriptUrl = "https://raw.githubusercontent.com/brotherbill/c01_p1_my_first_app_windows/main/new-project-from-template.ps1"
$scriptPath = Join-Path $env:TEMP "new-project-from-template.ps1"
Invoke-WebRequest -Uri $scriptUrl -OutFile $scriptPath
& $scriptPath -projectName "my-new-project" -description "my description" -TemplateRepoUrl "https://github.com/your-org/your-template-repo.git"
```

---

## Common PowerShell Issues

### `http://_vscodecontentref_/...` Is Not Recognized

Cause: a Markdown link was pasted into PowerShell.

Use a plain command instead:

```powershell
$scriptUrl = "https://raw.githubusercontent.com/brotherbill/c01_p1_my_first_app_windows/main/new-project-from-template.ps1"
$scriptPath = Join-Path $env:TEMP "new-project-from-template.ps1"
Invoke-WebRequest -Uri $scriptUrl -OutFile $scriptPath
& $scriptPath -projectName "my-new-project" -description "my description"
```

### Script Blocked by ExecutionPolicy

One-time command:

```powershell
$scriptUrl = "https://raw.githubusercontent.com/brotherbill/c01_p1_my_first_app_windows/main/new-project-from-template.ps1"
$scriptPath = Join-Path $env:TEMP "new-project-from-template.ps1"
Invoke-WebRequest -Uri $scriptUrl -OutFile $scriptPath
powershell -ExecutionPolicy Bypass -File $scriptPath -projectName "my-new-project" -description "my description"
```

For frequent local script use (current user):

```powershell
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned
```

---

## Advanced Debug Notes

### Launch Profiles

Two launch profiles are included in `.vscode/launch.json`:

1. **Debug D project** (`stopAtEntry: false`)
2. **Debug D project (Stop at entry)** (`stopAtEntry: true`)

### Backup Task

- Task: **backup: success snapshot**.
- Output: timestamped zip in `C:\temp\`.
- Optional user shortcut: `Ctrl+Alt+Shift+B` (if set in user keybindings).

### Optional `Alt+F5` Keybinding (User Setting)

Add this to user keybindings JSON if you want `Alt+F5` to always start "Stop at entry":

```json
{
  "key": "alt+f5",
  "command": "debug.startFromConfig",
  "args": {
    "name": "Debug D project (Stop at entry)",
    "type": "cppvsdbg",
    "request": "launch",
    "program": "${workspaceFolder}/c01_p1_my_first_app_windows.exe",
    "args": [],
    "stopAtEntry": true,
    "cwd": "${workspaceFolder}",
    "preLaunchTask": "dub: build",
    "console": "integratedTerminal"
  },
  "when": "workspaceFolderCount != 0"
}
```

If `Alt+F5` conflicts, change only the `key` value.
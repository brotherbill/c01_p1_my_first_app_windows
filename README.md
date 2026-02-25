# D Debugging Starter (Windows + VS Code)

Beginner-friendly D (`dub`) project for build, run, and debug practice.

## GitHub Template URL

- Template repository: `https://github.com/brotherbill/dlang_course`
- Template project folder: `https://github.com/brotherbill/dlang_course/tree/main/c01_p1_a_my_first_app_windows`
- Template script (raw): `https://raw.githubusercontent.com/brotherbill/dlang_course/main/c01_p1_a_my_first_app_windows/new-project-from-template.ps1`

## Quick Start

1. Open this folder in VS Code.
2. Open a terminal in this folder and run:

```powershell
dub build
```

3. Press `F5` to debug.

## What Success Looks Like

After `dub build`, this file appears in the workspace root:

- `c01_p1_a_my_first_app_windows.exe`.

When you run or debug the app, expected output:

```text
Greetings D!
```

## Day-to-Day Commands

- Build: `dub build`.
- Run: `dub run`.
- Debug: `F5`.
- Backup: Run `backup: success snapshot` from **Terminal > Run Task...**.

## Create a New Project from This Template

Run from any folder (for example `C:\temp`):

```powershell
$scriptUrl = "https://raw.githubusercontent.com/brotherbill/dlang_course/main/c01_p1_a_my_first_app_windows/new-project-from-template.ps1"
$scriptPath = Join-Path $env:TEMP "new-project-from-template.ps1"
Invoke-WebRequest -Uri $scriptUrl -OutFile $scriptPath
& $scriptPath -projectName "my-new-project" -description "my description"
```

## Need More Details?

See `CONTRIBUTING.md` for:

- Optional script switches (`-NoBuild`, `-SkipGitInit`).
- Common PowerShell issues and ExecutionPolicy fixes.
- Advanced debug profiles and keybindings.
- Contributor workflow guidance.
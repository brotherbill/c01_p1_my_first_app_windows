# Student Handout (Day 1)

Use this page for your first class session.

## GitHub Template URL

- Template repository: `https://github.com/brotherbill/c01_p1_my_first_app_windows`
- Template project folder: `https://github.com/brotherbill/c01_p1_my_first_app_windows`
- Template script (raw): `https://raw.githubusercontent.com/brotherbill/c01_p1_my_first_app_windows/main/new-project-from-template.ps1`

## 1) Open the Project

- Open this folder in VS Code: `C:\temp\c01_p1_my_first_app_windows`.

## 2) Build

```powershell
dub build
```

## 3) Run

```powershell
dub run
```

Expected output:

```text
Greetings D!
```

## 4) Debug

- Press `F5`.
- Choose **Debug D project** if prompted.

## 5) Optional: Create Your Own Project Copy

Run from any folder (for example `C:\temp`):

```powershell
$scriptUrl = "https://raw.githubusercontent.com/brotherbill/c01_p1_my_first_app_windows/main/new-project-from-template.ps1"
$scriptPath = Join-Path $env:TEMP "new-project-from-template.ps1"
Invoke-WebRequest -Uri $scriptUrl -OutFile $scriptPath
& $scriptPath -projectName "my-new-project" -description "my description"
```

Then open your new folder in VS Code:

- `C:\temp\my-new-project`.

## 6) Quick Backup

- Run task `backup: success snapshot` to create a timestamped backup zip in `C:\temp`.
- Optional: if your user keybinding is set, `Ctrl+Alt+Shift+B` runs the same backup task.

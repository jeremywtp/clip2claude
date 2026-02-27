#!/bin/bash
# install.sh - Install clip2claude on WSL + Windows

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
WIN_USER=$(cmd.exe /c "echo %USERNAME%" 2>/dev/null | tr -d '\r')
WIN_SCRIPTS="C:\\Users\\${WIN_USER}\\scripts"
WSL_SCRIPTS="/mnt/c/Users/${WIN_USER}/scripts"

echo "=== clip2claude installer ==="
echo ""

# 1. Install bash script to ~/.local/bin
echo "[1/4] Installing clip2img to ~/.local/bin..."
mkdir -p ~/.local/bin
cp "$SCRIPT_DIR/clip2img" ~/.local/bin/clip2img
chmod +x ~/.local/bin/clip2img
echo "  Done."

# 2. Copy Windows scripts
echo "[2/4] Copying scripts to ${WIN_SCRIPTS}..."
mkdir -p "$WSL_SCRIPTS"
cp "$SCRIPT_DIR/clip2claude.ahk" "$WSL_SCRIPTS/"
cp "$SCRIPT_DIR/clip2claude.ps1" "$WSL_SCRIPTS/"
cp "$SCRIPT_DIR/clip2claude.vbs" "$WSL_SCRIPTS/"
echo "  Done."

# 3. Install AutoHotkey v2 if not present
echo "[3/4] Checking AutoHotkey..."
AHK_PATH="/mnt/c/Users/${WIN_USER}/AppData/Local/Programs/AutoHotkey/v2/AutoHotkey64.exe"
if [ -f "$AHK_PATH" ]; then
    echo "  AutoHotkey v2 already installed."
else
    echo "  Installing AutoHotkey v2 via winget..."
    powershell.exe -NoProfile -Command "winget install AutoHotkey.AutoHotkey --accept-package-agreements --accept-source-agreements" 2>&1 | tr -d '\r'
    if [ ! -f "$AHK_PATH" ]; then
        echo "  ERROR: AutoHotkey installation failed. Install manually from https://www.autohotkey.com/" >&2
        exit 1
    fi
    echo "  Done."
fi

# 4. Create scheduled task (runs elevated, no UAC prompt)
echo "[4/4] Creating scheduled task..."
WIN_AHK_PATH=$( wslpath -w "$AHK_PATH" )
# Supprimer l'ancien raccourci startup s'il existe
powershell.exe -NoProfile -Command "
Remove-Item \"\$([Environment]::GetFolderPath('Startup'))\clip2claude.lnk\" -ErrorAction SilentlyContinue
" 2>/dev/null
# Créer la tâche planifiée avec privilèges élevés
powershell.exe -NoProfile -Command "
Unregister-ScheduledTask -TaskName 'clip2claude' -Confirm:\$false -ErrorAction SilentlyContinue
\$action = New-ScheduledTaskAction -Execute '${WIN_AHK_PATH}' -Argument '${WIN_SCRIPTS}\\clip2claude.ahk' -WorkingDirectory '${WIN_SCRIPTS}'
\$trigger = New-ScheduledTaskTrigger -AtLogOn -User '${WIN_USER}'
\$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -ExecutionTimeLimit 0
\$principal = New-ScheduledTaskPrincipal -UserId '${WIN_USER}' -RunLevel Highest -LogonType Interactive
Register-ScheduledTask -TaskName 'clip2claude' -Action \$action -Trigger \$trigger -Settings \$settings -Principal \$principal -Description 'Clipboard to Claude Code (ALT+V)' -Force
" 2>&1 | tr -d '\r'
echo "  Done."

# 5. Launch
echo ""
echo "Launching clip2claude..."
powershell.exe -NoProfile -Command "Start-Process '$WIN_AHK_PATH' -ArgumentList '${WIN_SCRIPTS}\\clip2claude.ahk'" 2>&1 | tr -d '\r'

echo ""
echo "=== Installation complete ==="
echo ""
echo "Usage:"
echo "  1. Take a screenshot (Win+Shift+S)"
echo "  2. Press ALT+V in Windows Terminal or Cursor"
echo "  3. The image path is typed into your terminal"
echo ""
echo "Manual usage from WSL:"
echo "  clip2img              # saves to /tmp/screenshots/"
echo "  clip2img output.png   # saves to specific path"

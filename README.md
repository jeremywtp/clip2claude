# clip2claude

Paste Windows clipboard screenshots into Claude Code (or any terminal) on WSL with **ALT+V**.

## How it works

1. Take a screenshot (`Win+Shift+S`)
2. Press `ALT+V` in your terminal
3. The screenshot is saved and its WSL path is typed into your input

Works with **Windows Terminal**, **Cursor**, and any terminal running on WSL.

## Installation

```bash
git clone https://github.com/YOUR_USERNAME/clip2claude.git
cd clip2claude
./install.sh
```

The installer will:
- Copy `clip2img` to `~/.local/bin/` (WSL)
- Copy Windows scripts to `C:\Users\<you>\scripts\`
- Install [AutoHotkey v2](https://www.autohotkey.com/) via winget if not present
- Create a startup shortcut so it launches automatically on login

## Files

| File | Platform | Description |
|---|---|---|
| `clip2img` | WSL (bash) | CLI tool - saves clipboard image and prints the path |
| `clip2claude.ahk` | Windows (AHK v2) | ALT+V hotkey for Windows Terminal & Cursor |
| `clip2claude.ps1` | Windows (PowerShell) | Alternative without AutoHotkey |
| `clip2claude.vbs` | Windows (VBScript) | Silent launcher for the PowerShell script |
| `install.sh` | WSL (bash) | Automated installer |

## Usage

### With ALT+V (recommended)

After install, just press `ALT+V` in your terminal. The path gets typed into your input:

```
/mnt/c/Users/you/screenshots/clip_20260223_150312.png
```

You can then write your message around it, for example:

```
Look at this bug /mnt/c/Users/you/screenshots/clip_20260223_150312.png
```

### Manual (CLI)

```bash
clip2img                # saves to /tmp/screenshots/clip_<timestamp>.png
clip2img output.png     # saves to a specific path
```

### Without AutoHotkey

If you prefer not to install AutoHotkey:

1. Create a shortcut to `clip2claude.vbs` on your Desktop
2. Right-click the shortcut > **Properties** > **Shortcut key** > press `Ctrl+Alt+V`
3. Click **OK**

This gives you `Ctrl+Alt+V` instead of `ALT+V` (Windows shortcut limitation).

## Adding more terminals

Edit `clip2claude.ahk` and add your terminal's executable to the `#HotIf` line:

```ahk
#HotIf WinActive("ahk_exe WindowsTerminal.exe") || WinActive("ahk_exe Cursor.exe") || WinActive("ahk_exe YourTerminal.exe")
```

Reload the script (right-click the AHK tray icon > **Reload Script**).

## Troubleshooting

**ALT+V does nothing**
- Make sure AutoHotkey is running (check the system tray for the green `H` icon)
- Verify your terminal is in the `#HotIf` line of `clip2claude.ahk`

**"No image in clipboard" tooltip**
- Take a fresh screenshot with `Win+Shift+S` before pressing ALT+V
- Some screenshot tools don't copy to clipboard by default - check their settings

**`clip2img` returns "No image in clipboard"**
- Same as above - ensure you have an image (not text) in your clipboard
- Run `powershell.exe -Command "[System.Windows.Forms.Clipboard]::ContainsImage()"` to verify

**Screenshots directory**
- ALT+V saves to `C:\Users\<you>\screenshots\`
- `clip2img` saves to `/tmp/screenshots/` by default

## Uninstall

```bash
# Remove WSL script
rm ~/.local/bin/clip2img

# Remove Windows scripts
rm -rf /mnt/c/Users/$(cmd.exe /c "echo %USERNAME%" 2>/dev/null | tr -d '\r')/scripts/clip2claude.*

# Remove startup shortcut
powershell.exe -Command "Remove-Item \"$([Environment]::GetFolderPath('Startup'))\clip2claude.lnk\" -ErrorAction SilentlyContinue"

# Optionally uninstall AutoHotkey
powershell.exe -Command "winget uninstall AutoHotkey.AutoHotkey"
```

## Requirements

- Windows 10/11 with WSL2
- [AutoHotkey v2](https://www.autohotkey.com/) (auto-installed by `install.sh`)
- PowerShell 5.1+ (included with Windows)

## License

MIT

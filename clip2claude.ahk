#Requires AutoHotkey v2.0
#SingleInstance Force

; Permet d'envoyer des frappes aux terminaux lances en administrateur
if !A_IsAdmin {
    try Run("*RunAs " A_ScriptFullPath)
    ExitApp
}

; ALT+V - Paste a clipboard screenshot path into a WSL terminal
; Works with Windows Terminal and Cursor

; ── Configuration ──────────────────────────────────────────────
; Change this to your Windows screenshots directory
SCREENSHOT_DIR := EnvGet("USERPROFILE") "\screenshots"
; Change this to match the WSL mount path
WSL_PREFIX := "/mnt/c/Users/" EnvGet("USERNAME") "/screenshots/"
; ───────────────────────────────────────────────────────────────

#HotIf WinActive("ahk_exe WindowsTerminal.exe") || WinActive("ahk_exe Cursor.exe")
!v:: {
    timestamp := FormatTime(, "yyyyMMdd_HHmmss")
    DirCreate(SCREENSHOT_DIR)
    imgPath := SCREENSHOT_DIR "\clip_" timestamp ".png"
    wslPath := WSL_PREFIX "clip_" timestamp ".png"

    ; Save clipboard image via PowerShell
    psCmd := "Add-Type -AssemblyName System.Windows.Forms;"
    psCmd .= " `$i=[System.Windows.Forms.Clipboard]::GetImage();"
    psCmd .= " if(`$i){`$i.Save('" imgPath "')}"

    RunWait('powershell.exe -NoProfile -Command "' psCmd '"',, "Hide")

    if FileExist(imgPath) {
        SendText(wslPath)
    } else {
        ToolTip("No image in clipboard!")
        SetTimer(() => ToolTip(), -2000)
    }
}
#HotIf

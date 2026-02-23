' clip2claude.vbs - Launch PowerShell script without visible window
' Create a shortcut to this file, then assign Ctrl+Alt+V to the shortcut
Set objShell = CreateObject("WScript.Shell")
objShell.Run "powershell.exe -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File """ & CreateObject("Scripting.FileSystemObject").GetParentFolderName(WScript.ScriptFullName) & "\clip2claude.ps1""", 0, False

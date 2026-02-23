# clip2claude.ps1 - Paste clipboard screenshot path into terminal
# Alternative to AutoHotkey - assign Ctrl+Alt+V to a shortcut pointing to clip2claude.vbs

Add-Type -AssemblyName System.Windows.Forms

$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$imgDir = "$env:USERPROFILE\screenshots"
if (-not (Test-Path $imgDir)) { New-Item -ItemType Directory -Path $imgDir | Out-Null }
$imgPath = "$imgDir\clip_$timestamp.png"
$wslPath = "/mnt/c/Users/$env:USERNAME/screenshots/clip_$timestamp.png"

$img = [System.Windows.Forms.Clipboard]::GetImage()
if ($img) {
    $img.Save($imgPath)
    Start-Sleep -Milliseconds 300
    [System.Windows.Forms.SendKeys]::SendWait($wslPath)
} else {
    $balloon = New-Object System.Windows.Forms.NotifyIcon
    $balloon.Icon = [System.Drawing.SystemIcons]::Warning
    $balloon.BalloonTipText = "No image in clipboard!"
    $balloon.BalloonTipTitle = "clip2claude"
    $balloon.Visible = $true
    $balloon.ShowBalloonTip(2000)
    Start-Sleep -Seconds 2
    $balloon.Dispose()
}

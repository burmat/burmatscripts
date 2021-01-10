Add-Type -AssemblyName System.Windows.Forms
$max = 90
$int = 5
$c = 0
while($true) {
        if ($c -gt $max) {
                Break
        }
        $tb = New-Object System.Windows.Forms.TextBox
        $tb.MultiLine = $true
        $tb.Paste()
        "____________________"
        $tb.Text
        "____________________"
        $c = $c + $int
        Start-Sleep -Seconds $int
}
Exit

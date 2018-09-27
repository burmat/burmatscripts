 Import-Module ActiveDirectory

function Get-ADHostsLastLogon() {

    $hnames = Get-ADComputer -Filter 'ObjectClass -eq "Computer"' | Select -Expand Name

    foreach ($hname in $hnames) {
        $dcs = Get-ADDomainController -Filter {Name -like "*"}
        $time = 0
        foreach($dc in $dcs) { 
            $computer = Get-ADComputer $hname | Get-ADObject -Properties lastLogon 
            if($computer.LastLogon -gt $time) {
                $time = $computer.LastLogon
            }
        }
        
        $dt = [DateTime]::FromFileTime($time).ToString('g')
        # 12/31/1600 will result if $time = 0 (never logged on before)
        Write-Host $dt", " $hname
    }
    Write-Host "Done."
}

Get-ADHostsLastLogon 

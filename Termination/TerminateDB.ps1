$winttl="DOSBox"

$AllProc = Get-Process | Where-Object {$_.ProcessName -eq $winttl}
$PreTerm = $AllProc | Select-Object Id, ProcessName
if ($AllProc.Count -gt 1) {$SelProc = $AllProc[0]}
else{$SelProc = $AllProc}
if ($SelProc) {
    Stop-Process -ID $SelProc.ID -Force
    
}
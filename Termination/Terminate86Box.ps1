$winttl="*86Box*"
$delaySeconds = 7

Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;

public class User32 {
    [DllImport("user32.dll", CharSet = CharSet.Auto)]
    public static extern IntPtr SendMessage(IntPtr hWnd, UInt32 Msg, IntPtr wParam, string lParam);
}
"@

$AllProc = Get-Process | Where-Object {$_.MainWindowTitle -like $winttl}
$PreTerm = $AllProc | Select-Object Id, ProcessName
if ($AllProc.Count -gt 1) {$SelProc = $AllProc[0]}
else{$SelProc = $AllProc}
if ($SelProc) {
    Add-Type -AssemblyName System.Windows.Forms
    $handle = $SelProc.MainWindowHandle
    [void][User32]::SendMessage($handle, 0x0010, 0, 0)
    #If the window is still open after the delay, just knock out the process entirely
    Start-Sleep -Seconds $delaySeconds
    $ChkProc = Get-Process | Where-Object {$_.MainWindowTitle -like $winttl}
    $ChkTerm = $ChkProc | Select-Object Id, ProcessName
    if ( -not (Compare-Object $PreTerm.PSObject.Properties $ChkTerm.PSObject.Properties) )
    {
        Stop-Process -ID $SelProc.ID -Force
    }
    
}
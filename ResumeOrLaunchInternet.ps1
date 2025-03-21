﻿Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
Add-Type -TypeDefinition @'
	using System;
	using System.Runtime.InteropServices;
    using System.Text;
	public class User32{
        [DllImport("user32.dll")] [return: MarshalAs(UnmanagedType.Bool)]  public static extern bool SetForegroundWindow(IntPtr hWnd);
	    [DllImport("user32.dll")] [return: MarshalAs(UnmanagedType.Bool)]  public static extern bool ShowWindowAsync(IntPtr hWnd, int nCmdShow);
}
'@
 
#$RelPathDef = "..\Vivaldi\Application\vivaldi.exe --start-fullscreen"
$IDHndl = @(get-process | ? { $_.ProcessName -match "msedge"})
#If the process is open, switch to it.
$handle = $null
if($IDHndl){
    foreach ($process in $IDHndl) {
        $handle = $process.MainWindowHandle
            if ($handle.ToInt64()) {
                break;
            }
    }
}

if ($handle.ToInt64()){
    [User32]::SetForegroundWindow($handle)
}
else{
    #start microsoft-edge:http://google.com
    $process = start microsoft-edge:  -PassThru
    $wshell = New-Object -ComObject wscript.shell;
    #$wshell.AppActivate('Google - Microsoft Edge')
    $wshell.AppActivate('Microsoft Edge')
    Sleep 1
    $IDHndl = @(get-process | ? { $_.ProcessName -match "msedge"})
    #If the process is open, switch to it.
    $handle = $null
    if($IDHndl){
        foreach ($process in $IDHndl) {
            $handle = $process.MainWindowHandle
                if ($handle.ToInt64()) {
                    break;
                }
        }
    }
    $handle = $process.MainWindowHandle 
    [User32]::ShowWindowAsync($handle,3)
    #Set-WindowStyle -Style Maximized
    #$wshell.SendKeys('{F11}')
}
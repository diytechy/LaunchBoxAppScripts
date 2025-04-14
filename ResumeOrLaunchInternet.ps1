Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
Add-Type -TypeDefinition @'
	using System;
	using System.Runtime.InteropServices;
    using System.Text;
	public class User32{
        [DllImport("user32.dll")] [return: MarshalAs(UnmanagedType.Bool)]  public static extern bool SetForegroundWindow(IntPtr hWnd);
        [DllImport("user32.dll")] [return: MarshalAs(UnmanagedType.Bool)]  public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);
	    [DllImport("user32.dll")] [return: MarshalAs(UnmanagedType.Bool)]  public static extern bool ShowWindowAsync(IntPtr hWnd, int nCmdShow);
}
'@

#Resolve home page location.
$sep = [System.IO.Path]::DirectorySeparatorChar
$scriptPathTst = $MyInvocation.MyCommand.Path
if ($scriptPathTst) {$scriptPath = $scriptPathTst}
$scriptDir = Split-Path $scriptPath
$HPP = ".." + $sep+ "BigPicLinkHTMLGenerator" + $sep + "LinkPage.html"
Set-Location $scriptDir
$HPFull = $scriptDir.ToString() + $sep.ToString() + $HPP

$HPResolved = Convert-Path $HPFull
$ResChk = Resolve-Path $HPResolved

$IDHndl = @(get-process | ? { $_.ProcessName -match "msedge"})
#If the process is open, switch to it.
$handle = $null
if($IDHndl){
    foreach ($process in $IDHndl) {
        $handle = $process.MainWindowHandle
        if ($handle.ToInt64() -and -not ($process.MainWindowTitle -eq "Messenger")) {
            break;
        }
        else{
        $handle = $null
        }
    }
}

if ($handle -and $handle.ToInt64()){
    [User32]::ShowWindowAsync($handle,3) #9?
    [User32]::SetForegroundWindow($handle)
}
else{
    #start microsoft-edge:http://google.com
    #$process = start microsoft-edge:file://$($ResChk.ToString())
    $process = start $HPResolved
    #$process = start microsoft-edge:http://google.com
    $wshell = New-Object -ComObject wscript.shell;
    #$wshell.AppActivate('Google - Microsoft Edge')
    $wshell.AppActivate('Image Tiles')
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
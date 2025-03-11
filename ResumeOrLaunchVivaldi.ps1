Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
Add-Type -TypeDefinition @'
	using System;
	using System.Runtime.InteropServices;
    using System.Text;
	public class User32{
        [DllImport("user32.dll")] [return: MarshalAs(UnmanagedType.Bool)]  public static extern bool SetForegroundWindow(IntPtr hWnd);
	}
'@
 
$RelPathDef = "..\Vivaldi\Application\vivaldi.exe --start-fullscreen"
$IDHndl = @(get-process | ? { $_.MainWindowTitle -match "vivaldi"})
#If the process is open, switch to it.
if($IDHndl){
    [User32]::SetForegroundWindow($IDHndl[0].mainwindowhandle)
}
#Else, open it.
else{
    $fullPath = Join-Path -Path $PSScriptRoot -ChildPath $RelPathDef
    Invoke-Expression $fullPath
}
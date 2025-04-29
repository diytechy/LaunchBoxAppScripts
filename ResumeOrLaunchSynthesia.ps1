Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
Add-Type -TypeDefinition @'
	using System;
	using System.Runtime.InteropServices;
    using System.Text;
	public class User32{
        [DllImport("user32.dll")] [return: MarshalAs(UnmanagedType.Bool)]  public static extern bool SetForegroundWindow(IntPtr hWnd);
        [DllImport("user32.dll", CharSet = CharSet.Auto, SetLastError = true)] public static extern int GetWindowText(IntPtr hwnd,StringBuilder lpString, int cch);
	}
'@
 
$IDHndl = @(get-process | ? { $_.ProcessName -match "Synthesia"})

#If the process is open, switch to it.
if($IDHndl){
    [User32]::SetForegroundWindow($IDHndl[0].mainwindowhandle)
}
#Else, open it.
else{
    #Start-Process -FilePath "msedge" -ArgumentList "--start-maximized", "https://www.youtube.com/"  -WindowStyle Normal
    #Start-Process -FilePath "msedge" -WindowStyle ([System.Diagnostics.ProcessWindowStyle]::Maximized), "https://www.youtube.com/"
    "C:\Program Files (x86)\Synthesia\Synthesia.exe"
}
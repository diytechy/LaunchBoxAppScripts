Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
Add-Type -TypeDefinition @'
	using System;
	using System.Runtime.InteropServices;
    using System.Text;
	public class User32{
	    [DllImport("user32.dll")] public static extern short GetAsyncKeyState(int virtualKeyCode);
        [DllImport("user32.dll", CharSet = CharSet.Auto, SetLastError = true)] public static extern int GetWindowText(IntPtr hwnd,StringBuilder lpString, int cch);
        [DllImport("user32.dll", SetLastError=true, CharSet=CharSet.Auto)] public static extern IntPtr GetForegroundWindow();
        [DllImport("user32.dll")] [return: MarshalAs(UnmanagedType.Bool)]  public static extern bool SetForegroundWindow(IntPtr hWnd);
        [DllImport("user32.dll", SetLastError=true, CharSet=CharSet.Auto)] public static extern Int32 GetWindowThreadProcessId(IntPtr hWnd,out Int32 lpdwProcessId);
        [DllImport("user32.dll", SetLastError=true, CharSet=CharSet.Auto)] public static extern Int32 GetWindowTextLength(IntPtr hWnd);
        [DllImport("user32.dll", CharSet = CharSet.Auto)] public static extern IntPtr SendMessage(IntPtr hWnd, UInt32 Msg, IntPtr wParam, string lParam);
	}
'@
 
$IDHndl = @(get-process | ? { $_.MainWindowTitle -eq "LaunchBox Big Box"})
if($IDHndl){
    [User32]::SetForegroundWindow($IDHndl[0].mainwindowhandle)
}
else{
$IDHndl = @(get-process | ? { $_.MainWindowTitle -eq "LaunchBox"})
    if($IDHndl){
        [User32]::SetForegroundWindow($IDHndl[0].mainwindowhandle)
    }
}
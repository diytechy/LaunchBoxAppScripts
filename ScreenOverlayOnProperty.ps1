Add-Type -TypeDefinition @'
	using System;
	using System.Runtime.InteropServices;
    using System.Text;
	public class User32{
	    [DllImport("user32.dll")] public static extern short GetAsyncKeyState(int virtualKeyCode);
        [DllImport("user32.dll", CharSet = CharSet.Auto, SetLastError = true)] public static extern int GetWindowText(IntPtr hwnd,StringBuilder lpString, int cch);
        [DllImport("user32.dll", SetLastError=true, CharSet=CharSet.Auto)] public static extern IntPtr GetForegroundWindow();
        [DllImport("user32.dll", SetLastError=true, CharSet=CharSet.Auto)] public static extern Int32 GetWindowThreadProcessId(IntPtr hWnd,out Int32 lpdwProcessId);
        [DllImport("user32.dll", SetLastError=true, CharSet=CharSet.Auto)] public static extern Int32 GetWindowTextLength(IntPtr hWnd);
	}
'@
$s_prev = 0

#Target res os 1920 x 1080
#Nominal 4x3 horizontal res is 1440
#Remaining half-res is 240 px
$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
$LastMovement = $StopWatch.Elapsed.TotalSeconds
#Mode:
#0 - No overlay
#1 - Windows overlay
#2 - Runnable overlay (Sheepshaver / 86box)
#0 - 
$OverlayMode = 0
#Idle loop check, only applies when 
While ($True) {
	$ksum = 0
	For ($k = 1; $k -le 255; $k++){
		$null = [User32]::GetAsyncKeyState($k) # Flush keyboard buffers
		If ([User32]::GetAsyncKeyState($k)) {
			$ksum = $ksum + $k
		}
	}
    #Get active window (Maybe don't need to do this so often?
    $a = [User32]::GetForegroundWindow()

    $mp = $position = [System.Windows.Forms.Cursor]::Position
	$s = $ksum
    $WaitTime = $StopWatch.Elapsed.TotalSeconds-$LastMovement
	If (($s_prev -ne $s) -or ($mp_prev -ne $mp)) {
		#Write-Host $ksum
		$s_prev = $s
        $mp_prev = $mp
        $LastMovement = $StopWatch.Elapsed.TotalSeconds
        #If the active window is for a dual save slot game emulator, overlay.
            #Else make sure the overlay is closed.
        #If the active window is for windows and the button is pressed, overlay?
            #Else make sure the overlay is closed.
	}
    #Do stuff when idle for "x" period.
    else
    {
        Write-Host $WaitTime
    }
    #If the active window is music related and the time has expired, open ProjectM
        #Else make sure the overlay is closed.
	Start-Sleep -Milliseconds 30
}
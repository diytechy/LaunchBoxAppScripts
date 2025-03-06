Add-Type -TypeDefinition @'
	using System;
	using System.Runtime.InteropServices;
	public class User32{
		[DllImport("user32.dll")] public static extern short GetAsyncKeyState(int virtualKeyCode);
	}
'@
$s_prev = 0


$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
$LastMovement = $StopWatch.Elapsed.TotalSeconds
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
	Start-Sleep -Milliseconds 50
}
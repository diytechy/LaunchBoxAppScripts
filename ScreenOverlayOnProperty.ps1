Add-Type -TypeDefinition @'
	using System;
	using System.Runtime.InteropServices;
	public class User32{
		[DllImport("user32.dll")] public static extern short GetAsyncKeyState(int virtualKeyCode);
	}
'@
$s_prev = 0

#Idle loop check, only applies when 
While ($True) {
	$ksum = 0
	For ($k = 1; $k -le 255; $k++){
		$null = [User32]::GetAsyncKeyState($k) # Flush keyboard buffers
		If ([User32]::GetAsyncKeyState($k)) {
			$ksum = $ksum + $k
		}
	}
    $mp = $position = [System.Windows.Forms.Cursor]::Position
	$s = $ksum
	If (($s_prev -ne $s) -or ($mp_prev -ne $mp)) {
		Write-Host $ksum
		$s_prev = $s
        $mp_prev = $mp
	}
	Start-Sleep -Milliseconds 50
}
Add-Type -TypeDefinition @'
	using System;
	using System.Runtime.InteropServices;
	public class User32{
		[DllImport("user32.dll")] public static extern short GetAsyncKeyState(int virtualKeyCode);
	}
'@
$s_prev = 0

While ($True) {
	$ksum = 0
	For ($k = 1; $k -le 255; $k++){
		$null = [User32]::GetAsyncKeyState($k) # Flush keyboard buffers
		If ([User32]::GetAsyncKeyState($k)) {
			$ksum = $ksum + $k
		}
	}
	$s = $ksum
	If ($s_prev -ne $s) {
		Write-Host $ksum
		$s_prev = $s
	}
	Start-Sleep -Milliseconds 50
}
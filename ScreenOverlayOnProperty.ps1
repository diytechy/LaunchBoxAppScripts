Add-Type -TypeDefinition @'
	using System;
	using System.Runtime.InteropServices;
	public class User32{
		[DllImport("user32.dll")] public static extern short GetAsyncKeyState(int virtualKeyCode);
	}
'@

While ($True) {
	$s = @()
	For ($k = 1; $k -le 255; $k++){
		$null = [User32]::GetAsyncKeyState($k) # Flush keyboard buffers
		If ([User32]::GetAsyncKeyState($k)) {
			Switch ($k) {
				1	{$s += "LMOUSE"}
				2	{$s += "RMOUSE"}
				4	{$s += "MMOUSE"}
				5	{$s += "MOUSE4"}
				6	{$s += "MOUSE5"}
				8	{$s += "BKSPC"}
				9	{$s += "TAB"}
				12	{$s += "CLEAR"}
				13	{$s += "ENTER"}
				16	{$s += "SHIFT"}
				17	{$s += "CTRL"}
				18	{$s += "ALT"}
				20	{$s += "CAPSLK"}
				27	{$s += "ESC"}
				32	{$s += "SPACE"}
				33	{$s += "PGUP"}
				34	{$s += "PGDN"}
				35	{$s += "END"}
				36	{$s += "HOME"}
				37	{$s += "LEFT"}
				38	{$s += "UP"}
				39	{$s += "RIGHT"}
				40	{$s += "DOWN"}
				44	{$s += "PRTSC"}
				45	{$s += "INS"}
				46	{$s += "DEL"}
				112	{$s += "F1"}
				113	{$s += "F2"}
				114	{$s += "F3"}
				115	{$s += "F4"}
				116	{$s += "F5"}
				117	{$s += "F6"}
				118	{$s += "F7"}
				119	{$s += "F8"}
				120	{$s += "F9"}
				121	{$s += "F10"}
				122	{$s += "F11"}
				123	{$s += "F12"}
				144	{$s += "NUMLK"}
				145	{$s += "SCRLK"}
				160	{$s += "LSHIFT"}
				161	{$s += "RSHIFT"}
				162	{$s += "LCTRL"}
				163	{$s += "RCTRL"}
				164	{$s += "LALT"}
				165	{$s += "RALT"}
				173	{$s += "MUTE"}
				174	{$s += "VOL-"}
				175	{$s += "VOL+"}
				176	{$s += "NEXT"}
				177	{$s += "PREV"}
				178	{$s += "STOP"}
				179	{$s += "PLAY/PAUSE"}
				default {$s += $k}
			}
		}
	}
	$s = $s -join ", "
	If ($s_prev -ne $s) {
		Write-Host "`r$s".PadRight(70,' ') -NoNewLine
		$s_prev = $s_
	}
	Start-Sleep -Milliseconds 20
}
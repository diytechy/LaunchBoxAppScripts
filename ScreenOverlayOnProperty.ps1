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
        [DllImport("user32.dll", SetLastError=true, CharSet=CharSet.Auto)] public static extern Int32 GetWindowThreadProcessId(IntPtr hWnd,out Int32 lpdwProcessId);
        [DllImport("user32.dll", SetLastError=true, CharSet=CharSet.Auto)] public static extern Int32 GetWindowTextLength(IntPtr hWnd);
        [DllImport("user32.dll", CharSet = CharSet.Auto)] public static extern IntPtr SendMessage(IntPtr hWnd, UInt32 Msg, IntPtr wParam, string lParam);
	}
'@

function Is-KeyboardActiveOrExitCodeSet {
	$ksum = 0
	For ($k = 1; $k -le 255; $k++){
		$null = [User32]::GetAsyncKeyState($k) # Flush keyboard buffers
		If ([User32]::GetAsyncKeyState($k)) {
			$ksum = $ksum + $k
            if($k -eq 27) #Esc val 
                {$exitkeyspressed = $exitkeyspressed+1}
            if($k -eq 115) #F4 val 
                {$exitkeyspressed = $exitkeyspressed+1}
		}
	}
    if($exitkeyspressed -gt 1){return 2}
    elseif($ksum){return 1}
    else{return 0}
}

$VideoPlayerNames="Youtube","Crunchyroll","Netrlix","Disney"
function Is-WindowVideoPlayer {

    param (
        [string]$WindowString
        )
    $NameMatchesVidList = 0
    foreach ($strchk in $VideoPlayerNames){
        if($WindowString -match $strchk){
            $NameMatchesVidList = 1
            break
        }
    }
    if($NameMatchesVidList){return $true}
    else{return $false}
}

function UpdateOverlays {

    param (
        $AppInd,
        $OverlayDef
        )
        #$OverlayDef[1].form.show()
    $ShowUpdated = 0
    if(1){
        Write-Host "App indexes input:"
        Write-Host $AppInd.Count
        Write-Host "Overlay Def Count:"
        Write-Host $OverlayDef.Count
        foreach ($Def in $OverlayDef){
            if($Def.AppIdx -eq $AppInd){
                $Def.form.Show()
                $ShowUpdated = $ShowUpdated+1
            }
            else{
                $Def.form.Hide()
            }
        }
    }
    return($ShowUpdated)
}


$s_prev = 0
$Slow_Roll_Trigger_Time = 1
$Music_Auto_Overlay_Wait = 7

#Target res os 1920 x 1080
#Nominal 4x3 horizontal res is 1440
#Remaining half-res is 240 px
$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
$LastMovement = $StopWatch.Elapsed.TotalSeconds
$SlowTime = $LastMovement
#Mode / App
#0 - No overlay / Default
#1 - Windows overlay
#2 - Runnable overlay (Sheepshaver / 86box)
#3 - Single Load / Save slot
#4 - Dual Load / Save slot
#10 - Music with timeout (Pandora / ect) to show ProjectM
#20 - Time to show custom screensaver
#100 - Video player or another app where screensaver should be ignored.
#255 - Powershell ISE
$SelApp      = 0
#Initialize all form definitions, and how it relates back to the app / mode.
$ScreenWidth = [System.Windows.Forms.Screen]::PrimaryScreen.Bounds.Width
$ScreenHeight = [System.Windows.Forms.Screen]::PrimaryScreen.Bounds.Height
$RuntimeDef =
@(
[pscustomobject]@{AppIdx=10;Cmd="..\ProjectM\ProjectM.exe"},
[pscustomobject]@{AppIdx=20;Cmd="..\WinAmp\WinAmp.exe"}
)
$OverlayDef =
@(
[pscustomobject]@{AppIdx=1;pos="c";ImgFile="OverlayGraphics\WinOverlay.png"},
[pscustomobject]@{AppIdx=2;pos="l";ImgFile="OverlayGraphics\RunnableL.png"},
[pscustomobject]@{AppIdx=2;pos="r";ImgFile="OverlayGraphics\RunnableR.png"},
[pscustomobject]@{AppIdx=3;pos="l";ImgFile="OverlayGraphics\SingleLL.png"},
[pscustomobject]@{AppIdx=3;pos="r";ImgFile="OverlayGraphics\SingleLR.png"},
[pscustomobject]@{AppIdx=4;pos="l";ImgFile="OverlayGraphics\DoubleLL.png"},
[pscustomobject]@{AppIdx=4;pos="r";ImgFile="OverlayGraphics\DoubleLR.png"}
)
$OverlayDef | Add-Member -MemberType NoteProperty -Name form -Value ([System.Windows.Forms.Form])
$OverlayDef | Add-Member -MemberType NoteProperty -Name image -Value ([System.Drawing.Image])
#Close the initialized object
foreach ($Def in $OverlayDef){
    $Def.form = New-Object System.Windows.Forms.Form
    #Get image
    $fullPath = Join-Path -Path $PSScriptRoot -ChildPath $Def.ImgFile
    $Def.image = [System.Drawing.Image]::FromFile($fullPath)
    #Determine position
    $YLoc = ($ScreenHeight - $Def.image.Height)/2
    if($YLoc -lt 0){$YLoc = 0}
    switch($Def.pos){
        "l"{$XLoc = 0;}
        "r"{$XLoc = $ScreenWidth - $Def.image.Width;}
        default{$XLoc = ($ScreenWidth - $Def.image.Width)/2}
    }
    if($XLoc -lt 0){$XLoc = 0}
    $Def.form.BackgroundImage = $Def.image
    $Def.form.FormBorderStyle = 'None'
    $Def.form.BackColor = "Silver"#[System.Drawing.Color]::Transparent
    $Def.form.TransparencyKey = $Def.form.BackColor
    $Def.form.Width = $Def.image.Width
    $Def.form.Height = $Def.image.Height
    $Def.form.TopMost = $true
    $Def.form.Opacity = 0.8
    $Def.form.StartPosition = 'Manual'
    $Def.form.Location = New-Object System.Drawing.Point($XLoc, $YLoc)
    $Def.form.FormBorderStyle = 'None'
    $Def.form.Text = Split-Path $Def.ImgFile -Leaf
}
$OverlayMode = 0
#Idle loop check, only applies when 
While ($True) {
    $keychk = Is-KeyboardActiveOrExitCodeSet
	$exitkeyspressed = 0
    $exittrig = 0
    #**************************
    if($keychk -gt 1){$exittrig = 1}
    #Update timers and check if anything has changed on mouse position and keyboard.
    $mp = $position = [System.Windows.Forms.Cursor]::Position
	$s = $keychk
    $CurrTime = $StopWatch.Elapsed.TotalSeconds
    $WaitTime = $CurrTime-$LastMovement
    $SlowRoll = $CurrTime-$SlowTime
	If (($s_prev -ne $s) -or ($mp_prev -ne $mp)) {
		$s_prev = $s
        $mp_prev = $mp
        $LastMovement = $StopWatch.Elapsed.TotalSeconds
	}
    #Do stuff when check timer passes.
    if ($SlowRoll -gt $Slow_Roll_Trigger_Time)
    {
        $PrevSelApp = $SelApp
        $SlowTime = $CurrTime
        #Get active window (Maybe don't need to do this so often?
        $whndl = [User32]::GetForegroundWindow()
        $WH = get-process | ? { $_.mainwindowhandle -eq $whndl }
        if(Is-WindowVideoPlayer($WH.MainWindowTitle)){
            $SelApp = 100}
        elseif($WH.ProcessName -like "powershell_ise"){
            $SelApp = 255}
        elseif(($WH.ProcessName -like "*sheepshaver*")`
         -or ($WH.ProcessName -like "*86box*")){
            $SelApp = 2}
        elseif(($WH.MainWindowTitle -like "*retroarch*")`
         -or ($WH.MainWindowTitle -like "*citra*")){
            $SelApp = 3}
        elseif(($WH.MainWindowTitle -like "*duckstation*")`
         -or ($WH.MainWindowTitle -like "*pcsx2*")`
         -or ($WH.MainWindowTitle -like "*pcsx2*")){
            $SelApp = 4}
        elseif(($WaitTime -gt $Music_Auto_Overlay_Wait)`
        -and (($WH.MainWindowTitle -like "*pandora*")`
         -or ($WH.ProcessName -like "*pandora*"))){
            $SelApp = 10}
        elseif($WaitTime -gt $Music_Auto_Overlay_Wait){
            $SelApp = 200}
        else{
            $SelApp = 0}
        #break;
        if($SelApp -ne $PrevSelApp){
            Write-Host $SelApp
            Write-Host $WaitTime
            UpdateOverlays $SelApp $OverlayDef
        }
    }
    else
    {
        #Write-Host $WaitTime
    }
    #If not exiiting,
    if(-not $exittrig)
    {}
    #Cleanup if the exit trigger is set.
    else{
        foreach ($Def in $OverlayDef){
            $Def.image.Dispose()
            $Def.form.Close()
            $Def.form.Close()
        }
        break
    }

    #If the active window is music related and the time has expired, open ProjectM
        #Else make sure the overlay is closed.

	Start-Sleep -Milliseconds 30
}
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

function Is-KeyboardActiveOrExitCodeSet {
	$ksum = 0
    $overlaykeyspressed = 0 
    $exitkeyspressed = 0 
	For ($k = 1; $k -le 255; $k++){
		$null = [User32]::GetAsyncKeyState($k) # Flush keyboard buffers
		If ([User32]::GetAsyncKeyState($k)) {
			$ksum = $ksum + $k
            if($k -eq 27) #Esc val 
                {$exitkeyspressed = $exitkeyspressed+1}
            if($k -eq 115) #F4 val 
                {$exitkeyspressed = $exitkeyspressed+1}
            if($k -eq 77) #M key
                {$overlaykeyspressed = $overlaykeyspressed+1}
            if($k -eq 17) #Left ctrl key
                {$overlaykeyspressed = $overlaykeyspressed+1}
            if($k -eq 18)#Left alt key
                {$overlaykeyspressed = $overlaykeyspressed+1}
		}
	}
    if($exitkeyspressed -gt 1){return 3}
    if($overlaykeyspressed -gt 2){return 2}
    elseif($ksum){return 1}
    else{return 0}
}

function Is-WindowActive {

    param (
        [string]$WindowString,
        $WindowMatch,
        $debug = 0
        )
    if($debug){
    Write-Host "WindowString:"
    write-Host $WindowString
    Write-Host "WindowMatch:"
    Write-Host $WindowMatch
    Write-Host "Options to check:"
    Write-Host $WindowMatch.Count
    }
    $NameMatches = 0
    foreach ($strchk in $WindowMatch){
        if($WindowString -match $strchk){
            $NameMatches = 1
            break
        }
    }
    if($NameMatches){return $true}
    else{return $false}
    break
}

$VideoPlayerNames="Youtube","Crunchyroll","Netflix","Disney"
function Is-WindowVideoPlayer {
    param ([string]$WindowString)
    return(Is-WindowActive $WindowString @($VideoPlayerNames))
}

$MusicPlayerNames="Pandora","Spotify","Amazon Music","Radio"
function Is-WindowMusicPlayer {
    param ([string]$WindowString)
    #$TstVal = Is-WindowActive $WindowString @($MusicPlayerNames) 1; Write-Host $TstVal
    return(Is-WindowActive $WindowString @($MusicPlayerNames))
}

function UpdateOverlays {

    param (
        $AppInd,
        $OverlayDef,
        $ActiveWinPID
        )
        #$OverlayDef[1].form.show()
    $ShowUpdated = 0
    if(1){
        foreach ($Def in $OverlayDef){
            if($Def.AppIdx -eq $AppInd){
                $Def.form.Show()
                $ShowUpdated = $ShowUpdated+1
                [User32]::SetForegroundWindow($ActiveWinPID)
            }
            else{
                $Def.form.Hide()
            }
        }
    }
    return($ShowUpdated)
}

function UpdateAutoExes {

    param (
        $AppInd,
        $AutoExeDef,
        $PrevAppInd,
        $proclist
        )
        #$OverlayDef[1].form.show()
    $ShowUpdated = 0;
    Write-Host Number of autodefs:
    Write-Host $AutoExeDef.Count
    foreach ($Def in $AutoExeDef){
        #First check to see if the process is already running.
        $fullPath = Join-Path -Path $PSScriptRoot -ChildPath $Def.Cmd
        $expprocname = [System.IO.Path]::GetFileNameWithoutExtension($fullPath)
        $RunningProc = $proclist | ? { $_.ProcessName -eq $expprocname }
        #If there is more than one running process, we don't know what to do with it, so don't do anything with it.
        Write-Host Number of matching processes:
        Write-Host $RunningProc.Count
        if($RunningProc.Count -gt 1){continue}
        
         
        if($Def.AppIdx -eq $AppInd){
            #If the process is already running, just bring it to the front
            Write-Host App found for process
            if($RunningProc){
                [User32]::SetForegroundWindow($RunningProc)
                $ShowUpdated = $ShowUpdated+1
            }
            #Else the process isn't running, we need to start it if possible.
            else{
                $RunCmd = 0
                #If there is optional definition content, figure out how to apply it.
                switch($AppInd){
                    #Custom screensaver, get the optional path, select a random video, and play it full screen on repeat.
                    20{
                        if(($Def.Opt.length) -and (Test-Path $Def.Opt -PathType Container)){
                            $AllMP4s = @(Get-ChildItem -Path $($Def.Opt) -Filter "*.mp4" -Recurse)
                            if($AllMP4s.Count){
                                $ShufMP4s = ($AllMP4s | Get-Random -Shuffle)
                                foreach($file in $ShufMP4s){

                                }
                                $AllFiles = "`"" + (($ShufMP4s | ForEach-Object {$_.FullName}) -join "`" `"") + "`""
                                $ApndCmd = " -L -f " + $AllFiles
                                $RunCmd  = 1;
                            }
                        }
                    }
                    default{
                        $ApndCmd = ""
                        $RunCmd  = 1;
                    }
                }

                if($RunCmd -and (Test-Path $fullPath -PathType Leaf)){
                    $FullExp = "`""+$fullPath+"`""
                    $parentDir = Split-Path -Path $fullPath -Parent
                    #$ResPath = Resolve-Path -LiteralPath $FullExp
                    Write-Host $fullPath
                    Write-Host $parentDir
                    Write-Host $ApndCmd
                    if($ApndCmd.Length)
                    {
                        Start-Process -FilePath $fullPath -WorkingDirectory $parentDir -ArgumentList $ApndCmd
                    }
                    else{
                        Start-Process -FilePath $fullPath -WorkingDirectory $parentDir
                    }
                    Write-Host $FullExp
                    #Write-Host $ResPath
                    #Invoke-Expression $FullExp
                    $ShowUpdated = $ShowUpdated+1
                }
            }
        }
        #If the app index was previously running, and now we've switched, close it if applicable.
        elseif($Def.AppIdx -eq $PrevAppInd){
            #If it is running, shut it down when it shouldn't be running.
            #If the process is already running, just bring it to the front
            if($RunningProc){
                Stop-Process -Id $RunningProc.ID -Force
            }
        }
    }
    return($ShowUpdated)
}


$s_prev = 0
$Slow_Roll_Trigger_Time = 0.5
$Music_Auto_Overlay_Wait = 7
$Video_Screensaver_Wait = 20
$WindowsMenuOverlayTimeout = 3

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
[pscustomobject]@{AppIdx=10;Cmd="..\ProjectM\projectMSDL.exe";Opt=""},
[pscustomobject]@{AppIdx=20;Cmd="..\vlc\vlc.exe";Opt=""}
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
$WindowsMenuOverlayTimer = $WindowsMenuOverlayTimeout
#Idle loop check, only applies when 
While ($True) {
    $keychk = Is-KeyboardActiveOrExitCodeSet
	$exitkeyspressed = 0
    $exittrig = 0
    #**************************
    if($keychk -eq 3){$exittrig = 1}
    
    if($keychk -eq 2)
    {
        $TripWinOverlay = 1
        if (($SelApp -eq 0) -or ($SelApp -eq 1)){
            $WindowsMenuOverlayTimer = 0
        }
    }
    else {$TripWinOverlay = 0}
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
        $proclist = get-process
        #Get active window (Maybe don't need to do this so often?
        $whndl = [User32]::GetForegroundWindow()
        $WH = $proclist | ? { $_.mainwindowhandle -eq $whndl }
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
        -and (Is-WindowMusicPlayer($WH.MainWindowTitle))){
            $SelApp = 10}
        elseif($WaitTime -gt $Video_Screensaver_Wait){
            $SelApp = 200}
        elseif ($WindowsMenuOverlayTimer -lt $WindowsMenuOverlayTimeout){
            $SelApp = 1
            }
        else{
            $SelApp = 0}
        #break;
        if($SelApp -ne $PrevSelApp){
            Write-Host $SelApp
            #Write-Host $WaitTime
            $OverlayFdbk = UpdateOverlays $SelApp $OverlayDef $whndl
            $AudoExeFdbk = UpdateAutoExes $SelApp $RuntimeDef $PrevSelApp $proclist

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
        exit
    }
    $WindowsMenuOverlayTimer = $WindowsMenuOverlayTimer+0.03
	Start-Sleep -Milliseconds 30
}
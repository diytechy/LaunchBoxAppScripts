Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing


$ImagePath = "overlay.jpg"  # Replace with the actual path to your image
$LocationX = 100  # X-coordinate for the image position
$LocationY = 100  # Y-coordinate for the image position
$fullPath = Join-Path -Path $PSScriptRoot -ChildPath $ImagePath
$Image = [System.Drawing.Image]::FromFile($fullPath)
Start-Sleep -Seconds 0.5
$ScreenWidth = [System.Windows.Forms.Screen]::PrimaryScreen.Bounds.Width
$ScreenHeight = [System.Windows.Forms.Screen]::PrimaryScreen.Bounds.Height

$form = New-Object System.Windows.Forms.Form
$form.FormBorderStyle = 'None'
#$form.BackColor = [System.Drawing.Color]::Transparent
#$form.TransparencyKey = $form.BackColor
$form.Width = $Image.Width / 2
$form.Height = $Image.Height / 4
$form.TopMost = $true
$form.StartPosition = 'Manual'
$form.Location = New-Object System.Drawing.Point($LocationX, $LocationY)

$ghndl = $form.CreateGraphics()
$ghndl.DrawImage($Image, 0, 0, $form.Width, $form.Height)
Start-Sleep -Seconds 0.5
$form.Show()

# Keep the form open until a key is pressed
Write-Host "Press any key to close the image overlay..."
Start-Sleep -Seconds 3
#[void][System.Console]::ReadKey($true)

# Clean up
$form.Close()
$form.Dispose()
$ghndl.Dispose()
$Image.Dispose()
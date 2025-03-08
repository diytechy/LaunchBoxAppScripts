Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing


$ImagePath = "OverlayGraphics\overlay.jpg"  # Replace with the actual path to your image
$LocationX = 100  # X-coordinate for the image position
$LocationY = 100  # Y-coordinate for the image position
$fullPath = Join-Path -Path $PSScriptRoot -ChildPath $ImagePath
$Image = [System.Drawing.Image]::FromFile($fullPath)
#Start-Sleep -Seconds 0.5
$ScreenWidth = [System.Windows.Forms.Screen]::PrimaryScreen.Bounds.Width
$ScreenHeight = [System.Windows.Forms.Screen]::PrimaryScreen.Bounds.Height

$form = New-Object System.Windows.Forms.Form
$form.FormBorderStyle = 'None'
$form.BackColor = "Silver"
$form.TransparencyKey = $form.BackColor
$form.Width = $Image.Width / 2
$form.Height = $Image.Height / 4
$form.TopMost = $true
$form.Opacity = 0.5
$form.StartPosition = 'Manual'
$form.Location = New-Object System.Drawing.Point($LocationX, $LocationY)
$form.BackgroundImage = $Image
$form.FormBorderStyle = 'None'
$form.Text = "My Custom Form Title"
Start-Sleep -Seconds 0.5
$form.Show()
Start-Sleep -Seconds 3
$form.Hide()
Start-Sleep -Seconds 3
$form.Show()
Start-Sleep -Seconds 3

# Clean up
$form.Close()
$form.Dispose()
$Image.Dispose()
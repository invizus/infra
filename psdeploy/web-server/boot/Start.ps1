Add-Type -AssemblyName System.Windows.Forms

### init variables

$diskpartScript = "null"
$WindowsImage = "null"
$LocalImage= "W:\image.wim"
$dismArgs = "/apply-image /imagefile:" + $LocalImage + " /index:1 /ApplyDir:W:\"
$MBRargs = "W:\Windows /l en-GB"


### init form and form elements

$Form = New-Object system.Windows.Forms.Form
$Form.Text = "Apply Windows 10 image"
$Form.TopMost = $true
$Form.Width = 470
$Form.Height = 319

$radioButton1 = New-Object system.windows.Forms.RadioButton
$radioButton1.Text = "BIOS - legacy BIOS based PCs"
$radioButton1.AutoSize = $true
$radioButton1.Width = 104
$radioButton1.Height = 20
$radioButton1.location = new-object system.drawing.point(15,15)
$radioButton1.Font = "Microsoft Sans Serif,10"
$radioButton1.Checked = $True

$radioButton2 = New-Object system.windows.Forms.RadioButton
$radioButton2.Text = "UEFI - newer PCs supporting UEFI partitions"
$radioButton2.AutoSize = $true
$radioButton2.Width = 104
$radioButton2.Height = 20
$radioButton2.location = new-object system.drawing.point(15,45)
$radioButton2.Font = "Microsoft Sans Serif,10"

$radioButton3 = New-Object system.windows.Forms.RadioButton
$radioButton3.Text = "MS Office 2013"
$radioButton3.AutoSize = $true
$radioButton3.Width = 104
$radioButton3.Height = 20
$radioButton3.location = new-object system.drawing.point(15,15)
$radioButton3.Font = "Microsoft Sans Serif,10"

$radioButton4 = New-Object system.windows.Forms.RadioButton
$radioButton4.Text = "MS Office 2016"
$radioButton4.AutoSize = $true
$radioButton4.Width = 104
$radioButton4.Height = 20
$radioButton4.location = new-object system.drawing.point(15,45)
$radioButton4.Font = "Microsoft Sans Serif,10"
$radioButton4.Checked = $True

$label1 = New-Object system.windows.Forms.Label
$label1.Text = "Select partition and MS Office version"
$label1.AutoSize = $true
$label1.Width = 25
$label1.Height = 10
$label1.location = new-object system.drawing.point(15,8)
$label1.Font = "Microsoft Sans Serif,10"

$label2 = New-Object System.Windows.Forms.Label
$label2.Text = "Progress should have been displayed here..."
$label2.AutoSize = $true
$label2.Width = 25
$label2.Height = 10
$label2.Location = new-object System.Drawing.Point(150,220)
$label2.Font = "Microsoft Sans Serif,10"

$button1 = New-Object system.windows.Forms.Button
$button1.Text = "Proceed"
$button1.Width = 111
$button1.Height = 29
$button1.location = new-object system.drawing.point(15,210)
$button1.Font = "Microsoft Sans Serif,10"
$button1.Enabled = $true

$GroupBox1 = New-Object System.Windows.Forms.GroupBox
$GroupBox1.Location = New-Object System.Drawing.Size(10,40)
$GroupBox1.Size = New-Object System.Drawing.Size(400,70)
$GroupBox1.Text = "Partitions"

$GroupBox2 = New-Object System.Windows.Forms.GroupBox
$GroupBox2.Location = New-Object System.Drawing.Size(10,120)
$GroupBox2.Size = New-Object System.Drawing.Size(400,70)
$GroupBox2.Text = "Office version"


### Add elements on the form

$Form.controls.Add($label1)
$Form.controls.add($GroupBox1)
$Form.controls.add($GroupBox2)
$GroupBox1.Controls.Add($radioButton1)
$GroupBox1.Controls.Add($radioButton2)
$GroupBox2.Controls.Add($radioButton3)
$GroupBox2.Controls.Add($radioButton4)
$Form.controls.Add($button1)


### Main function 

Function Proceed() {

	$button1.Enabled = $False
	$form.controls.Add($label2)
	$label2.Text = "Working..."

	if ($radioButton1.Checked) {$diskpartScript = "CreatePartitions-BIOS.txt"}
	if ($radioButton2.Checked) {$diskpartScript = "CreatePartitions-UEFI.txt"}
	if ($radioButton3.Checked) {$WindowsImage = "Win10-2013.wim"}
	if ($radioButton4.Checked) {$WindowsImage = "Win10-2016.wim"}

	$diskpartArgs = "/s X:\Scripts\" + $diskpartScript
	$WindowsLink = "http://webserver.private/images/" + $WindowsImage

	Write-Host " 
DISKPART command and script: diskpart.exe $diskpartArgs
Image will be downloaded: $WindowsLink
" -ForegroundColor Cyan

	sleep -s 1

	Write-Host "Partitioning disk... all previous data will be lost." -ForegroundColor Cyan
	Start-Process "X:\Windows\system32\diskpart.exe" -ArgumentList $diskpartArgs -Wait

	sleep -S 1

	Write-Host "Downloading image..." -ForegroundColor Cyan
	(New-Object System.Net.WebClient).DownloadFile($WindowsLink, $LocalImage)
	Write-Host "Download finished." -ForegroundColor Cyan

	#sleep -S 300

	Write-Host "Applying image..." -ForegroundColor Cyan

	#$maxRetries = 3; $retryCount = 0; $present = $false;
	#while 
	#if (Test-Path "W:\image.wim") { Start-Process "dism" -ArgumentList $dismArgs }
	if (Test-Path "W:\image.wim") { Start-Process "dism" -ArgumentList $dismArgs -Wait } else { Write-Host "Image not found. stopped" -ForegroundColor Red }

	sleep -S 2

	# Bootsector
	Write-Host "Setting bootable partition..." -ForegroundColor Cyan
	Start-Process "X:\Windows\System32\bcdboot.exe" -ArgumentList $MBRArgs -Wait
	sleep -S 3
	Remove-Item $LocalImage

### post-image actions before restart
# functions:
	Write-Host "Post imaging steps..."
	postImaging

### wrap up:

	Write-Host "All done. Remove disc or USB. Computer will restart in 30 seconds." -ForegroundColor Green
	$label2.Text = "Imaging done. Computer will restart now."
	sleep -S 30
	Restart-Computer

}


### Additional functions below

function postImaging() {

# After image is deployed and computer restarted, Windows will boot in audit mode where another script 
# (C:\Temp\Deploy\RunOnce.ps1) will be exectued but only once. That script will attempt to execute 
# C:\Temp\Deploy.ps1 if it exists. After Deploy.ps1 execution is done, script will run sysprep command
# to prepare Windows for user.
# Below you can download and drop Deploy.ps1 script on newly deployed image just after the imaging is done 
# before restart and in that script you can list your prefered software to be installed whilst in audit mode.

#	if (-Not (Test-Path W:\Temp\Deploy)) { New-Item W:\Temp\Deploy -type directory }
	Write-Host "Downloading Deploy script"
	Invoke-WebRequest "http://webserver.private/deploy/Deploy.ps1" -OutFile "W:\Temp\Deploy\Deploy.ps1"
}


### When user pressed the button it calls main function "Proceed"

$button1.Add_Click({Proceed})

[void]$Form.ShowDialog()
$Form.Dispose()



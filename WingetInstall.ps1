# Use this script to install winget and necessary software using winget as part of Custom Image template build

$software = @(
  @{ Name = 'Adobe.Acrobat.Reader.64-bit'; Source = 'winget'; Scope = 'machine' },
  @{ Name = 'Notepad++.Notepad++'; Source = 'winget'; Scope = 'machine' },
  @{ Name = '7zip.7zip'; Source = 'winget'; Scope = 'machine' }
)


#Initialise WebClient
$dc = New-Object net.webclient
$dc.UseDefaultCredentials = $true
$dc.Headers.Add("user-agent", "Inter Explorer")
$dc.Headers.Add("X-FORMS_BASED_AUTH_ACCEPTED", "f")

#Create temp folder
$InstallerFolder = $(Join-Path $env:ProgramData CustomScripts)
if (!(Test-Path $InstallerFolder)) {
  New-Item -Path $InstallerFolder -ItemType Directory -Force -Confirm:$false
}
	
#Check Winget Install
Write-Host "Checking if Winget is installed" -ForegroundColor Yellow
$TestWinget = Get-AppxProvisionedPackage -Online | Where-Object { $_.DisplayName -eq "Microsoft.DesktopAppInstaller" }
If ([Version]$TestWinGet. Version -gt "2022.506.16.0") {
  Write-Host "WinGet is Installed" -ForegroundColor Green
}
Else {
  #Download WinGet MSIXBundle
  Write-Host "Not installed. Downloading WinGet..." 
  $WinGetURL = "https://aka.ms/getwinget"
  $dc.DownloadFile($WinGetURL, "$InstallerFolder\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle")
  
  #Install WinGet MSIXBundle 
  Try {
    Write-Host "Installing MSIXBundle for App Installer..." 
    Add-AppxProvisionedPackage -Online -PackagePath "$InstallerFolder\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle" -SkipLicense 
    Write-Host "Installed MSIXBundle for App Installer" -ForegroundColor Green
  }
  Catch {
    Write-Host "Failed to install MSIXBundle for App Installer..." -ForegroundColor Red
  } 
}


function install_silent {
  Clear-Host
  Write-Host -ForegroundColor Cyan "Installing new Apps"
  Set-Location 'C:\Program Files\WindowsApps\Microsoft.DesktopAppInstaller_1.21.3482.0_x64__8wekyb3d8bbwe\'
  foreach ($s in $software) {
    .\winget.exe install --id $s.Name --source $s.Source --scope $s.Scope --silent --accept-source-agreements
  }
  # .\winget.exe install --id Adobe.Acrobat.Reader.64-bit --source winget --scope machine --silent --accept-source-agreements
}

install_silent

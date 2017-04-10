if(! (Test-Path variable:ConvertFormVcs))
{ throw "The project configuration is required, see the 'ConvertForm_ProjectProfile.ps1' script." }

Push-Location "$ConvertFormVcs\Tools"
try {
 .\Build.ps1
 Import-Module PSNuspec
}
Finally {
 Pop-Location        
}

$ModuleVersion=(Import-ManifestData "$ConvertFormDelivery\ConvertForm.psd1").ModuleVersion

$Result=nuspec 'ConvertForm' $ModuleVersion {
   properties @{
        Authors='Dardenne Laurent'
        Owners='Dardenne Laurent'
        Description=@'
Converting a Winform file (xxx.Designer.cs) to a PowerShell script .ps1.
'@
        title='ConvertForm module'
        summary='Converting a Winform file (xxx.Designer.cs) to a PowerShell script .ps1.'
        copyright='Copyleft'
        language='fr-FR'
        licenseUrl='https://creativecommons.org/licenses/by-nc-sa/4.0/'
        projectUrl='https://github.com/LaurentDardenne/ConvertForm'
        #iconUrl='https://github.com/LaurentDardenne/Template/blob/master/icon/ConvertForm.png'
        releaseNotes="$(Get-Content "$ConvertFormDelivery\CHANGELOG.md" -raw)"
        tags='Form Winform Convertion'
   }

   files {
        file -src "$ConvertFormDelivery\ConvertForm.psd1"
        file -src "$ConvertFormDelivery\ConvertForm.psm1"
        file -src "$ConvertFormDelivery\Transform.psm1"
        file -src "$ConvertFormDelivery\Resgen.Exe"
        file -src "$ConvertFormDelivery\Demo\" -target 'Demo\'
        file -src "$ConvertFormDelivery\Tools\Add-Header.ps1" -target 'Tools\Add-Header.ps1'
        file -src "$ConvertFormDelivery\fr-FR\" -target 'fr-FR\'
        file -src "$ConvertFormDelivery\ConvertFormLocalizedData.psd1"
        file -src "$ConvertFormDelivery\TransformLocalizedData.psd1"
        file -src "$ConvertFormDelivery\CHANGELOG.md"
   }
}

$Result|
  Push-nupkg -Path $ConvertFormDelivery -Source 'https://www.myget.org/F/ottomatt/api/v2/package'


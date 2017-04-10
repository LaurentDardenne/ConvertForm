if(! (Test-Path variable:ConvertFormVcs))
{ throw "The project configuration is required, see the 'ConvertForm_ProjectProfile.ps1' script." }

$ModuleVersion=(Import-ManifestData "$ConvertFormVcs\ConvertForm.psd1").ModuleVersion

$Result=nuspec 'ConvertForm' $ModuleVersion {
   properties @{
        Authors='Dardenne Laurent'
        Owners='Dardenne Laurent'
        Description=@'
Creation of ps1xml file dedicated to the extension methods contained in an assembly
'@
        title='ConvertForm module'
        summary='Converting a Winform file (xxx.Designer.cs) to a PowerShell script .ps1.'
        copyright='Copyleft'
        language='fr-FR'
        licenseUrl='https://creativecommons.org/licenses/by-nc-sa/4.0/'
        projectUrl='https://github.com/LaurentDardenne/ConvertForm'
        #iconUrl='https://github.com/LaurentDardenne/Template/blob/master/icon/ConvertForm.png'
        releaseNotes="$(Get-Content "$ConvertFormVcs\CHANGELOG.md" -raw)"
        tags='Form Winform Convertion'
   }

   dependencies {
        dependency Log4Posh 2.0.1
        dependency UncommonSense.PowerShell.TypeData 1.0.2
   }

   files {
        file -src "$ConvertFormVcs\ConvertForm.psd1"
        file -src "$ConvertFormVcs\ConvertForm.psm1"
        file -src "$ConvertFormVcs\Transform.psm1"
        file -src "$ConvertFormVcs\Resgen.Exe"
        file -src "$ConvertFormVcs\Demo\" -target 'Demo\'
        file -src "$ConvertFormVcs\Tools\Add-Header.ps1" -target 'Tools\Add-Header.ps1'
        file -src "$ConvertFormVcs\en-US\" -target 'en-US\'
        file -src "$ConvertFormVcs\fr-FR\" -target 'fr-FR\'
   }
}

$Result|
  Push-nupkg -Path $ConvertFormDelivery -Source 'https://www.myget.org/F/ottomatt/api/v2/package'


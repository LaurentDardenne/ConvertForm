# ConvertForm

![Logo](https://github.com/LaurentDardenne/ConvertForm/blob/master/Convert-Form-Icon.jpg)

Powershell module for converting a Winform file (xxx.Designer.cs) to a PowerShell script .ps1


To install this module :
```Powershell
$PSGalleryPublishUri = 'https://www.myget.org/F/ottomatt/api/v2/package'
$PSGallerySourceUri = 'https://www.myget.org/F/ottomatt/api/v2'

Register-PSRepository -Name OttoMatt -SourceLocation $PSGallerySourceUri -PublishLocation $PSGalleryPublishUri #-InstallationPolicy Trusted
Install-Module ConvertForm -Repository OttoMatt
```



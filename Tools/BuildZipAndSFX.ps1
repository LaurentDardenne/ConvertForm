if (-not $currentContext.tasks.default)
{ 
  Properties {
   $Configuration=$Config
   $PSVersion=$PSVersionTable.PSVersion.ToString()
  }
  Task default -Depends BuildZipAndSFX 
}

Task BuildZipAndSFX {
#Construit une archive autoextractible
 
  Pop-Location
   Set-location "$ConvertFormLivraison"
   Import-Module PsIonic 

   $ZipFileName="$ConvertFormLivraison\ConvertFormSetup.zip"
   
   $Files="$ConvertFormLivraison\*"
   $ReadOptions = New-Object Ionic.Zip.ReadOptions -Property @{ 
                    StatusMessageWriter = [System.Console]::Out
                  } 

   $Save=@{
		ExeOnUnpack="Powershell -noprofile -File .\ConvertFormSetup.ps1";  
        Description="Setup for the ConvertForm Powershell module"; 
        NameOfProduct="ConvertForm";
        VersionOfProduct="1.0.0";
        Copyright='This module is free for non-commercial purposes. Ce module est libre de droits pour tout usages non commercial'
	}
   $SaveOptions=New-ZipSfxOptions @Save

   Write-host "Crée l'archive $ZipFileName"
   dir $Files|
     Compress-ZipFile $ZipFileName
   Write-host "Puis crée une archive autoextractible"
   ConvertTo-Sfx -Path $ZipFileName -Save $SaveOptions -Read $ReadOptions  

  Push-Location  
      
} #BuildZipAndSFX
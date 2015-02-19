Function Test-LocalizedData {
#Recherche dans un script si des clés d'un fichier d'aide localisé sont inutilisées.
# Test-LocalizedData 'fr-FR' 'G:\PS\PsIonic\Psionic' 'PsionicLocalizedData.psd1' 'Psionic.psm1' 'PsionicMsgs\.'

 [CmdletBinding()]
 param(
      #Permet de pointer sur le fichier d'aide associé à une culture
     [Parameter(Position=0, Mandatory=$true,ValueFromPipelineByPropertyName=$true)]
   $Culture, 
      #Chemin de recherche
     [Parameter(Position=1, Mandatory=$true,ValueFromPipelineByPropertyName=$true)] 
   $Path,
      #Nom du fichier d'aide localisé (.psd1)
     [Parameter(Position=2, Mandatory=$true,ValueFromPipelineByPropertyName=$true)]
   $LocalizedFilename,
      #Nom du fichier dans lequel rechercher l'absence de clés issues du fichier d'aide localisé (.psd1)
     [Parameter(Position=3, Mandatory=$true,ValueFromPipelineByPropertyName=$true)]
   $FileName,
      #Expression régulière de recherche de clés.
      #constituée d'un préfixe et d'un nom de clé.
      #Ce préfixe sera le plus souvent un nom de variable utilisé dans le code du script $FileName :
      # Ex : '${NomDeModule}Msgs\.'  --> $PsIonicMsgs.ValueNotSupported
      #où ValueNotSupported est le nom de la clé recherchée 
     [Parameter(Position=4, Mandatory=$false,ValueFromPipelineByPropertyName=$true)]
   [string]$PrefixPattern=$null
  ) 
 process {          
  try {
    Write-Debug "$($PSBoundParameters.GetEnumerator()|% {"$($_.key)=$($_.value)"})"
   $result=$true
    Push-location $pwd
    Write-Verbose "Valide the culture $Culture" 
    Write-Debug "[$Culture] current directory $Path"
    Set-Location $Path 
    try {
     Import-LocalizedData -BindingVariable HelpMsg -Filename $LocalizedFilename -UI $Culture -BaseDirectory $Path #-EA Stop
     } 
     catch { #[System.Management.Automation.ActionPreferencesStopException]{ 
      Write-Error  "[$Culture] Fichier inconnu ${Path}\$Culture\$LocalizedFilename"
     }
    
     #Mémorise tout les lignes du code Powershell
    $Text=Get-Content $FileName
    
     #Pour toutes les clés déclarées dans le fichier d'aide précisé,
     #on recherche s'il existe au moins une occurence 
    $HelpMsg.Keys|
     Foreach {
      $CurrentName=$_
      Write-Debug "Search the key $_"
       #bug : https://connect.microsoft.com/PowerShell/feedback/details/684218/select-strings-quiet-never-returns-false
      [bool](Select-string -input $Text -Pattern "$PrefixPattern${_}" -Quiet) 
     }| 
     Where { $_ -eq $false}|
     Foreach { 
      $Result=$false
      Write-Warning "The Key $CurrentName is unused in the .psd1 $FileName."
     }
  } Finally {
      Pop-location
      $Result 
  }
 }
 } #Test-LocalizedData
 
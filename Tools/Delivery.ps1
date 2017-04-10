#Delivery.ps1                               
#Construit la livraison de ConvertForm via Psake

Properties {
   $Configuration='Release' #$Config   #todo parameterSet
   $PSVersion=$PSVersionTable.PSVersion.ToString()
   $Cultures= "fr-FR","en-US"
   $ProjectName='ConvertForm'
}

 #charge la fonction dans la portée de PSake
include "$ConvertFormTools\New-FileNameTimeStamped.ps1"

Task default -Depends Build, TestBomFinal

Task Build -Depends Clean, RemoveConditionnal { 
#Recopie les fichiers dans le répertoire de livraison  
$VerbosePreference='Continue'
#Doc xml localisée
   #US
   Copy "$ConvertFormVcs\en-US\ConvertFormLocalizedData.psd1" "$ConvertFormDelivery"
   Copy "$ConvertFormVcs\en-US\TransformLocalizedData.psd1" "$ConvertFormDelivery"
 

  #Fr 
   Copy "$ConvertFormVcs\fr-FR\ConvertForm.Help.xml" "$ConvertFormDelivery\fr-FR"
   Copy "$ConvertFormVcs\fr-FR\ConvertFormLocalizedData.psd1" "$ConvertFormDelivery\fr-FR"
   Copy "$ConvertFormVcs\fr-FR\Limites_et_composants_supportés.html" "$ConvertFormDelivery\fr-FR"
   Copy "$ConvertFormVcs\fr-FR\TransformLocalizedData.psd1" "$ConvertFormDelivery\fr-FR"
 

#Demos
     #Copie uniquement les fichiers versionnés
   Push-Location "$ConvertFormVcs\Demo\DemoTreeView"
    $Files=git ls-tree  -r HEAD --name-only
    $Directories=$Files|Split-Path -parent|Select-Object -unique
    $Directories|% {md "$ConvertFormDelivery\Demo\DemoTreeView\$_" > $null}
    $Files|
     Copy -LiteralPath {"$ConvertFormVcs\Demo\DemoTreeView\$_"} -Destination {"$ConvertFormDelivery\Demo\DemoTreeView\$_"} 
   Pop-Location 
   
     #Copie tous les fichiers du répertoire
   Copy "$ConvertFormVcs\Demo\DataBinding" "$ConvertFormDelivery\Demo\DataBinding" -Recurse
   Copy "$ConvertFormVcs\Demo\ErrorProvider" "$ConvertFormDelivery\Demo\ErrorProvider" -Recurse
   Copy "$ConvertFormVcs\Demo\IseAddon" "$ConvertFormDelivery\Demo\IseAddon" -Recurse
   Copy "$ConvertFormVcs\Demo\ProgressBar" "$ConvertFormDelivery\Demo\ProgressBar" -Recurse
   

#Module
      #Modules créés par la tâche RemoveConditionnal :
      #ConvertForm.psm1 et Transform.psm1
   Copy "$ConvertFormVcs\ConvertForm.psd1" "$ConvertFormDelivery" 

#Tools
   Copy "$ConvertFormVcs\Resgen.Exe" "$ConvertFormDelivery"  
   Copy "$ConvertFormVcs\Tools\Add-Header.ps1" "$ConvertFormDelivery\Tools"  
      
#Other 
   Copy "$ConvertFormVcs\CHANGELOG.md" "$ConvertFormDelivery\"
} #Build

Task RemoveConditionnal {
#Traite les pseudo directives de parsing conditionnelle

   $VerbosePreference='Continue'
   ."$ConvertFormTools\Remove-Conditionnal.ps1"
   Write-debug "Configuration=$Configuration"
   Dir "$ConvertFormVcs\ConvertForm.psm1","$ConvertFormVcs\Transform.psm1" |
    Foreach {
      $Source=$_
      Write-Verbose "Parse :$($_.FullName)"
      $CurrentFileName="$ConvertFormDelivery\$($_.Name)"
      Write-Warning "CurrentFileName=$CurrentFileName"
      if ($Configuration -eq "Release")
      { 
         Write-Warning "`tTraite la configuration Release"
         #Supprime les lignes de code de Debug et de test
         #On traite une directive et supprime les lignes demandées. 
         #On inclut les fichiers.       
        Get-Content -Path $_ -ReadCount 0 -Encoding UTF8|
         Remove-Conditionnal -ConditionnalsKeyWord 'DEBUG' -Include -Remove -Container $Source|
         Remove-Conditionnal -Clean| 
         Set-Content -Path $CurrentFileName -Force -Encoding UTF8        
      }
      else
      { 
         #On ne traite aucune directive et on ne supprime rien. 
         #On inclut uniquement les fichiers.
        Write-Warning "`tTraite la configuration DEBUG" 
         #Directive inexistante et on ne supprime pas les directives
         #sinon cela génére trop de différences en cas de comparaison de fichier
        Get-Content -Path $_ -ReadCount 0 -Encoding UTF8|
         Remove-Conditionnal -ConditionnalsKeyWord 'NODEBUG' -Include -Container $Source|
         Set-Content -Path $CurrentFileName -Force -Encoding UTF8       
         
      }
    }#foreach
} #RemoveConditionnal

Task Clean -Depends Init {
# Supprime, puis recrée le dossier de livraison   

   $VerbosePreference='Continue'
   Remove-Item $ConvertFormDelivery -Recurse -Force -ea SilentlyContinue
   "$ConvertFormDelivery\Tools",
   "$ConvertFormDelivery\Demo", 
   "$ConvertFormDelivery\fr-FR"|
   Foreach {
    md $_ -Verbose -ea SilentlyContinue > $null
   } 
} #Clean

Task Init -Depends TestBOM {
#validation à minima des prérequis

 Write-host "Mode $Configuration"
  if (-not (Test-Path $env:ProfileConvertForm))
  {Throw 'La variable $env:ProfileConvertForm n''est pas déclarée.'}
} #Init

Task TestBOM {
#Validation de l'encodage des fichiers AVANT la génération  
  Write-Host "Validation de l'encodage des fichiers du répertoire : $ConvertFormVcs"
  
  Import-Module DTW.PS.FileSystem -Global
  
  $InvalidFiles=@(&"$ConvertFormTools\Test-BOMFile.ps1" $ConvertFormVcs)
  if ($InvalidFiles.Count -ne 0)
  { 
     $InvalidFiles |Format-List *
     Throw "Des fichiers ne sont pas encodés en UTF8 ou sont codés BigEndian."
  }
} #TestBOM

#On duplique la tâche, car PSake ne peut exécuter deux fois une même tâche
Task TestBOMFinal {

#Validation de l'encodage des fichiers APRES la génération  
  
  Write-Host "Validation de l'encodage des fichiers du répertoire de livraison : $ConvertFormDelivery"
  $InvalidFiles=@(&"$ConvertFormTools\Test-BOMFile.ps1" $ConvertFormDelivery)
  if ($InvalidFiles.Count -ne 0)
  { 
     $InvalidFiles |Format-List *
     Throw "Des fichiers ne sont pas encodés en UTF8 ou sont codés BigEndian."
  }
} #TestBOMFinal

#Task ValideParameterSet Todo PSSA
#Task TestLocalizedData  todo module dependence

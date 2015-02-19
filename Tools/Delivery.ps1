#Delivery.ps1                               
#Construit la livraison de ConvertForm via Psake

Properties {
   $Configuration='Release' #$Config   #todo parameterSet
   $PSVersion=$PSVersionTable.PSVersion.ToString()
   $Cultures= "fr-FR","en-US"
   $ProjectName=$ConvertForm.ProjectName
}

 #charge la fonction dans la portée de PSake
include "$ConvertFormTools\New-FileNameTimeStamped.ps1"

Task default -Depends Delivery ,ValideParameterSet #,TestBomFinal

Task Delivery -Depends Clean, RemoveConditionnal { #,FindTodo {
#Recopie les fichiers dans le répertoire de livraison  
$VerbosePreference='Continue'
#Doc xml localisée
   #US
   #Copy "$ConvertFormVcs\en-US\PsIonicLocalizedData.psd1" "$ConvertFormLivraison\PsIonic\en-US\PsIonicLocalizedData.psd1" 

  #Fr 
   Copy "$ConvertFormVcs\fr-FR\ConvertForm.Help.xml" "$ConvertFormLivraison\fr-FR"
   Copy "$ConvertFormVcs\fr-FR\ConvertFormLocalizedData.psd1" "$ConvertFormLivraison\fr-FR"
   Copy "$ConvertFormVcs\fr-FR\Limites_et_composants_supportés.html" "$ConvertFormLivraison\fr-FR"
   Copy "$ConvertFormVcs\fr-FR\TransformLocalizedData.psd1" "$ConvertFormLivraison\fr-FR"
 

#Demos
     #Copie uniquement les fichiers versionnés
   Push-Location "$ConvertFormVcs\Demo\DemoTreeView"
    $Files=git ls-tree  -r HEAD --name-only
    $Directories=$Files|Split-Path -parent|Select-Object -unique
    $Directories|% {md "$ConvertFormLivraison\Demo\DemoTreeView\$_" > $null}
    $Files|
     Copy -LiteralPath {"$ConvertFormVcs\Demo\DemoTreeView\$_"} -Destination {"$ConvertFormLivraison\Demo\DemoTreeView\$_"} 
   Pop-Location 
   
     #Copie tous les fichiers du répertoire
   Copy "$ConvertFormVcs\Demo\DataBinding" "$ConvertFormLivraison\Demo\DataBinding" -Recurse
   Copy "$ConvertFormVcs\Demo\ErrorProvider" "$ConvertFormLivraison\Demo\ErrorProvider" -Recurse
   Copy "$ConvertFormVcs\Demo\IseAddon" "$ConvertFormLivraison\Demo\IseAddon" -Recurse
   Copy "$ConvertFormVcs\Demo\ProgressBar" "$ConvertFormLivraison\Demo\ProgressBar" -Recurse
   

#Module
      #Modules créés par la tâche RemoveConditionnal :
      #ConvertForm.psm1 et Transform.psm1
   Copy "$ConvertFormVcs\ConvertForm.psd1" "$ConvertFormLivraison" 

#Tools
   Copy "$ConvertFormVcs\Tools\Add-Header.ps1" "$ConvertFormLivraison\Tools"  
      
#Other 
   Copy "$ConvertFormVcs\Revisions.txt" "$ConvertFormLivraison"
} #Delivery

Task RemoveConditionnal -Depend TestLocalizedData {
#Traite les pseudo directives de parsing conditionnelle

   $VerbosePreference='Continue'
   ."$ConvertFormTools\Remove-Conditionnal.ps1"
   Write-debug "Configuration=$Configuration"
   Dir "$ConvertFormVcs\ConvertForm.psm1","$ConvertFormVcs\Transform.psm1" |
    Foreach {
      $Source=$_
      Write-Verbose "Parse :$($_.FullName)"
      $CurrentFileName="$ConvertFormLivraison\$($_.Name)"
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

Task TestLocalizedData -ContinueOnError {
 ."$ConvertFormTools\Test-LocalizedData.ps1"

 $SearchDir="$ConvertFormVcs"
 Foreach ($Culture in $Cultures)
 {
   Dir "$SearchDir\ConvertForm.psm1","$SearchDir\Transform.psm1"|          
    Foreach-Object {
       #Construit un objet contenant des membres identiques au nombre de 
       #paramètres de la fonction Test-LocalizedData 
      New-Object PsCustomObject -Property @{
                                     Culture=$Culture;
                                     Path="$SearchDir";
                                       #convention de nommage de fichier d'aide
                                     LocalizedFilename="$($_.BaseName)LocalizedData.psd1";
                                     FileName=$_.Name;
                                       #convention de nommage de variable
                                     PrefixPattern="$($_.BaseName)Msgs\."
                                  }
    }|   
    Test-LocalizedData -verbose
 }
} #TestLocalizedData

Task Clean -Depends Init {
# Supprime, puis recrée le dossier de livraison   

   $VerbosePreference='Continue'
   Remove-Item $ConvertFormLivraison -Recurse -Force -ea SilentlyContinue
   "$ConvertFormLivraison\Tools",
   "$ConvertFormLivraison\Demo", 
   "$ConvertFormLivraison\en-US", 
   "$ConvertFormLivraison\fr-FR"|
   Foreach {
    md $_ -Verbose -ea SilentlyContinue > $null
   } 
} #Clean

Task Init -Depends TestBOM {
#validation à minima des prérequis

 Write-host "Mode $Configuration"
  if (-not (Test-Path Variable:ConvertForm))
  {Throw "La variable ConvertForm n'est pas déclarée."}
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
  
  Write-Host "Validation de l'encodage des fichiers du répertoire : $ConvertFormLivraison"
  $InvalidFiles=@(&"$ConvertFormTools\Test-BOMFile.ps1" $ConvertFormLivraison)
  if ($InvalidFiles.Count -ne 0)
  { 
     $InvalidFiles |Format-List *
     Throw "Des fichiers ne sont pas encodés en UTF8 ou sont codés BigEndian."
  }
} #TestBOMFinal

Task ValideParameterSet {
 if ($PSVersion -eq "2.0")
 { Write-Warning "L'exécution de la tâche ValideParameterSet nécessite la version v3 ou supérieure de Powershell." }
 else
 {
    ."$ConvertFormTools\Test-DefaultParameterSetName.ps1"
    ."$ConvertFormTools\Test-ParameterSet.ps1"
    $Module=Import-Module "$ConvertFormLivraison\ConvertForm.psd1" -PassThru
    $WrongParameterSet= @(
      $Module.ExportedFunctions.GetEnumerator()|
       Foreach-Object {
         Test-DefaultParameterSetName -Command $_.Key |
         Where-Object {-not $_.isValid} |
         Foreach-Object { 
           Write-Warning "[$($_.CommandName)]: Le nom du jeu par défaut $($_.Report.DefaultParameterSetName) est invalide."
           $_
         }
        
         Get-Command $_.Key |
          Test-ParameterSet |
          Where-Object {-not $_.isValid} |
          Foreach-Object { 
            Write-Warning "[$($_.CommandName)]: Le jeu $($_.ParameterSetName) est invalide."
            $_
          }
       }
    )
    if ($WrongParameterSet.Count -gt 0) 
    {
      $FileName=New-FileNameTimeStamped "$ConvertFormLogs\WrongParameterSet.ps1"
      $WrongParameterSet |Export-CliXml $FileName
      throw "Des fonctions déclarent des jeux de paramétres erronés. Voir les détails dans le fichier :`r`n $Filename"
    }
  }
}#ValideParameterSet

Task FindTodo {
  if ($Configuration -eq "Release") 
  {
     $Pattern='(?<=#).*?todo'
     $ResultFile="$env:Temp\$ProjectName-TODO-List.txt"
     Write-host "Recherche les occurences des TODO"
     Write-host "Résultat dans  : $ResultFile"
                
     Get-ChildItem -Path $ConvertFormVcs -Include *.ps1,*.psm1,*.psd1,*.ps1xml,*.xml,*.txt -Recurse |
      Where { (-not $_.PSisContainer) -and ($_.Length -gt 0)} |
      Select-String -pattern $Pattern|Set-Content $ResultFile -Encoding UTF8
     Invoke-Item $ResultFile
  }
  else
  {Write-Warning "Config DEBUG : tâche inutile" } 
} #FindTodo

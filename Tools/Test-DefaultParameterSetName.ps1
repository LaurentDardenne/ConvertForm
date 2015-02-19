#Requires -Version 3
Function Test-DefaultParameterSetName{
<#
.SYNOPSIS
   Détermine si le nom du paramètre DefaultParameterSetName, de l'attribut 
   CmdletBinding, est présent dans la liste des noms de jeux de paramètre. 
.
   Si DefaultParameterSetName n'est pas utilisé, cette fonction renvoie $true.
.   
   Si DefaultParameterSetName est utilisé et qu'aucun autre jeu de paramètre 
   n'est déclaré, cette fonction renvoie $true.
.
   Si DefaultParameterSetName est utilisé et que son contenu ne correspond à 
   aucun nom de jeu de paramètre déclaré, cette fonction renvoie $false.
   Ce test est sensible à la casse.
   Le jeux de paramètre nommé 'Setup' est différent de celui nommé 'setup'.

.PARAMETER Command
  Nom de la fonction à tester.

.EXAMPLE
  Function F0{
    Param( 
     [Switch] $A
    )
  }

  Test-DefaultParameterSetName F0
.
  Le test de la fonction F0 renvoi $true.

.EXAMPLE
  Function F1{
   # Nomme le jeux par défaut, un seul jeux
   [CmdletBinding(DefaultParameterSetName="Fonctionnalite1")]         
    Param( 
     [Switch] $A
    )
  }
    Test-DefaultParameterSetName F1
.
  Le test de la fonction F1 renvoi $true.

.EXAMPLE
  Function F2{
  # Un seul jeux, pas de défaut
    Param( 
      [Parameter(ParameterSetName="Fonctionnalite1")]
     [Switch] $A
    )
  }  
  Test-DefaultParameterSetName F2
.
  Le test de la fonction F2 renvoi $true.

.EXAMPLE  
  Function F3{
  # Un seul jeux, un  défaut identique         
   [CmdletBinding(DefaultParameterSetName="Fonctionnalite1")]         
    Param( 
      [Parameter(ParameterSetName="Fonctionnalite1")]
     [Switch] $A
    )
  }  
  Test-DefaultParameterSetName F3
.
  Le test de la fonction F3 renvoi $true.

.EXAMPLE  
  Function F4{
  #Deux jeux, le jeu par défaut est inconnu ( cause : n'est pas utilisé par un des paramètres)         
   [CmdletBinding(DefaultParameterSetName="Fonctionnalite2")]         
    Param( 
      [Parameter(ParameterSetName="Fonctionnalite1")]
     [Switch] $A
    )
  }  
  Test-DefaultParameterSetName F4
.
  Le test de la fonction F4 renvoi $false.

.EXAMPLE
  Function F5{
    #Deux jeux, le jeu par défaut est inconnu ( cause : erreur sur la casse du nom)
   [CmdletBinding(DefaultParameterSetName="fonctionnalite1")]         
    Param( 
      [Parameter(ParameterSetName="Fonctionnalite1")]
     [Switch] $A
    )
  } 
  Test-DefaultParameterSetName F5
.
  Le test de la fonction F5 renvoi $true.
#>
 param (
   #Nom de la commande à tester
  [parameter(Mandatory=$True,ValueFromPipeline=$True)]
  [string]$Command
 ) 
begin {

  Function New-DefaultParameterSetNameValidation{
    param(
       [Parameter(Mandatory=$True,position=0)]
      $ModuleName,       
       [Parameter(Mandatory=$True,position=1)]
      $CommandName,
       [Parameter(Mandatory=$True,position=2)]
      $isValid,
       [Parameter(Mandatory=$True,position=3)]
      $Report
    )
  
    [pscustomobject]@{
      PSTypeName='DefaultParameterSetNameValidation';
      ModuleName=$ModuleName;
      CommandName=$CommandName;
       #Le nom déclaré dans DefaultParameterSetName est utilisé par au moins un paramètre. 
      isValid=$isValid;
      Report=$Report;
     }
}# New-DefaultParameterSetNameValidation

 Function New-DefaultParameterSetNameReport{
  #Mémorise les informations.
  #Utiles en cas de construction de rapport
    param(
       [Parameter(Mandatory=$True,position=0)]
      $isDefaultParameterSetNameValid,
      [Parameter(Mandatory=$True,position=1)]
      $isCaseSensitiveDetected,
       [Parameter(Mandatory=$True,position=2)]
      $DefaultParameterSetName,
       [Parameter(Mandatory=$True,position=3)]
      $ParameterSetNames
   )
  
    [pscustomobject]@{
      PSTypeName='DefaultParameterSetNameReport';
       #False si l'attribut CmdletBinding est déclaré et que le DefaultParameterSetName n'existe pas dans les jeux déclarés.  
       #True si aucun attribut CmdletBinding n'est pas déclaré ou s'il est le seul à déclarer un nom de jeu,
       #True si l'attribut CmdletBinding est déclaré et qu'il existe un seul jeu de même nom, 
       #Trues si l'attribut CmdletBinding est déclaré et qu'il existe dans les jeux déclarés
       #True par défaut
      isDefaultParameterSetNameValid=$isDefaultParameterSetNameValid;
      
       #True si le nom du jeu par défaut n'est pas unique (cas de casse différente) dans la liste des noms de jeux
       #False par défaut
      isCaseSensitiveDetected=$isCaseSensitiveDetected;
      
       #Contient le nom de jeux par défaut ou une chaîne vide
      DefaultParameterSetName=$DefaultParameterSetName;
      
       #Contient les noms des jeux déclarés via un paramètre.
       #Le tableau n'est pas renseigné si :
       # - Si l'attribut CmdletBinding n'est pas déclaré 
       # - Si l'attribut CmdletBinding est déclaré mais qu'il n'existe aucun jeu déclaré via un paramètre.
       # - Si l'attribut CmdletBinding est déclaré et qu'il n'existe un jeu déclaré via un paramètre de même nom.
      ParameterSetNames=$ParameterSetNames
     }
  }# New-DefaultParameterSetNameReport
}#begin

process {
  $Cmd=Get-Command $Command
  Write-Debug "Test $Command"
  $isDefaultParameterSetNameValid=$true
  $isCaseSensitiveDetected=$false
  
      #bug PS : https://connect.microsoft.com/PowerShell/feedback/details/653708/function-the-metadata-for-a-function-are-not-returned-when-a-parameter-has-an-unknow-data-type
  $oldEAP,$ErrorActionPreference=$ErrorActionPreference,'Stop'
   $SetCount=$Cmd.get_ParameterSets().count
  $ErrorActionPreference=$oldEAP
  
  $DPS=if ($Cmd.DefaultParameterSet -ne $null) {$Cmd.DefaultParameterSet} else {[string]::Empty}
  
  $T=@()

  Write-Debug "DPS est-il renseigné ? $($DPS -ne [string]::Empty)"
  Write-Debug "Nom de jeux de paramètre : $SetCount"
  
  if ($DPS -ne [string]::Empty)
  {
     if ($SetCount -gt 1)
     {
        #Récupère les noms de jeux ayant au moins un paramètre
        #Les paramètres communs sont dans le jeu nommée '__AllParameterSets'
       $T=$Cmd.Parameters.GetEnumerator()|% {$_.Value.Attributes.ParameterSetName}|select -Unique
       Write-Debug "T= $t" 
       
       if ( $DPS -eq '__AllParameterSets') #Nommage improbable, mais autorisé
       { 
         Write-Debug "Test sur __AllParameterSets" 
         $isDefaultParameterSetNameValid= $DPS -ceq '__AllParameterSets'
         if ($isDefaultParameterSetNameValid -eq $false)
         {$isCaseSensitiveDetected=$true}
       }
       else 
       { 
         Write-Debug "Test sur les jeux de paramètre"
         $isDefaultParameterSetNameValid= $DPS -in $T 
          #bug https://connect.microsoft.com/PowerShell/feedback/details/928085/parameterset-names-should-not-be-case-sensitive
          # Si DPS à la même casse on utilise le même jeu (nom identique), sinon PS en crée deux
         $isCaseSensitiveDetected= @($Cmd.ParameterSets.Name -eq $DPS).Count -gt 1 
       }
       
       Write-Debug "isDefaultParameterSetNameValid=$isDefaultParameterSetNameValid"

     }
  } 

  Write-Debug "isCaseSensitiveDetected=$isCaseSensitiveDetected"
  $isValid= $isDefaultParameterSetNameValid -and ($isCaseSensitiveDetected -eq $false)

  Write-Debug "isValid=$isValid"   
  $Report=New-DefaultParameterSetNameReport $isDefaultParameterSetNameValid $isCaseSensitiveDetected $DPS $T
  
  New-DefaultParameterSetNameValidation  $Cmd.ModuleName `
                                         $Cmd.Name `
                                         $isValid `
                                         $Report
 }#process
}#Test-DefaultParameterSetName

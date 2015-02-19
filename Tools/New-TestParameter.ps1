function New-TestSetParameters{
#Génére le produit cartésien de chaque jeux de paramètre d'une commande
#adapted from : #http://makeyourownmistakes.wordpress.com/2012/04/17/simple-n-ary-product-generic-cartesian-product-in-powershell-20/
 [CmdletBinding(DefaultParameterSetName="Nammed")]
 [OutputType([System.String])]
 param (
   
   [parameter(Mandatory=$True,ValueFromPipeline=$True)]
   [ValidateNotNull()]
  [System.Management.Automation.CommandInfo] $CommandName,
    
    [ValidateNotNullOrEmpty()]
    [Parameter(Position=0,Mandatory=$false)]
  [string[]] $ParameterSetNames='__AllParameterSets',
    
    [ValidateNotNullOrEmpty()]
    [Parameter(Mandatory=$false,ParameterSetName="All")]
  [string[]] $Exclude,
  
    [Parameter(ParameterSetName="All")]
  [switch] $All
)       

 begin {
  # Common parameters
  # [System.Management.Automation.Internal.CommonParameters].GetProperties()|Foreach {$_.name} 
  #  -Verbose (vb) -Debug (db) -WarningAction (wa)
  #  -WarningVariable (wv) -ErrorAction (ea) -ErrorVariable (ev)
  #  -OutVariable (ov) -OutBuffer (ob) -WhatIf (wi) -Confirm (cf)

  function getValue{
     if ($Value -eq $false)
     {
       Write-Debug "Switch is `$false, dont add the parameter name : $Result."
       return "$result"
     }
     else
     {
       Write-Debug "Switch is `$true, add only the parameter name : $result$Bindparam"
       return "$result$Bindparam"
     }
  }#getValue
  
  function AddToAll{
   param (
     [System.Management.Automation.CommandParameterInfo] $Parameter,
     $currentResult, 
     $valuesToAdd
   )
    Write-Debug "Treate '$($Parameter.Name)' parameter."
    Write-Debug "currentResult =$($currentResult.Count -eq 0)"
    $Bindparam=" -$($Parameter.Name)" 
      #Récupère une information du type du paramètre et pas la valeur liée au paramètre
    $isSwitch=($Parameter.parameterType.FullName -eq 'System.Management.Automation.SwitchParameter')
    Write-Debug "isSwitch=$isSwitch"
    $returnValue = @()
    if ($valuesToAdd -ne $null)
    {
      foreach ($value in $valuesToAdd)
      {
        Write-Debug "Add Value : $value "
        if ($currentResult -ne $null)
        {
          foreach ($result in $currentResult)
          {
            if ($isSwitch) 
            { $returnValue +=getValue } 
            else
            {
              Write-Debug "Add parameter and value : $result$Bindparam $value"
              $returnValue += "$result$Bindparam $value"
            }
          }#foreach
        }
        else
        {
           if ($isSwitch) 
           { $returnValue +="$($CommandName.Name)$(getValue)" } 
           else 
           {
             Write-Debug "Add parameter and value :: $Bindparam $value"
             $returnValue += "$($CommandName.Name)$Bindparam $value"
           }
        }
      }
    }
    else
    {
      Write-Debug "ValueToAdd is `$Null :$currentResult"
      $returnValue = $currentResult
    }
    return $returnValue
  }#AddToAll  
 }#begin

  process {
          
   foreach ($Set in $CommandName.ParameterSets)
   {
      if (-not $All -and ($ParameterSetNames -notcontains $Set.Name)) 
      { continue }
      elseif ( $All -and ($Exclude -contains $Set.Name)) 
      {
        Write-Debug "Exclude $($Set.Name) "
        continue
      }
      
      $returnValue = @()
      Write-Debug "Current set name is $($Set.Name) "
      Write-Debug "Parameter count=$($Set.Parameters.Count) "
      #Write-Debug "$($Set.Parameters|Select name|out-string) "
      foreach ($parameter in $Set.Parameters)
      {
        $Values=Get-Variable -Name $Parameter.Name -Scope 1 -ea SilentlyContinue
        if ( $Values -ne $Null) 
        { $returnValue = AddToAll -Parameter $Parameter $returnValue $Values.Value }
        else
        { $PSCmdlet.WriteWarning("The variable $($Parameter.Name) is not defined, processing the next parameter.") } 
      }
     New-Object PSObject -Property @{CommandName=$CommandName.Name;SetName=$Set.Name;Lines=$returnValue.Clone()}
   }#foreach
  }#process
} #New-TestSetParameters

<#
 #récupère les métadonnées d'une commande
$cmd=Get-Command Test-Path
 #Déclare un variable portant le même nom que le paramètre qu'on souhaite
 #inclure dans le produit cartésien. 
 #Chaque valeur du tableau crée une ligne d'appel 
$Path=@(
  "'c:\temp\unknow.zip'",
  "'Test.zip'",
  "(dir variable:OutputEncoding)",
  "'A:\test.zip'",
  "(Get-Item 'c:\temp')",
  "(Get-Service Winmgmt)",
  'Wsman:\*.*',
  'hklm:\SYSTEM\CurrentControlSet\services\Winmgmt'
)
#Le paramètre 'PathType' est une énumération de type booléen
$PathType=@("'Container'", "'Leaf'")
#Génére les combinaisons du jeu de paramètre nommée 'Path'
#Les paramètres qui ne sont pas associé à une variable, génére un warning.
$result=New-TestSetParameters -command $Cmd  -ParameterSetNames Path

#Nombre de lignes construites
$result.lines.count
#Exécution, Test-path n'a pas d'impact sur le FileSystem
$result.lines|% {Write-host $_ -fore green;$_}|Invoke-Expression

#On ajoute le paramètre 'iSValide' de type booléen
$isValid= @($true,$false)

#Génére les combinaisons du jeu de paramètre nommée 'Path'
#On supprime la génération du warning.
$result=New-TestSetParameters -command $Cmd  -ParameterSetNames Path -WarningAction 'SilentlyContinue'
#Nombre de lignes construites
$result.lines.count
#Tri des chaine de caractères puis exécution
$Result.lines|Sort-Object|% {Write-host $_ -fore green;$_}|Invoke-Expression

#On peut aussi générer du code de test pour Pester ou un autre module de test :
$Template=@'
#
    It "Test ..TO DO.." {
        try{
          `$result = $_ -ea Stop
        }catch{
            Write-host "Error : `$(`$_.Exception.Message)" -ForegroundColor Yellow
             `$result=`$false
        }
        `$result | should be (`$true)
    }
'@
$Result.Lines| % { $ExecutionContext.InvokeCommand.ExpandString($Template) }
#>

function Get-CommonParameters{ 
 [System.Management.Automation.Internal.CommonParameters].GetProperties()|
  Foreach {$_.name}
}#Get-CommonParameters

function Get-ParameterSet {
#renvoi à partir de $Command 
#les paramètres du jeux de paramètre indiqué
 param (
    [ValidateNotNull()]
    [Parameter(Mandatory=$True,ValueFromPipeline=$True)]
  [System.Management.Automation.CommandInfo] $Command,    
    
    [ValidateNotNullOrEmpty()]
    [Parameter(Position=1,Mandatory=$false)]
  [string]$ParameterSetName='__AllParameterSets',
  
  [switch] $List
  
 )  
   process {       
    if ( ($ParameterSetName -eq '__AllParameterSets') -and ($Command.ParameterSets.Count -gt 1) )
    { throw "La commande '$($Command.Name)' posséde plusieurs jeux de paramètre, précisez un des noms suivants : $($ofs=' , '; $cmd.ParameterSets|select -expand name)" }

    $I=0
    $Index=$Command.ParameterSets|? {$I++;$_.name -eq $ParameterSetName}|% { $I-1}
    if ($i -eq -1 -or $index -eq $null) 
    {throw "Le jeu de paramètre nommé '$ParameterSetName' n'existe pas " }
    Write-Debug "Index de $ParameterSetName : $Index"
    if ($List)
    { $Command.ParameterSets[$Index].Parameters|Select -expand Name}
    else 
    { ,$Command.ParameterSets[$Index].Parameters }
  }#process
} # Get-ParameterSet

function ConvertTo-VariableDeclaration {
#Associé à la fonction New-TestSetParameters
#Génére le code de déclaration des paramètres d'un jeux de paramètre d'une commande
 [CmdletBinding()]
 [OutputType([System.String])]
 param (
    [ValidateNotNullOrEmpty()]
    [Parameter(Position=0,Mandatory=$true,ValueFromPipeline=$True)]
   $ParameterSet,
   
    [ValidateNotNullOrEmpty()]
    [Parameter(Position=1,Mandatory=$false)]
  [scriptblock] $Code
)       
  
  begin {  
    [string[]]$CommonParameters=Get-CommonParameters
  }
  process {
    $List=New-object System.Collections.Arraylist
    Write-debug "Call ConvertTo-VariableDeclaration"
    $ParameterSet|
      Where { $CommonParameters -notContains $_.Name} |
      foreach { 
        $TypeName=$_.Parametertype
        $RuntimeType=$TypeName -as [type]
        write-debug $RuntimeType.fullname
        try{ 
         $Type=[Activator]::CreateInstance($RuntimeType) 
        }catch {
         $Type=$null
         Write-Debug "Impossible de construire le type $($RuntimeType.fullname)"            
        }
    
        write-debug ($Type -is [boolean])
        write-debug ($Type -is [switch])
        if ($Type -is [enum] )
        { 
           $ofs="','"
           $List.Add( ('[string[]] ${0}=(''{1}'')' -f $_.Name,"$([enum]::GetValues($Type.GetType()))") ) > $null
        }
        elseif ( ($Type -is [boolean]) -or ($Type -is [switch]))
        { 
           $List.Add( ('${0}=@($true,$false)'-f $_.Name) ) > $null 
        }
        else
        { 
           $List.Add( ('[{0}] ${1}={2}' -f $TypeName,$_.Name,'''""''') ) > $null
        }
        if ($PSBoundParameters.ContainsKey('Code')) 
        {  $List.Add("$Code") > $null }
      }
      ,$List
   }#process
}#ConvertTo-VariableDeclaration

<#
$Cmd=Get-Command Test-Path
 #insére l'appel de la génération du cas de test
 #pour les variables déclarées au moment de l'appel
$BuildCall= {  $Result +=(New-TestSetParameters -command $Cmd -ParameterSetNames 'Path' -Exclude 'Credential','UseTransaction').Lines

}
 #Liste des paramètres communs
[string[]]$Commons=Get-CommonParameters

 #Récupére la liste des paramètres du cmdlet ou de la fonction
 #Excepté les paramètres communs
[string[]] $Parameters=$Cmd|Get-ParameterSet 'Path' -List|
  Where { $Commons -notContains $_.Name}
 
 #Supprime les variables de tests
Remove-Variable $Parameters -ea SilentlyContinue 

 #construit les lignes de déclaration des variables de test
 #référencées par la fonction New-TestSetParameters
$CodeLines=$Cmd|
            Get-ParameterSet 'Path'|
            ConvertTo-VariableDeclaration -code $BuildCall
 
 #Ajoute l'initialisation de la collection            
$CodeLines.Insert(0,'$Result=@()') > $null
$CodeLines.Insert(0,'$Cmd=Get-Command Test-Path') > $null

#Crée le fichier de génération du jeux de test
$CodeLines > C:\Temp\InitVarTest.ps1

 #Reste à éditer ce fichier afin de renseigner le contenu des variables 
 # on peut également  réordonner l'ordre de déclaration des variables
 #notamment placer les paramètre de type switch et de type énumération
 #au début des déclarations, les combinaisons seront améliorées  
ii C:\Temp\InitVarTest.ps1
 
 #Puis on éxécute la génération du jeux de test 
. "C:\Temp\InitVarTest.ps1"

 #Le résultat
$Result

#Enfin l'objectif : insérez le code généré dans un script de test
#>
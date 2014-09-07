function New-ProjectVariable {
<#
.SYNOPSIS
    Créer une variable, de type hashtable, contenant des informations spécifiques à un projet.

.DESCRIPTION
    Cette fonction crée une variable, de type hashtable, contenant des informations 
    relatives à un projet, parmi ces informations certaines sont spécifiques à un 
    poste de travail, par exemple le nom du répertoire de travail local de Subversion. 
.
    Le nom de cette ou ces variables seront identiques dans les divers scripts d'un projet, tout 
    en étant configurées différemment sur chaque poste des membres de l'équipe projet.
.      
    L'objet créé dispose d'une méthode nommée NewVariables(), celle-ci crée des 
    variables, de type constantes, d'après les clés de la hashtable. 
    Ces variables facileteront les substitutions dans les chaînes de caractères.

.EXAMPLE
    $ProjetX=New-ProjectVariable 'ProjetX' 'C:\Temp\ProjectX' 'https://projectx.svn.codeplex.com/svn'
    $ProjetX|fl
    # Url                 : https://projectx.svn.codeplex.com/svn
    # Vcs                 : C:\Temp\ProjectX\ProjetX
    # ProjectName         : ProjetX
    # RepositoryLocation  : C:\Temp\ProjectX\ProjetX
.
    Cette exemple crée la variable $ProjetX contenant les informations spécifique à un projet.
.EXAMPLE
    $ProjectName='PsIonic'
     #Spécifique au poste de développement
    $SvnPathRepository='G:\PS'

    $Paths=@{
     Bin='$($Properties.RepositoryLocation)\Bin';
      #Spécifique au poste de développement, n'est pas versionné.
     Livraison='C:\Temp\$ProjectName';
     Tests='$($Properties.RepositoryLocation)\Tests';
     Tools='$($Properties.RepositoryLocation)\Tools';
     Help='$($Properties.RepositoryLocation)\Documentation\Helps';
     Setup='$($Properties.RepositoryLocation)\Setup';
      #Spécifique au poste de développement
     Logs='C:\Temp\Logs\$ProjectName'
    }
    
    $PsIonic=New-ProjectVariable $ProjectName $SvnPathRepository 'https://psionic.svn.codeplex.com/svn' $Paths

    $PsIonic.NewVariables()
    Get-ChilItem Variable:PsIonic* 
.
    Cet exemple crée la variable $Psionic contenant les différents répertoires 
    spécifique au projet. 
.  
    On retarde la substitution dans le contenu des clés de la variable $Paths.
.    
    L'appel à la méthode NewVariables() créés des variables, de type constantes,
    d'après les clés de la hashtable $PsIonic.
.    
    Pour $PsIonic.Tools la méthode crée la variable $PsIonicTools 
#>
 param (
      #Nom du projet
     [Parameter(Position=0, Mandatory=$true)]
     [ValidateNotNullOrEmpty()]
   [string]$ProjectName, 
     
     #Nom du répertoire de travail du projet utilisé par Subversion.
     [Parameter(Position=1, Mandatory=$true)]
     [ValidateNotNullOrEmpty()]
   [string]$VcsPath,
     
     #URL du server Subversion hébergeant le projet
     [Parameter(Position=2, Mandatory=$true)]
     [ValidateNotNullOrEmpty()]
   [string]$URlVcsServer,
     
     #Hashtable optionnelle portant des noms de variable à créer dans la portée 
     #de l'appelant.
     #.
     #Les valeurs des clés peuvent contenir des références à la variable interne 
     #$Properties, de type hashtable, qui déclare les clés suivantes :
     # ProjectName : Nom du projet.
     # Url         : Url du repository VCS.
     # Vcs         : Répertoire de la copie de travail (checkout). 
     # RepositoryLocation : Emplacement du répertoire racine dans la copie de travail. 
     #               Son contenu peut être identique à la clé VCS.
     [Parameter(Position=3, Mandatory=$false)]
     [ValidateNotNullOrEmpty()]
  [System.Collections.IDictionary] $ProjectParameters,

     #Portée dans laquelle créer la variable. Par défaut 1, celle de l'appelant.
     [Parameter(Mandatory=$false)]
   [int]$Scope=1,
   
   #Modifie le nom du répertoire racine du projet.
   #La clé nommée 'RepositoryLocation' pointera vers le répertoire "$VcsPath\$ProjectName\trunk", 
   #Sinon, par défaut, elle pointera vers le répertoire "$VcsPath\$ProjectName"
   [Switch]$TrunkDirectory
 )#param
  
  if ($TrunkDirectory)
  {$Trunk="$VcsPath\$ProjectName\trunk"}
  else
  {$Trunk="$VcsPath\$ProjectName"}

  # Hashtable 'primaire'
  # Ces clés peuvent être référencées dans le code de l'appelant
  $Properties=@{
     ProjectName=$ProjectName;
     Url=$URlVcsServer;
     Vcs="$VcsPath\$ProjectName";
     RepositoryLocation=$Trunk;
  }

  # Ajoute les clés de la hashtable additionnelle
  if ($PSBoundParameters.ContainsKey('ProjectParameters'))
  { 
       #Construit les noms de chemins
      $New=@{}
      $ProjectParameters.GetEnumerator() | 
       Foreach { 
          #V3 Bug 
          #$_.Value=$ExecutionContext.InvokeCommand.ExpandString(($_.Value))
          #une chaîne de type '$($Properties.RepositoryLocation)\Bin' -> Null Reference exception
         Write-debug "Before $($_.value)"
         $New."$($_.Key)"=iex "`"$($_.value)`""
         Write-debug ("After " + $New."$($_.Key)")
       }
      $Properties +=$New 
  }
  
  $method=[scriptblock]::Create(@"
    `$this.Psobject.Properties | 
      Foreach-Object {
        New-Variable "`$(`$this.ProjectName)`$(`$_.Name)" -Value `$_.Value -Option Constant -Scope $Scope
      }
"@)

  # La méthode NewVariable crée, à partir de la hashtable d'un projet, 
  # une variable constante par clé et ce dans le scope indiqué.
  # Le nom de la variable est préfixée par le nom du projet 
  # on évite les collisions de noms et facilite la saisie lors de la substitution de chaîne 
  New-Object PSObject -Property  $Properties|
   Add-Member -Passthru -Member ScriptMethod -Name NewVariables -Value $Method
} #New-ProjectVariable

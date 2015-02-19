#Remove-Conditionnal.ps1
Function Remove-Conditionnal {
<#
.SYNOPSIS
    Supprime dans un fichier source toutes les lignes placées entre deux 
    directives de 'parsing conditionnal', tels que #<DEFINE %DEBUG%> et 
    #<UNDEF %DEBUG%>. Il est également possible d'inclure des fichiers,
    de décommenter des lignes de commentaires ou de supprimer des lignes.
 
.DESCRIPTION
    La fonction Remove-Conditionnal filtre dans une collection de chaîne 
    de caractères toutes les lignes placées entre deux directives de
     'parsing conditionnal'.
.
    PowerShell ne propose pas de mécanisme similaire à ceux de la compilation 
    conditionnelle, qui permet à l'aide de directives d'ignorer certaines
     parties du texte source.      
.    
    Cette fonction utilise les constructions suivantes :
       . pour déclarer une directive : #<DEFINE %Nom_De_Directive_A%> 
       . pour annuler une directive :   #<UNDEF %Nom_De_Directive_A%>.
.
    Chacune de ces directives doit être placée en début de ligne et peut être 
    précédées d'un ou plusieurs caractères espaces ou tabulation.  
    Le nom de directive ne doit pas contenir d'espace ou de tabulation.
.
    Ces directives peuvent êtres imbriquées:
     #<DEFINE %Nom_De_Directive_A%> 
     
      #<DEFINE %Nom_De_Directive_B%> 
      #<UNDEF %Nom_De_Directive_B%>
     
     #<UNDEF %Nom_De_Directive_A%>
.
    Par principe la construction suivante n'est pas autorisée :
     #<DEFINE %Nom_De_Directive_A%> 
     
      #<DEFINE %Nom_De_Directive_B%> 
      #<UNDEF %Nom_De_Directive_A%>  #fin de directive erronée
     
     #<UNDEF %Nom_De_Directive_B%>  
.
    Ni celle-ci :
     #<DEFINE %Nom_De_Directive_A%> 
     
      #<UNDEF %Nom_De_Directive_B%>
      #<DEFINE %Nom_De_Directive_B%>      
      
     #<UNDEF %Nom_De_Directive_A%>
.
    La présence de directives DEFINE ou UNDEF orpheline génére une erreur.
.
    La directive REMOVE doit être placée en fin de ligne  :
       Write-Debug 'Test' #<%REMOVE%> 
.
    La directive UNCOMMENT doit être placée en fin de ligne  :
       #[FunctionalType('PathFile')] #<%UNCOMMENT%>
       ...
       #Write-Debug 'Test' #<%UNCOMMENT%>
.       
    Ces lignes seront tranformées en : 
       [FunctionalType('PathFile')]
       ...
       Write-Debug 'Test
.
      Le directive INCLUDE insére le contenu d'un fichier externe.
       Write-Host 'Code avant'
       #<INCLUDE %'C:\Temp\Test.ps1'%>"
       Write-Host 'Code aprés'       
.       
     Ces lignes seront tranformées en : 
       Write-Host 'Code avant'
       Write-Host "Insertion du contenus du fichier 'C:\Temp\Test.ps1'"
       Write-Host 'Code aprés'       

.PARAMETER InputObject
    Spécifie un objet hébergeant le texte du code source à transformer. 
    Cet objet doit pouvoir être énumérer en tant que collection de chaîne 
    de caractères afin de traiter chaque ligne du code source.
.
    Si le texte est contenu dans une seule chaîne de caractères l'analyse des 
    directives échouera, dans ce cas le code source ne sera pas transformé.

.PARAMETER ConditionnalsKeyWord
    Tableau de chaîne de caractères contenant les directives à rechercher.
. 
    Il n'est pas possible de combiner ce paramètre avec le paramètre -Clean. 
    les noms de directive 'REMOVE','INCLUDE' et 'UNCOMMENT' sont réservées.
.
    Chaque nom de directive ne doit pas contenir d'espace, ni de tabulation.
    Le nom de directive 'NOM' et distinct de '1NOM',de 'NOM2' ou de 'PRENOM'.     

.PARAMETER Container
    Contient le nom de la source de données d'où ont été extraite les ligne du 
    code source à transformer.
    En cas de traitement de la directive INCLUDE, ce paramètre contiendra 
    le nom du fichier déclaré dans cette directive.
        
.PARAMETER Clean
    Déclenche une opération de nettoyage des directives, ce traitement devrait 
    être la dernière tâche de transformation d'un code source.
    Ce paramètre filtre toutes les lignes contenant une directive. 
    Cette opération supprime seulement les lignes contenant une directive et pas le texte
    entre deux directives. Pour la directive UNCOMMENT, la ligne reste
    commentée.
.    
    Il est possible de combiner ce paramètre avec un ou plusieurs des 
    paramètres suivant :  -Remove -UnComment -Include 

.PARAMETER Encoding
    Indique le type d'encodage à utiliser lors de l'inclusion de fichiers. 
    La valeur par défault est ASCII.
    Pour plus de détails sur les type d'encodage disponible, consultez l'aide en 
    ligne du cmdlet Get-Content.
    
.PARAMETER Include
    Inclus le fichier précisé dans les directives : #<INCLUDE %'FullPathName'%>
    Cette directive doit être placée en début de ligne :
      #<INCLUDE %'C:\Temp\Test.ps1'%>"
.      
    Ici le fichier 'C:\Temp\Test.ps1' sera inclus dans le code source en 
    cours de traitement. Vous devez vous assurer de l'existence du fichier. 
    Ce nom de fichier doit être précédé de %' et suivi de '%>
.
    L'imbrication de fichiers contenant des directives INCLUDE est possible, 
    car ce traitement appel récursivement la fonction Remove-Conditionnal en 
    propageant la valeur des paramètres. Tous les fichiers inclus seront donc 
    traités avec les mêmes directives.
.
    Cette directive attend un seul nom de fichier.
    Les espaces en début et fin de chaîne sont supprimés.
    Ne placez pas de texte à la suite de cette directive. 
.       
    Il est possible de combiner ce paramètre avec le paramètre -Clean.
.
    Par défaut la lecture des fichiers à inclure utilise l'encodage ASCII.  
.
    L'usage d'un PSDrive dédié évitera de coder en dur des noms de chemin.
    Par exemple cette création de drive  :  
     $null=New-PsDrive -Scope Global -Name 'MyProject' -PSProvider FileSystem -Root 'C:\project\MyProject\Trunk'
    autorisera la déclaration suivante :
     #<INCLUDE %'MyProject:\Tools\New-PSPathInfo.ps1'%>    
    au lieu de 
     #<INCLUDE %'C:\project\MyProject\Trunk\Tools\New-PSPathInfo.ps1'%>                          

.PARAMETER Remove
    Supprime les lignes de code source contenant la directive <%REMOVE%>. 
.
    Il est possible de combiner ce paramètre avec le paramètre -Clean. 

.PARAMETER UnComment
    Décommente les lignes de code source commentées portant la 
    directive <%UNCOMMENT%>. 
.
    Il est possible de combiner ce paramètre avec le paramètre -Clean.

.EXAMPLE
    $Code=@'
      Function Test-Directive {
        Write-Host "Test"
       #<DEFINE %DEBUG%>
        Write-Debug "$DebugPreference"
       #<UNDEF %DEBUG%>   
      } 
    '@ 
    
    Remove-Conditionnal -Input ($code -split "`n") -ConditionnalsKeyWord  "DEBUG"
.        
    Description
    -----------
    Ces instructions créent une variable contenant du code, dans lequel on 
    déclare une directive DEBUG. Cette variable étant du type chaîne de 
    caractères, on doit la transformer en un tableau de chaîne, à l'aide de 
    l'opérateur -Split, avant de l'affecter au paramétre -Input. 
.    
    Le paramétre ConditionnalsKeyWord déclare une seule directive nommée 
    'DEBUG', ainsi configuré le code transformé correspondra à ceci :
    
       Function Test-Directive {
        Write-Host "Test"
       } 
       
    Les lignes comprisent entre la directive #<DEFINE %DEBUG%> et la directive
    #<UNDEF %DEBUG%> sont filtrées.   

.EXAMPLE
    $Code=@'
      Function Test-Directive {
        Write-Host "Test"
       #<DEFINE %DEBUG%>
        Write-Debug "$DebugPreference"
       #<UNDEF %DEBUG%>   
      } 
    '@ 
    
    ($code -split "`n")|Remove-Conditionnal -ConditionnalsKeyWord  "DEBUG"
.        
    Description
    -----------
    Cet exemple provoquera les erreurs suivantes :
      Remove-Conditionnal : Parsing annulé.
      Les directives suivantes n'ont pas de mot clé de fin : DEBUG:1
      
      throw : Parsing annulé.
      La directive #<UNDEF %DEBUG%> n'est pas associée à une directive DEFINE ('DEBUG:1')
    
    Le message d'erreur contient le nom de la directive suivi du numéro de 
    ligne du code source où elle est déclarée.
.
    La cause de l'erreur est due au type d'objet transmit dans le pipeline, 
    cette syntaxe transmet les objets contenus dans le tableau les uns à la 
    suite des autres, l'analyse ne peut donc se faire sur l'intégralité du code 
    source, car la fonction opére sur une seule ligne et autant de fois qu'elle
    reçoit de ligne.
.    
    Pour éviter ce problème on doit forcer l'émission du tableau en spécifiant 
    une virgule AVANT la variable de type tableau :
    
    ,($code -split "`n")|Remove-Conditionnal -ConditionnalsKeyWord  "DEBUG"
 
.EXAMPLE
    $Code=@'
      Function Test-Directive {
        Write-Host "Test"
       #<DEFINE %DEBUG%>
        Write-Debug "$DebugPreference"
       #<UNDEF %DEBUG%>   
      } 
    '@ > C:\Temp\Test1.PS1
    
    Get-Content C:\Temp\Test1.PS1 -ReadCount 0|
     Remove-Conditionnal -Clean
.        
    Description
    -----------
    La première instruction crée un fichier contenant du code, dans lequel on 
    déclare une directive DEBUG. La seconde instruction lit le fichier en 
    une seule étape, car on indique à l'aide du paramétre -ReadCount de 
    récupèrer un tableau de chaînes. Le paramétre Clean filtrera toutes les 
    lignes contenant une directive, ainsi configuré le code transformé 
    correspondra à ceci :
    
      Function Test-Directive {
        Write-Host "Test"
        Write-Debug "$ErrorActionPreference"
      } 
      
    Les lignes comprisent entre la directive #<DEFINE %DEBUG%> et la directive
    #<UNDEF %DEBUG%> ne sont pas filtrées, par contre les lignes contenant 
    une déclaration de directive le sont. 

.EXAMPLE
    $Code=@'
      Function Test-Directive {
        param (
           [FunctionalType('FilePath')] #<%REMOVE%>
         [String]$Serveur
        )
       #<DEFINE %DEBUG%>
        Write-Debug "$DebugPreference"
       #<UNDEF %DEBUG%>   
       
        Write-Host "Test"
       
       #<DEFINE %TEST%>
        Test-Connection $Serveur
       #<UNDEF %TEST%>         
      } 
    '@ > C:\Temp\Test2.PS1
    
    Get-Content C:\Temp\Test2.PS1 -ReadCount 0|
     Remove-Conditionnal -ConditionnalsKeyWord  "DEBUG"|
     Remove-Conditionnal -Clean
.        
    Description
    -----------
    Ces instructions déclarent une variable contenant du code, dans lequel on 
    déclare deux directives, DEBUG et TEST. 
    On applique le filtre de la directive 'DEBUG' puis on filtre les 
    déclarations des directives restantes, ici 'TEST'. 
.    
    Le code transformé correspondra à ceci :
    
      Function Test-Directive {
        param (
         [String]$Serveur
        )
        Write-Host "Test"
        Test-Connection $Serveur
      } 

.EXAMPLE
    $code=@'
    #<DEFINE %V3%>
    #Requires -Version 3.0
    #<UNDEF %V3%>
    
    #<DEFINE %V2%>
    #Requires -Version 2.0
    #<UNDEF %V2%>
    
    Filter Test {
    #<DEFINE %V2%>
     dir | % { $_.FullName } #v2
    #<UNDEF %V2%>
    
    #<DEFINE %V3%>
     (dir).FullName   #v3
    #<UNDEF %V3%>
    
    #<DEFINE %DEBUG%>
    Write-Debug "$DebugPreference"
    #<UNDEF %DEBUG%>  
    } 
    '@ -split "`n" 
    
     #Le code est compatible avec la v2 uniquement
    ,$Code|
      Remove-Conditionnal -ConditionnalsKeyWord  "V3","DEBUG"|
      Remove-Conditionnal -Clean
    
     #Le code est compatible avec la v3 uniquement
    ,$Code|
      Remove-Conditionnal -ConditionnalsKeyWord  "V2","DEBUG"|
      Remove-Conditionnal -Clean   
.        
    Description
    -----------
    Ces instructions génèrent, selon le paramétrage, un code dédié à une 
    version spécifique de Powershell. 
.    
    En précisant la directive 'V3', on supprime le code spécifique à la version 
    3. On génère donc du code compatible avec la version 2 de Powershell. 
    Le code transformé correspondra à ceci :
    
      #Requires -Version 2.0
      Filter Test {
       dir | % { $_.FullName } #v2
      } 
.    
    En précisant la directive V2 on supprime le code spécifique à la version 2 
    on génère donc du code compatible avec la version 3 de Powershell.
    Le code transformé correspondra à ceci :
    
      #Requires -Version 3.0
      Filter Test {
       (dir).FullName   #v3
      } 

.EXAMPLE
    $PathSource="C:\Temp"
    $code=@'
     Filter Test {
    #<DEFINE %SEVEN%>
      #http://psclientmanager.codeplex.com/  #<%REMOVE%>
     Import-Module PSClientManager   #Seven
     Add-ClientFeature -Name TelnetServer
    #<UNDEF %SEVEN%>
    
    #<DEFINE %2008R2%>
     Import-Module ServerManager  #2008R2
     Add-WindowsFeature Telnet-Server
    #<UNDEF %2008R2%>
    } 
    '@ > "$PathSource\Add-FeatureTelnetServer.PS1"
    
    
    $VerbosePreference='Continue'
    $Livraison='C:\Temp\Livraison'
    Del "$Livraison\*.ps1" -ea 'SilentlyContinue'
      
      #Le code est compatible avec Windows 2008R2 uniquement
    $Directives=@('SEVEN')
    
   Dir "$PathSource\Add-FeatureTelnetServer.PS1"|
     Foreach {
      Write-Verbose "Parse :$($_.FullName)"
      $CurrentFileName=$_.Name
      $_
     }|
     Get-Content -ReadCount 0|
     Remove-Conditionnal -ConditionnalsKeyWord $Directives -REMOVE|
     Remove-Conditionnal -Clean|
     Set-Content -Path (Join-Path $Livraison $CurrentFileName) -Force -Verbose
.        
    Description
    -----------
    Ces instructions génèrent un code dédié à une version spécifique de Windows. 
    On lit le fichier script prenant en compte plusieurs versions de Windows, 
    on le transforme, puis on le réécrit dans un répertoire de livraison.
.    
    Dans cette exemple on génère un script contenant du code 
    dédié à Windows 2008R2 :
     Filter Test {
       Import-Module ServerManager  #2008R2
       Add-WindowsFeature Telnet-Server
     }
.    
    En précisant la directive '2008R2' on génèrerait du code dédié à Windows 
    SEVEN.
    
.EXAMPLE
    @'
    #Fichier d'inclusion C:\Temp\Test1.ps1
    1-un
    '@ > C:\Temp\Test1.ps1
    #
    #     
    @'
    #Fichier d'inclusion C:\Temp\Test2.ps1
    #<INCLUDE %'C:\Temp\Test3.ps1'%>
    2-un
    #<DEFINE %DEBUG%>
    2-deux
    #<UNDEF %DEBUG%>  
    '@ > C:\Temp\Test2.ps1
    #
    #    
    @'
    #Fichier d'inclusion C:\Temp\Test3.ps1
    3-un
    #<INCLUDE %'C:\Temp\Test1.ps1'%> 
    $Logger.Debug('Test') #<%REMOVE%>
    #<DEFINE %PSV2%>
    3-deux
    #<UNDEF %PSV2%>  
    '@ > C:\Temp\Test3.ps1
    #
    #   
    Dir C:\Temp\Test2.ps1|
     Get-Content -ReadCount 0 -Encoding Unicode|
     Remove-Conditionnal -ConditionnalsKeyWord 'DEBUG' -Include -Container 'C:\Temp\Test2.ps1'
.        
    Description
    -----------
    Ces instructions créent trois fichiers avec l'encodage par défaut, 
    puis l'appel à Remove-Conditionnal génère le code suivant :
    #Fichier d'inclusion C:\Temp\Test2.ps1
    #Fichier d'inclusion C:\Temp\Test3.ps1
    3-un
    #Fichier d'inclusion C:\Temp\Test1.ps1
    1-un
    #<DEFINE %PSV2%>
    3-deux
    #<UNDEF %PSV2%>
    2-un      
.
    Chaque appel interne à Remove-Conditionnal utilisera les directives déclarées 
    lors du premier appel.
    La présence du paramètre -Container permet en cas d'erreur de retrouver
    le nom du fichier en cours de traitement.  

.INPUTS
    System.Management.Automation.PSObject

.OUTPUTS
    [string[]]

.NOTES
		Author:  Laurent Dardenne
		Version:  1.3
		Date: 27/01/2014

.COMPONENT
    parsing
    
.ROLE
    Windows Administrator
    Developper

.FUNCTIONALITY
    Global

.FORWARDHELPCATEGORY <Function>
#>           
[CmdletBinding(DefaultParameterSetName="NoKeyword")]
param (
         #S'attend à traiter une collection de chaîne de caractères
        [Parameter(Mandatory=$true,ValueFromPipeline = $true)]
      $InputObject,
      
        [ValidateNotNullOrEmpty()]
        [Parameter(position=0,ParameterSetName="Keyword")]
      [String[]]$ConditionnalsKeyWord,
      
       #Nom de la source hébergeant les données à traiter
        [AllowNull()]
      [String]$Container,
  
      [Microsoft.PowerShell.Commands.FileSystemCmdletProviderEncoding] $Encoding='ASCII',
       [Parameter(ParameterSetName="Clean")]
      [Switch] $Clean, #L'opération de nettoyage des directives devrait être la dernière tâche de transformation
      [Switch] $Remove, #on peut vouloir nettoyer les directives inutilisées et supprimer une ligne
      [Switch] $Include, #idem et inclure un fichier
      [Switch] $UnComment #idem, mais ne pas décommenter       
      
)
 Begin {
   function New-ParsingDirective {
    param(
         [Parameter(Mandatory=$true,position=0)]
        $Name,
         [Parameter(Mandatory=$true,position=1)]
        $Line,
         [Parameter(Mandatory=$true,position=2)]
        $isFilterParent
    )
      #Les paramétres liés définissent aussi les propriétés de l'objet
     $O=New-Object PSObject -Property $PSBoundParameters 
     $O.PsObject.TypeNames[0] = "ParsingDirective"
     $O|Add-Member ScriptMethod ToString {'{0}:{1}' -F $this.Name,$this.Line} -force -pass
   }#New-ParsingDirective
   
   Write-Debug "PSBoundParameters:"   
   $PSBoundParameters.GetEnumerator()|% { Write-Debug "`t$($_.key)=$($_.value)"}
   
   $RegexDEFINE="^\s*#<\s*DEFINE\s*%(?<DEFINE>.*[^%\s])%>"
   $RegexUNDEF="^\s*#<\s*UNDEF\s*%(?<UNDEF>.*[^%\s])%>"
     #Directives liées à un paramètre
   $ReservedKeyWord=@('Clean','Remove','Include','UnComment')
   $RegexConditionnalsKeyWord=[string]::Empty
   
     $oldofs,$ofs=$ofs,'|'
   $isConditionnalsKeyWord=$PSBoundParameters.ContainsKey('ConditionnalsKeyWord')
   if( $isConditionnalsKeyWord)
   { 
     Write-Debug "Traite ConditionnalsKeyWord : $ConditionnalsKeyWord" 
     $ConditionnalsKeyWord=$ConditionnalsKeyWord|Select -Unique
     $RegexConditionnalsKeyWord="$ConditionnalsKeyWord"
     
     $ConditionnalsKeyWord|
      Where {$Directive=$_; $Directive.Contains(' ')}|
      Foreach {Throw "Une directive contient des espaces :'$Directive'" }

     $ofs=','
     $KeyWordsNotAllowed=@(Compare-object $ConditionnalsKeyWord $ReservedKeyWord -IncludeEqual -PassThru| Where {$_.SideIndicator -eq "=="})
     if ($KeyWordsNotAllowed.Count -gt 0)
     { 
        $ofs=','
        Throw "Ces noms de directive sont réservées : ${KeyWordsNotAllowed}.Utilisez le paramétre associé."
     }     
   }
   $Directives=New-Object System.Collections.Stack
   $ofs=$oldofs
 }#begin       
 
 Process { 
   $LineNumber=0; 
   $isDirectiveBloc=$False

   $Result=$InputObject|
     Foreach-Object { 
       $LineNumber++
       [string]$Line=$_
       Write-Debug "`tLit  $Line `t  isDirectiveBloc=$isDirectiveBloc"
       switch -regex ($Line)  
       {
          #Recherche le mot clé de début d'une directive, puis l'empile 
         $RegexDEFINE {   
                          $CurrentDirective=$Matches.DEFINE
                          Write-Debug "DEFINE: Debut de la directive '$CurrentDirective'"
                          if (-not $Clean.isPresent)
                          {
                            if ($RegexConditionnalsKeyWord -ne [string]::Empty)
                            { $isFilter=$CurrentDirective -match $RegexConditionnalsKeyWord}
                            else 
                            { $isFilter=$false }
                            Write-Debug "Doit-on filtrer la directive trouvée : $isFilter"
                           
                            if ($Directives.Count -gt 0 )
                            { 
                              Write-Debug "Filtre du parent '$($Directives.Peek().Name)' en cours : $($Directives.Peek().isFilterParent)"
                               #La directive parente est-elle activée ?
                              if ($isFilter -eq $false )
                              {
                                  #La directive courante est imbriquée, le parent détermine le filtrage courant
                                 $isFilter=$Directives.Peek().isFilterParent 
                              } 
                            }
                            Write-Debug "Filtre en cours : $isFilter"  
                              #Mémorise la directive DEFINE, 
                              #le numéro de ligne du ficher courant et 
                              #l'état du filtrage en cours.
                            $O=New-ParsingDirective $CurrentDirective $LineNumber $isFilter 
                            $Directives.Push($O)
                           
                            if ($isFilter)
                            { $isDirectiveBloc=$True}
                            else 
                            {Write-Debug "`tEcrit la directive : $Line";$Line}
                            Write-debug "Demande du filtrage des lignes =$($isDirectiveBloc -eq $true)"
                          }
                          continue
                       }#$RegexDEFINE
                    
           #Recherche le mot clé de fin de la directive courante, puis dépile
          $RegexUNDEF  { 
                          $FoundDirective=$Matches.UNDEF
                          Write-Debug "UNDEF: Fin de la directive '$FoundDirective'"
                          if (-not $Clean.isPresent)
                          {                          
                             #Gére le cas d'une directive UNDEF sans directive DEFINE associée
                            $isDirectiveOrphan=$Directives.Count -eq 0
                            if ($Directives.Count -gt 0) 
                            {
                               $Last=$Directives.Peek()
                               $LastDirective=$Last.Name
                             
                               if ($LastDirective -ne $FoundDirective)
                               { Throw "Parsing annulé.`r`n$Container`r`nLes déclarations des directives '$Last' et '${FoundDirective}:$LineNumber' ne sont pas imbriquées."}
                               Write-Debug "Pop $LastDirective"
                               [void]$Directives.Pop() 
                            }
                            
                            if ($isDirectiveOrphan)
                            { Throw "Parsing annulé.`r`n$Container`r`nLa directive #<UNDEF %${FoundDirective}%> n'est pas associée à une directive DEFINE ('${FoundDirective}:$LineNumber')"}
                            
                            if ($Directives.Count -eq 0)
                            {
                              Write-Debug "Fin d'imbrication. On arrête le filtre"
                              $isDirectiveBloc=$False
                            }
                            elseif (-not $Directives.Peek().isFilterParent )
                            {  
                              Write-Debug "La directive '$($Directives.Peek().Name)' ne filtre pas. On arrête le filtre"
                              $isDirectiveBloc=$False 
                            }
                             #Si le parent ne filtre pas on émet la ligne 
                            if (-not $Last.isFilterParent )  
                            {Write-Debug "`tEcrit la directive : $Line";$Line }
  
                            Write-debug "Demande d'arrêt du filtre des lignes =$($isDirectiveBloc -eq $true)"
                          }
                          continue
                      }#$RegexUNDEF 
                      
          #Supprime la ligne                                      
         "#<%REMOVE%>"  {  Write-Debug "Match REMOVE"
                           if ($Remove.isPresent)
                           { 
                             Write-Debug "`tREMOVE Line"
                             continue 
                           }
                           if ($Clean.isPresent)
                           { 
                             Write-Debug "`tREMOVE directive"
                             $Line -replace "#<%REMOVE%>",'' 
                           }
                           else
                           { $Line } 
                           continue
                        }#REMOVE 
          
          #Décommente la ligne
         "#<%UNCOMMENT%>"  { Write-Debug "Match UNCOMMENT"
                             if ($UnComment.isPresent)
                             { 
                               Write-Debug "`tUNCOMMENT  Line"
                               $Line -replace "^\s*#*<%UNCOMMENT%>",''
                             }
                             elseif ($Clean.isPresent)
                             { 
                               Write-Debug "`tRemove UNCOMMENT directive"
                               $Line -replace "^\s*#*<%UNCOMMENT%>(.*)",'#$1'
                             } 
                             else
                             { $Line }
                             continue
                           } #%UNCOMMENT
          
          #Traite un fichier la fois
          #L'utilisateur à la charge de valider le nom et l'existence du fichier
         "^\s*#<INCLUDE\s{1,}%'(?<FileName>.*)'%>" { 
                             Write-Debug "Match INCLUDE"
                             if ($Include.isPresent)
                             {
                               $FileName=$Matches.FileName.Trim()
                               Write-Debug "Inclut le fichier $FileName"
                                #Lit le fichier, le transforme à son tour, puis l'envoi dans le pipe
                                #Imbrication d'INCLUDE possible
                                #Exécution dans une nouvelle portée 
                               if ($Clean.isPresent)
                               {
                                  Write-Debug "Recurse Remove-Conditionnal -Clean"
                                  $NestedResult= Get-Content $FileName -ReadCount 0 -Encoding:$Encoding|
                                                  Remove-Conditionnal -Clean -Remove:$Remove -Include:$Include -UnComment:$UnComment -Container:$FileName
                                  #Ici on émet le contenu du tableau et pas le tableau reçu
                                  #Seul le résultat final est renvoyé en tant que tableau 
                                 $NestedResult
                               }
                               else #if (-not $Clean.isPresent)
                               {
                                  Write-Debug "Recurse Remove-Conditionnal $ConditionnalsKeyWord"
                                  if ($isConditionnalsKeyWord)
                                  {
                                    $NestedResult= Get-Content $FileName -ReadCount 0 -Encoding:$Encoding|
                                                    Remove-Conditionnal -ConditionnalsKeyWord $ConditionnalsKeyWord -Remove:$Remove -Include:$Include -UnComment:$UnComment -Container:$FileName
                                  }
                                  else
                                  {
                                    $NestedResult= Get-Content $FileName -ReadCount 0 -Encoding:$Encoding|
                                                    Remove-Conditionnal -Remove:$Remove -Include:$Include -UnComment:$UnComment -Container:$FileName
                                  }
                                                                                                                                          
                                 $NestedResult
                               }
                             }
                             elseif (-not $Clean.isPresent)
                             { $Line }
                             continue
                           } #%INCLUDE
                      
                      
         default {
             #Emet les lignes qui ne sont pas filtrées
           if ($isDirectiveBloc -eq $false)
           {  Write-Debug "`tEcrit : $Line";$Line }
           else
           {  Write-Debug "`tFILTRE : $Line" } 
         }#default
      }#Switch
   }#Foreach
   
   if ($Directives.Count -gt 0) 
   { 
     $oldofs,$ofs=$ofs,','
     Write-Error "Parsing annulé.`r`n$Container`r`nLes directives suivantes n'ont pas de mot clé de fin : $Directives" 
     $ofs=$oldofs
  }
   else 
   { ,$Result } #Renvoi un tableau, permet d'imbriquer un second appel sans transformation du résultat
   $Directives.Clear()
 }#process
} #Remove-Conditionnal

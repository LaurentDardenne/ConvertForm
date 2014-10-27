function Test-UNCPath {
#Valide si un chemin est au format UNC (IPv4 uniquement).
#On ne valide pas l'existence du chemin
#http://msdn.microsoft.com/en-us/library/gg465305.aspx
#
#Note:
#  File I/O functions in the Windows API convert "/" to "\" as part of converting the name to an NT-style name, 
# except when using the "\\?\" prefix as detailed in the following sections.  (http://msdn.microsoft.com/en-us/library/aa365247%28VS.85%29.aspx)
#
#\\.\PHYSICALDRIVE1 -> false
#\\?\C:\temp -> false

 param(  
  [string] $Path,
  
   #Valide les chemins PS : 
   # 'FileSystem::\\localhost\c$\temp' 
   # 'Microsoft.PowerShell.Core\FileSystem::\\localhost\c$\temp'
  [switch] $Force 
  )
 try {
  if ($force)
  {
    If ($path -match '^(.*?)\\{0,1}FileSystem::(.*)')
    {$Path=$matches[2]}
  }
  $Uri=[URI]$Path.Replace('/','\')
  
    #Le nom de chemin doit comporter au moins deux segments : \\Server\Share\File_path
    #et il doit débuter par '\\' ou '//' et ne pas être suivi de '\' ou de'/'
   $isValid=($Uri -ne $Null) -and ($Uri.Segments -ne $null) -and ($Uri.Segments.Count -ge 2) -and ($Path -match '^(\\{2}|/{2})(?!(\\|/))')
   #IsUnc égale $true alors LocalPath contient un path UNC transformé et valide.
   
   Write-Debug "[Test-UNCPath] isValid=$isValid isUnc=$($Uri.IsUnc) $Path $($Uri.LocalPath)" #<%REMOVE%>
 }
 catch [System.Management.Automation.RuntimeException] {
   Write-Debug "[Test-UNCPath] $_" #<%REMOVE%>
   $isValid=$false
 }
 $isValid
} #Test-UNCPath
(Get-Item function:Test-UNCPath).Description='Test un chemin UNC IPv4'

Function New-PSPathInfo{
#Crée un objet détaillant un nom de chemin Powershell
 [CmdletBinding(DefaultParameterSetName = "Path")]          
 param(
    [Parameter(Mandatory=$true,ValueFromPipeline=$true,ParameterSetName="Path")]
   [string]$Path,
   
    [Parameter(Mandatory=$true,ValueFromPipeline=$true, ParameterSetName="LiteralPath")]
   [String]$LiteralPath
 )

 begin { 
    Function New-PSPathInfoError{
     #construit une string affectée à la propriété LastError
      param ($ErrorRecord)
     Return "[{0}] {1}" -F $ErrorRecord.Exception.GetType().FullName,$ErrorRecord.Exception.Message
    }#New-PSPathInfoError

    Function NewPSPathInfo{
     #construit un objet portant les informations d'analyse d'un PSPath
     param(
        [Parameter(position=1)]
      $Name,
      [switch] $asLiteral
    )
      Write-debug "name=$name" #<%REMOVE%>
      $Helper = $ExecutionContext.SessionState.Path
      $O=New-Object PSObject -Property @{
         # !! Certaines propriétés boolean sont affectées par défaut à $false
         #Leurs interprétation dépendent de la propriété LastError.
         #Par exemple pour un nom de chemin référençant un provider inexistant, 
         #Bien que dans ce cas IsAbsolute=$false, on ne peut en conclure que le nom de chemin est relatif.
          
                #Nom du chemin à analyser
              Name=$Name;
              
               #Mémorise le type d'interprétation du path
               #Par exemple pour 'C:\Temp\File[1-5]' sa résolution avec -Path échoue et avec -LiteralPath elle réussie.
               #Les objets seront différents.
               #Par exemple en utilisant -Path la propriété Win32PathName ne peut être renseigné, 
               #car les caractères '[1-5]' sont interprétés comme une demande de globbing.    
              asLiteral=$asLiteral
              
               #Indique si le chemin résolu est un chemin Powershell valide (pour un provider)
               #On peut donc l'utiliser pour un accès disque.
               #Un chemin comportant des jokers sera considéré comme invalide.
              isPSValid=$false
               
               #Liste des fichiers si le globbing est détecté. Les élements sont du type string.
               #Le globbing peut être détecté sans pour autant que le chemin renvoit de fichier.
               #Attention, parmis les les fichiers trouvés, on peut trouver des chemins devant 
               #être utilisés avec -LiteralPath.
               #*.* ne renvoit que les entrées contenant un point, pour tout sélectionner utiliser * 
               #Les fichiers ayant l'attribut 'hidden' seront absent de cette liste .   
              ResolvedPSFiles=@();
               
               #Texte de la dernière exception rencontrée (exceptions gérées uniquement)
               #On décharge l'appelant de la gestion des exceptions déclenchées dans ce traitement.
               #L'objectif est de savoir si oui ou non on peut utiliser un chemin, 
               #et pas pourquoi on ne peut pas. 
              LastError=$Null;
               
               #Contient le nom réel du chemin Powershell. cf. Win32PathName  
               #Par exemple avec 'New-PSDrive -name TestsWinform -root G:\PS\Add-Lib\Add-Lib\trunk\Tests\Convert-Form -psp FileSystem'
               #Pour 'TestsWinform:\1Form1.Designer.cs', on renvoi 'G:\PS\Add-Lib\Add-Lib\trunk\Tests\Convert-Form\1Form1.Designer.cs'
               #
               #Peut être vide selon le provider pointé et la syntaxe utilisée: 
               #'Alias:','FeedStore:','Function:','PscxSettings:\'
               #ex: cd function: ; $pathHelper.GetUnresolvedProviderPathFromPSPath('.') -> renvoi une chaîne vide sous PS v2. 
               #Ici le provider ne gère pas une hiérarchie d'objets (doit dériver de [System.Management.Automation.Provider.NavigationCmdletProvider])
              ResolvedPSPath=$Null;
               
               #Indique si le PSDrive existe ou pas
              isDriveExist=$false;
               
               #Indique si l'élément d'un provider existe ou pas. 
               #Un chemin comportant des jokers et renvoyant au moins un élement
               #positionne isItemExist à $true. 
              isItemExist=$False;
              
               #Indique si le parent de l'élément d'un provider existe ou pas.
               #Un élément parent peut exister sans que l'élement existe et 
               #Un élément parent peut ne pas exister.
               #On cherche à savoir si on doit créer l'accès avant de créer l'élément. 
              isParentItemExist=$False;

               #Précise si le provider indiqué par le nom de chemin $Name est celui du FileSystem
              isFileSystemProvider=$False;
               
               #Référence le provider du nom de chemin contenu dans $Name
              isProviderExist=$False;
               
               #Nom du provider associé au chemin $Name, soit il est précisé dans le nom, soit c'est le lecteur qui, s'il existe, porte l'info.
               #Pour les chemins relatif c'est le nom du provider du drive courant. Le résultat dépend donc de la localisation.
               #Voir le comportement du cmdlet natif Resolve-Path
              Provider=$Null;
               
               #Le nom de chemin ne contient pas de nom de drive, ce qui est le cas d'un chemin relatif, de '~' et d'un chemin de type UNC
              isAbsolute=$False;
               
               #Contient $True si le nom de chemin commence par 'NomDeProvider::' 
               #ou précédé du nom de snapin/module 0'Microsoft.PowerShell.Core\FileSystem::'
              isProviderQualified=$False;
               
               #Indique si le nom de chemin contient des caractères joker Powershell. 
               # Sous PS, le globbing comprend les caractères suivants :  *,?,[]
               #Si le paramètre -Literal est utilisé cette propriété vaut $false, 
               # car dans ce cas ces caractères ne sont pas interprété par PS.  
              isWildcard=$False;
               
               #Indique si le nom du provider de la localisation courante est le provider FileSystem
              isCurrentLocationFileSystem =$Helper.CurrentFileSystemLocation.Path -eq $Helper.CurrentLocation.Path
              
              #ATTENTION le nom du drive peut contenir des jokers ( 'C*' ) ou des espaces, exemple : ' C:\Temp\foo.txt'
                #dans ce cas le caractére espace est recopié dans Drivename. Il est possible de nommer un drive avec des espaces :
                # New-PSDrive -Name ' Toto' -PSProvider FileSystem -Root C:\Temp
                # Dir ' Toto:' 
                #
                #Pour un chemin UNC le nom du drive pointé est inconnu.             
               DriveName=$Null;
               
               #Nom du drive en cours lors de l'appel.
               #Contient le nom du drive courant ou le nom du provider si le chemin est ProviderQualified.
               CurrentDriveName=$null;
               
               #Indique si le chemin est au format UNC
               isUNC=$false
               
               #Contient la résolution nom d'un chemin du FileSystem.
               #Utilisable avec des API ou des programme externes. 
               #Bug PS pour le chemin 'C:\temp\...' ? 
               #cf. ResolvedPSPath
               Win32PathName=$null
             }          
      $O.PsObject.TypeNames.Insert(0,"PSPathInfo")
      $O
    }# NewPSPathInfo
 
   $pathHelper = $ExecutionContext.SessionState.Path
   
   $_EA= $null
   [void]$PSBoundParameters.TryGetValue('ErrorAction',[REF]$_EA)
   if ($_EA -ne $null) 
   { $ErrorActionPreference=$_EA}
   
   Write-Debug "New-PSPathInfo.Begin `$ErrorActionPreference=$ErrorActionPreference" #<%REMOVE%> 
 }#begin
  
 process {
   try {
     $isLiteral = $PsCmdlet.ParameterSetName -eq 'LiteralPath'
     if ( $isLiteral )
     { $CurrentPath=$LiteralPath }
     else
     { $CurrentPath=$Path }

     Write-Debug  "CurrentPath=$CurrentPath" #<%REMOVE%>
     $Infos=NewPSPathInfo $CurrentPath -asLiteral:$isLiteral

     $Infos.IsProviderQualified=$pathHelper.IsProviderQualified($CurrentPath)
     $ProviderInfo=$DriveInfo=$CurrentDriveName=$ursvPath=$null
    
      #Récupère le nom du drive
      #Ne déclenche pas d'exception pour les chemins erronés, sauf si $PsPath=$null
      #
      #Si le path est relatif alors Absolute est faux, dans ce cas le drive renvoyé est le drive courant
      #Si le path est Provider-Qualified alors Absolute est tjrs vrai. 
      #Si le provider ou le drive n'existe pas l'information IsAbsolute reste valide.
      #'~' renvoi $false
      #un chemin UNC renvoi $false
     $infos.IsAbsolute=$pathHelper.IsPSAbsolute($CurrentPath,[ref]$CurrentDriveName)
     
     #!! Attention : 
     #Pour les noms de chemin tel que 'FileSystem::\Temp\*' ou 'FileSystem::\Temp', 
     #PS renvoi le path pointé par [Environment]::CurrentDirectory
     # voir http://www.beefycode.com/post/The-Difference-between-your-Current-Directory-and-your-Current-Location.aspx
     
     try {
       #Si le path est ProviderQualified alors DriveInfo est à $null
       #Si la localisation est 'HKLM:\', alors pour le nom de chemin '..', l'appel renvoie HKEY_LOCAL_MACHINE\ qui est la racine courante, 
       #mais la racine courante du provider registry n'est pas un nom de drive PS, c'est ici le nom de la ruche.
       #Si la localisation est 'C:\', alors pour le nom de chemin '..', l'appel renvoie C:\ qui est la racine courante, pour le filesystem elle contient le nom du drive PS, 
       #car celui-ci existe en dehors de Powershell.
       #
       #Le nom de path '...' est pris en compte, mais selon les cmdlets il est considéré comme un chemin relatif :-/
       #Les chemins UNC débutant par plus de 2 '\' sont pris en compte, 
       # et fonctionne avec des cmdlets de PS v2, mais déclenchera des exceptions avec ces mêmes cmdlets sous la V3.  
      $ursvPath=$pathHelper.GetUnresolvedProviderPathFromPSPath($CurrentPath,[ref]$ProviderInfo,[ref]$DriveInfo)
      Write-debug "ursvPath=$ursvPath" #<%REMOVE%>
            
      $Infos.isProviderExist=$True     
      $Infos.Provider=$ProviderInfo.Name
      $Infos.isFileSystemProvider=$ProviderInfo.Name -eq 'FileSystem'

      Write-Debug "Provider : $ProviderInfo" #<%REMOVE%>
      Write-debug "IsProviderQualified = $($Infos.IsProviderQualified)" #<%REMOVE%>
      Write-debug "IsAbsolute = $($infos.IsAbsolute)" #<%REMOVE%>
      
      if ($Infos.IsProviderQualified -eq $false)
      {
        if ($Infos.IsAbsolute -eq $false) 
        {
          Write-debug "On change le path RELATIF : $ursvPath" #<%REMOVE%>
          $CurrentPath=$ursvPath
        }
#<DEFINE %DEBUG%>
        else  #sinon on perd l'information du provider HKLM:\*  --> HKEY_LOCAL_MACHINE\*
        { Write-debug "On ne change pas le path ABSOLU : $CurrentPath" } 
#<UNDEF %DEBUG%>         
        $Infos.IsUnc=Test-UNCPath $CurrentPath       
      }
      else 
      { 
        Write-debug "On ne change pas le path PROVIDER-QUALIFIED : $CurrentPath" #<%REMOVE%>
        #'Registry::\\localhost\c$\temp' ne doit pas être reconnu comme UNC 
        if ($Infos.isFileSystemProvider)  
        { 
          $lpath=$CurrentPath -replace '(.*?)::(.*)','$2'
          $Infos.IsUnc=Test-UNCPath $lpath
           #pour 'filesystem::z\' isValid renvoie true
           #'z:\' isValid  déclenche une exception DriveNotFound
           try {
             #Pour valider le path, on doit se placer sur le provider FS    
            Push-Location $env:windir
            [void]$PathHelper.IsValid($lpath)
           }finally {
             Pop-Location
           }
        } 
      }

      Write-debug "isUNC=$($Infos.IsUnc)" #<%REMOVE%>
      
       #Ici on ne traite que des drives connus sur des providers existant
      Write-debug "CurrentDrivename=$CurrentDrivename" #<%REMOVE%>
      $Infos.CurrentDrivename=$CurrentDrivename
      if ($DriveInfo -ne $null)
      {
        $Infos.DriveName=$DriveInfo.Name
        $infos.isDriveExist=$True
        Write-Debug "Drive name: $($DriveInfo.Name)" #<%REMOVE%>
      }
     
      #Pour 'c:\temp\MyTest[a' iswildcard vaut $true, mais le globbing est invalide, à priori la seule présence du [ renvoi $true  
      #Pour 'c:\temp\MyTest`[a' iswildcard vaut $false
      #pour 'Frm[AZ]'    iswildcard vaut $true
      #     'Frm`[AZ`]'   iswildcard vaut $false
      #      Frm``[AZ``]' iswildcard vaut $true 
      #Si c'est un chemin littéral les caractères génériques ne peuvent être interprétés, car il générerait une exception
      if ($isLiteral)
      {  $infos.isWildCard=[Management.Automation.WildcardPattern]::ContainsWildcardCharacters(([Management.Automation.WildcardPattern]::Escape($CurrentPath)))}
      else
      {  $infos.isWildCard=[Management.Automation.WildcardPattern]::ContainsWildcardCharacters($CurrentPath)}
       
      Write-Debug "Path résolu : $CurrentPath" #<%REMOVE%> 
     } catch [System.Management.Automation.ProviderInvocationException],
              # sur la registry les noms de chemin '\..' et '\..' déclenche :  
              #  Le chemin d'accès 'HKEY_LOCAL_MACHINE\..' fait référence à un élément situé hors du chemin d'accès de base 'HKEY_LOCAL_MACHINE'.  
             [System.Management.Automation.PSInvalidOperationException] {
       #Sur la registry, '~' déclenche cette exception, car la propriété Home n'est pas renseigné.
       Write-Debug  "$_" #<%REMOVE%>
       Write-Debug "Path n'est pas résolu : $CurrentPath" #<%REMOVE%>
       $Infos.LastError=New-PSPathInfoError $_
       #On quitte, car les informations nécessaires sont inconnues. 
       return
     } 
     
     if (($Infos.IsProviderQualified -eq $false) -and ($Infos.IsAbsolute -eq $false) -and ($Infos.isFileSystemProvider -eq $false) ) 
     {
       Write-debug "Ajoute le nom du provider : $CurrentPath" #<%REMOVE%>
       if ($Infos.IsUnc)
       {$Infos.ResolvedPSPath='FileSystem::'+$CurrentPath }
       else
       {$Infos.ResolvedPSPath=$Infos.Provider+'::'+$CurrentPath }
       Write-debug "Resultat après l'ajout : $($Infos.ResolvedPSPath)" #<%REMOVE%> 
     }
     else
     {$Infos.ResolvedPSPath=$CurrentPath}

     #Implémente Path et LiteralPath
     try {
       #Le globbing n'est pas pris en compte
       Write-Debug "isLiteral : $isLiteral" #<%REMOVE%>
       if ($isLiteral)
       { 
          #si le path est déjà échappé ( File`[az`]) l'analyse est fausse.
          #si le path est échappé ainsi ( File``[az``])  alors iswildcard est faux
         $EscapePath=[Management.Automation.WildcardPattern]::Escape($Infos.ResolvedPSPath)
         $Infos.isItemExist= $ExecutionContext.InvokeProvider.Item.Exists($EscapePath,$false,$false)
         
         if ($Infos.isItemExist)
         { $Infos.isParentItemExist=$true }
         else
         { $Infos.isParentItemExist=$ExecutionContext.InvokeProvider.Item.Exists(($pathHelper.ParseParent($EscapePath,'')),$false,$false) }
       } 
       else 
       { 
         $Infos.isItemExist= $ExecutionContext.InvokeProvider.Item.Exists($Infos.ResolvedPSPath,$false,$false)
         if ($Infos.isItemExist)
         { $Infos.isParentItemExist=$true }
         else
         { $Infos.isParentItemExist=$ExecutionContext.InvokeProvider.Item.Exists(($pathHelper.ParseParent($Infos.ResolvedPSPath,'')),$false,$false) } 
       }
       Write-Debug "L'item existe-t-il ? $($Infos.isItemExist)" #<%REMOVE%>
       Write-Debug "Le parent de l'item existe-t-il ? $($Infos.isParentItemExist)" #<%REMOVE%>
       if ($Infos.isItemExist)
       {
        try {
           Write-Debug "Analyse le globbing." #<%REMOVE%>
           $provider=$null
            #renvoi le nom du provider et le fichier (-Literal) ou les fichiers en cas de globbing (-Path)
           if ($isLiteral)
           { 
             #Les fichiers ayant l'attribut 'hidden' ne sont pas renvoyés.
             $Infos.ResolvedPSFiles=@($pathHelper.GetResolvedProviderPathFromPSPath(([Management.Automation.WildcardPattern]::Escape($Infos.ResolvedPSPath)),[ref]$provider)) 
           }
           else 
           { $Infos.ResolvedPSFiles=@($pathHelper.GetResolvedProviderPathFromPSPath($Infos.ResolvedPSPath,[ref]$provider)) }
           Write-Debug ("ResolvedPSFiles.Count={0}" -F $Infos.ResolvedPSFiles.Count) #<%REMOVE%> 
         } catch [System.Management.Automation.PSInvalidOperationException] {
             Write-Debug  "Exception GetResolvedProviderPathFromPSPath : $($_.Exception.GetType().Name)" #<%REMOVE%>
             #Sur la registry, '~' déclenche cette exception, car par défaut sa propriété Home n'est pas renseignée.
         }
       }
     }  
     catch [System.Management.Automation.MethodInvocationException]  {
           #Path Invalide. 'C:\temp\t>\t.txt' -> "Caractères non conformes dans le chemin d'accès."
       Write-Debug  "$_" #<%REMOVE%>
       Write-Debug  "Exception Exists: $($_.Exception.GetType().Name)" #<%REMOVE%>
       $Infos.LastError=New-PSPathInfoError $_          
     }

    }#try
    catch [System.Management.Automation.ProviderNotFoundException],

              #Le lecteur physique peut ne pas exister, exemple A:\
          [System.Management.Automation.DriveNotFoundException],

              #Le lecteur physique existe, mais est amovible exemple A:\ ou un lecteur de CD-Rom
              #Avec : New-PSDrive -name ' Space' -root C:\Temp -psp FileSystem
              #l'appel de    : ' Space:\Test'|New-PSPathInfo
              # le message d'erreur contiendra la référence à 'C:\Temp\Test' et pas ' Space:\Test' 
              #pour 'Registry::HKLM:\System' le message d'erreur référencera « HKLM:\System » 
          [System.Management.Automation.ItemNotFoundException],

           #Path Invalide.
          [System.Management.Automation.PSArgumentException],

           # Caractères génériques invalides.
          [System.Management.Automation.WildcardPatternException], 

           #Pour les items du filesystem contenant des caractères interdits :  < > | : ? * etc
           #Pour le 'etc' voir : [System.IO.Path]::GetInvalidFileNameChars()
           #Les noms de chemin contenant un nom de périphérique Win32 tels que 
           # PRN, AUX, CLOCK,NUL,CON,COM1,LPT2...
           #sont testé en interne par le provider FileSystem. 
           #Ces noms ne peuvent exister et seront considérés comme inconnus.
           #Pour d'autres provider ces caractères et noms peuvent être autorisés.
          [System.NotSupportedException] {
      Write-Debug  "Exception : $($_.Exception.GetType().Name)" #<%REMOVE%>
      $Infos.LastError=New-PSPathInfoError $_
    }
    finally {

      #Répond à la question : Le nom de chemin est-il un nom valide pour le FileSystem?
      $Infos| 
        Add-Member -Membertype Scriptmethod -Name IsaValidNameForTheFileSystem{
           $result= $this.isPSValid  -and
                   ($this.LastError -eq $null)  -and 
                   (($this.isFileSystemProvider -eq $true) -or ($this.isUNC -eq $true)) -and 
                   ($this.isWildcard -eq $false)  
#<DEFINE %DEBUG%>
          if (-not $result)
          { Write-Debug "Chemin invalide pour une utilisation sur le FileSystem : $($this.GetFileName())" } 
#<UNDEF %DEBUG%>          
          $result                    
        }  

      $Infos| 
        Add-Member -Membertype Scriptmethod -Name GetFileName { #todo rename GetPathName peut être une répertoire ou un fichier
          If ($this.Win32PathName -ne $null) 
          {$this.Win32PathName } 
          elseIf ($this.ResolvedPSPath -ne $null) 
          {$this.ResolvedPSPath}          
          else 
          {$this.Name} 
        }

        #Un chemin tel que 'registry::hklm:\' est considéré comme candidate
        #on s'assure que sa construction est valide pour le provider   
       if ($Infos.ResolvedPSPath -ne $null)
       { 
         try {
              #La validation doit se faire à l'aide du provider ciblé
              #$pathHelper.isValid('t*') est différent si la localisation courante est sur le filesystem ou la registry
             Push-Location $env:windir
             $Infos.isPSValid=$pathHelper.isValid($Infos.ResolvedPSPath)
         } catch [System.Management.Automation.ProviderInvocationException]  {
             #Par exemple pour 'Registry::\\localhost\c$\temp' ou 'Registry::..\temp'
             Write-Debug  "isPSValid : $($_.Exception.GetType().Name)" #<%REMOVE%>
            $Infos.LastError=New-PSPathInfoError $_
         } finally {
             Pop-Location
           }
      }
      if ($Infos.IsaValidNameForTheFileSystem())
      { 
        #Pour 'C:\Temp\MyTest[a' si on utilise -Path, alors Win32PathName n'est pas renseigné
        #Pour 'C:\Temp\MyTest[a' si on utilise -LiteralPath, alors Win32PathName est renseigné
        #On reste cohérent dans la démarche.
        #Seul les drives existant sont concernés. 
        #Pour une exception DriveNotFound, Win32PathName n'est pas renseigné.
        #
        #Replace corrige un bug de PS
        $Infos.Win32PathName=$ursvPath -replace '^\\{2,}','\\' -replace '(?<!^)\\{2,}','\' 
      }
      
       #Ajoute des méthodes au champ contenant le nom de fichier recherché
      if($Infos.Win32PathName -ne $null)
      {
         $Infos.Win32PathName=$Infos.Win32PathName -as [PSobject]
         
         $Infos.Win32PathName|Add-Member -Membertype Scriptmethod -Name GetasFileInfo {
            New-object System.IO.FileInfo $this
         } -pass|
         Add-Member -Membertype Scriptmethod -Name GetFileNameTimeStamped {
          param ($Date=(Get-Date),$Format='dd-MM-yyyy-HH-mm-ss')
           $SF=$this.GetasFileInfo()
           "{0}\{1}-{2:$Format}{3}" -F $SF.Directory,$SF.BaseName,$Date,$SF.Extension
         }
      }
      Write-Output $Infos 
    }
 } #process
} #New-PSPathInfo
(Get-Item function:New-PSPathInfo).Description="Résout un nom de chemin et détermine s'il peut être utilisé sur le FileSystem"
new-alias npspa New-PSPathInfo -description "Fonction New-PSPathInfo" -force 

function Add-FileSystemValidationMember {
#Ajoute des méthodes de validation spécifique à un traitement
 param(
    [Parameter(Position=0, Mandatory=$true,ValueFromPipeline=$true)]
    [ValidateNotNullOrEmpty()]
    [ValidateScript({$_.PsObject.TypeNames[0] -eq "PSPathInfo"})]
  $PSPathInfo
 )
 
 process {
   #Le path est-il valide ? Concerne les fichiers et les répertoires avec ou sans jokers. 
    $PSPathInfo| 
      Add-Member -Membertype Scriptmethod -Name isaValidFileSystemPath {
         $result=($this.LastError -eq $null)  -and 
                 (($this.isFileSystemProvider -eq $true) -or ($this.isUNC -eq $true)) 
                   
        if (-not $result) { Write-Debug "Chemin invalide pour une utilisation sur le FileSystem : $($this.GetFileName())" } #<%REMOVE%>  
        $result                    
      }  -Passthru|
        #Le chemin d'un répertoire existe-t-il ?
      Add-Member -Membertype Scriptmethod -Name IsDirectoryExist{
          #Pour utiliser un répertoire on doit savoir s'il :
          #  est valide (ne pas contenir de joker,ni de caractères interdits),
          #  existe,
          #  pointe sur le file systeme (s'il est relatif, la location courante doit être le FS)
         $result= $false
         if ($this.isFileSystemItemFound())
         { 
           if ($this.asLiteral)
           { $lpath=[Management.Automation.WildcardPattern]::Escape($this.Win32PathName) }
           else 
           { $lpath=$this.Win32PathName }
           $result=$ExecutionContext.InvokeProvider.Item.IsContainer($lpath)
         }
          
         If (-not $result) { Write-Debug "Le répertoire n'existe pas : $($this.Win32PathName)" } #<%REMOVE%>
         $result     
      }  -Passthru|  
        #Le nom de chemin est-il un nom valide pouvant être crée sur le FileSystem ?
      Add-Member -Membertype Scriptmethod -Name IsCandidateForCreation {
          # Pour créer un répertoire on doit savoir s'il :
          #  est valide (ne pas contenir de joker, ni de caractères interdits),
          #  S'il n'existe pas déjà,
          #  pointe sur le file système (s'il est relatif, la location courante doit être le FS)
          #
          # $this.ResolvedPSPath est un nom d'entrée du FileSystem, pas un Fichier ou un Répertoire, 
          # c'est lors de la création de cette entrée que l'on détermine son type.
          #
          # AUCUN test d'accès en écriture n'est effectué. 
          #Par exemple les chemin pointant sur un CDROM sont considérés comme valide, 
          #ceux n'ayant pas la permision d'écriture également.
          #Mais dans ce cas isItemExist sera égal à $false
         $result= $this.IsaValidNameForTheFileSystem() -and ($this.isItemExist -eq $false)  
         
         If (-not $result) { Write-Debug "Path invalide pour une création de répertoire ou de fichier : $($this.Win32PathName)"} #<%REMOVE%> 
         $result
      } -Passthru | 
        #Le nom de chemin valide renvoie-t-il un et un seul élément ?
      Add-Member -Membertype Scriptmethod -Name isFileSystemItemFound {
         $result= $this.isaValidFileSystemPath() -and $this.isItemExist -and $this.isWildcard -eq $false
         if (-not $result) { Write-Debug "Le path pointe sur plusieurs éléments : $($this.GetFileName())" } #<%REMOVE%>
         $result 
      } -Passthru |
        #Le nom de chemin valide existant et comportant des jokers, renvoie-t-il au moins un fichier/répertoire ?
      Add-Member -Membertype Scriptmethod -Name isFileSystemItemContainsResolvedFiles {
         $result=$this.isaValidFileSystemPath() -and $this.isItemExist -and $this.isWildcard -and $this.ResolvedPSFiles.Count -gt 0
         if (-not $result) { Write-Debug "La résolution du chemin valide ne renvoi pas de fichiers/répertoire : $($this.GetFileName())" } #<%REMOVE%>
         $result          
      } -Passthru   
 }#process   
}#Add-FileSystemValidationMember


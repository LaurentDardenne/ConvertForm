
#PowerShell Form Converter

#todo : Ajout try /finally pour
# $ModalResult=$WinForm.ShowDialog()
# $WinForm.Dispose()
# Show-Window

Import-LocalizedData -BindingVariable ConvertFormMsgs -Filename ConvertFormLocalizedData.psd1 -EA Stop
 
 #On charge les méthodes de construction et d'analyse du fichier C#
Import-Module "$psScriptRoot\Transform.psm1" -DisableNameChecking -Verbose:$false

 #Analyse d'un pspath
."$psScriptRoot\Tools\New-PSPathInfo.ps1"

try {
  $OLDWP,$WarningPreference=$WarningPreference,'SilentlyContinue'
  Add-Type -TypeDefinition @'
  using System;
  
  namespace ConvertForm {
      [Serializable]
      public class OperationCanceledException : System.ApplicationException
      {
         public OperationCanceledException() : base()
         {
         }
         
         public OperationCanceledException(string message) : base(message)
         {
         }
         
         public OperationCanceledException(string message, Exception innerException)
         : base(message, innerException)
         {
         }
      }
  
      [Serializable]
      public class ComponentNotSupportedException : System.ApplicationException
      {
         public ComponentNotSupportedException() : base()
         {
         }
         
         public ComponentNotSupportedException(string message) : base(message)
         {
         }
         
         public ComponentNotSupportedException(string message, Exception innerException)
         : base(message, innerException)
         {
         }
      }
  
      [Serializable]
      public class CSParseException : System.ApplicationException
      {
         public CSParseException() : base()
         {
         }
         
         public CSParseException(string message) : base(message)
         {
         }
         
         public CSParseException(string message, Exception innerException)
         : base(message, innerException)
         {
         }
      }
  } 
'@
} Finally{
#bug ? https://connect.microsoft.com/PowerShell/feedbackdetail/view/917335
#-IgnoreWarnings do not work 
#-WV IgnoreWarnings do not work
 $WarningPreference=$OLDWP  
}

function Convert-Form {
# .ExternalHelp ConvertForm-Help.xml           
  [CmdletBinding(DefaultParameterSetName="Path")] 
  [OutputType([System.String])] 
 Param(
      #On attend un nom de fichier
     [ValidateNotNullOrEmpty()]
     [Parameter(Position=0,Mandatory=$True,ValueFromPipeline=$True, ParameterSetName="Path")]
   [string]$Path,
   
     [ValidateNotNullOrEmpty()]
     [Parameter(Position=0,Mandatory=$True,ValueFromPipeline=$True, ParameterSetName="LiteralPath")]
     [Alias('PSPath')]
   [string]$LiteralPath,
       
       #On attend un nom de répertoire
      [parameter(position=1,ValueFromPipelineByPropertyName=$True)]
    [PSObject] $Destination, #todo teste delayed SB    
    
      [parameter(position=1,ValueFromPipelineByPropertyName=$True)]
    [PSObject] $DestinationLiteral, #todo teste delayed SB     
    
     [Parameter(Position=2,Mandatory=$false)]
     [ValidateSet("unknown", "string", "unicode", "bigendianunicode", "utf8", "utf7", "utf32", "ascii", "default", "oem")]
    [string] $Encoding='default',
    
    [switch] $Force,
     
    [switch] $HideConsole,
    
    [switch] $asFunction,
    
    [switch] $Secondary,
    
    [switch] $Passthru
 )

 process {
  [Switch] $isVerbose= $null
  [void]$PSBoundParameters.TryGetValue('Verbose',[REF]$isVerbose)
  if ($isVerbose)
  { $VerbosePreference='Continue' } 
  
  $_EA= $null
  [void]$PSBoundParameters.TryGetValue('ErrorAction',[REF]$_EA)
  
  if ($_EA -eq $null)
  {
     #Récupère la valeur du contexte de l'appelant
    $ErrorActionPreference=$PSCmdlet.SessionState.PSVariable.Get('ErrorActionPreference').Value
  }
  else 
  { 
     #Priorité: On remplace sa valeur
    $ErrorActionPreference=$_EA
  }
  
  if ($Secondary -and $HideConsole)  
  { Throw (New-Object System.ArgumentException($ConvertFormMsgs.ParameterIsNotAllow)) }
 
  $isLiteral=$PsCmdlet.ParameterSetName -eq "LiteralPath"
  
  $isDestination=$PSBoundParameters.ContainsKey('Destination')
  $isDestinationLiteral=$PSBoundParameters.ContainsKey('DestinationLiteral')
  if ($isDestination -and $isDestinationLiteral)
  { Throw (New-Object System.ArgumentException($ConvertFormMsgs.ParameterIsExclusif)) }
  
  [boolean] $STA=$false

  $isDestinationBounded=$isDestination -or $isDestinationLiteral
  
  if ($isDestinationLiteral) 
  { $Destination=($DestinationLiteral -as [String]).Trim()}
  else
  { $Destination=($Destination -as [String]).Trim()}
   
  #Valide les prérequis concernant les fichiers
  if ($isLiteral)
  { $SourcePathInfo=New-PSPathInfo -LiteralPath ($LiteralPath.Trim())|Add-FileSystemValidationMember }
  else
  { $SourcePathInfo=New-PSPathInfo -Path ($Path.Trim())|Add-FileSystemValidationMember }
 
  $FileName=$SourcePathInfo.GetFileName()
  
   #Le PSPath doit exister, ne pas être un répertoire, ne pas contenir de globbing et être sur le FileSystem
   #On doit lire un fichier.
   #On précise la raison de l'erreur
  if (!$SourcePathInfo.isFileSystemItemFound()) 
  {
    if (!$SourcePathInfo.isDriveExist) 
    {Throw (New-Object System.ArgumentException(($ConvertFormMsgs.DriveNotFound  -F $FileName),'Source')) } 
  
       #C'est un chemin relatif, le drive courant appartient-il au provider FileSystem ? 
    if (!$SourcePathInfo.isAbsolute -and !$SourcePathInfo.isCurrentLocationFileSystem)
    {Throw (New-Object System.ArgumentException(($ConvertFormMsgs.FileSystemPathRequiredForCurrentLocation -F $FileName),'Source')) }
  
    if (!$SourcePathInfo.isFileSystemProvider)
    {Throw (New-Object System.ArgumentException(($ConvertFormMsgs.FileSystemPathRequired -F $FileName),'Source')) }
  
    if ($SourcePathInfo.isWildcard) 
    {Throw (New-Object System.ArgumentException(($ConvertFormMsgs.GlobbingUnsupported -F $FileName),'Source'))}
    else
    {Throw (New-Object System.ArgumentException(($ConvertFormMsgs.ItemNotFound -F $FileName),'Source')) } 
  }
  $SourceFI=$FileName.GetasFileInfo()
  if ($SourceFI.Attributes -eq 'Directory')
  { Throw (New-Object System.ArgumentException(($ConvertFormMsgs.ParameterMustBeAfile -F $FileName),'Source')) } 
  
   #Le cast de Destination renvoit-il une chaîne ayant au moins un caractère différent d'espace ? 
  if ($Destination -ne [String]::Empty)
  {
    if ($isDestinationLiteral) 
    { $DestinationPathInfo=New-PSPathInfo -LiteralPath $Destination|Add-FileSystemValidationMember }  
    else
    { $DestinationPathInfo=New-PSPathInfo -Path $Destination|Add-FileSystemValidationMember }
    
    $FileName=$DestinationPathInfo.GetFileName()

    #Le PSPath doit être valide, ne pas contenir de globbing (sauf si literalPath) et être sur le FileSystem
    #Le PSPath doit exister et pointer sur un répertoire :  { md C:\temp\test00 -Force}
    #On précise la raison de l'erreur
    if (!$DestinationPathInfo.IsaValidNameForTheFileSystem()) 
    {
      if (!$DestinationPathInfo.isDriveExist) 
      {Throw (New-Object System.ArgumentException(($ConvertFormMsgs.DriveNotFound  -F $FileName),'Destination')) }  
  
      if (!$DestinationPathInfo.isAbsolute -and !$DestinationPathInfo.isCurrentLocationFileSystem)
      {Throw (New-Object System.ArgumentException(($ConvertFormMsgs.FileSystemPathRequiredForCurrentLocation -F $FileName),'Destination')) }
      
      if (!$DestinationPathInfo.isFileSystemProvider)
      {Throw (New-Object System.ArgumentException(($ConvertFormMsgs.FileSystemPathRequired -F $FileName),'Destination')) }
      
      if ($DestinationPathInfo.isWildcard)
      {Throw (New-Object System.ArgumentException(($ConvertFormMsgs.GlobbingUnsupported -F $FileName),'Destination')) }
    }
    elseif (!$DestinationPathInfo.isItemExist)
    {Throw (New-Object System.ArgumentException(($ConvertFormMsgs.PathNotFound -F $FileName),'Destination')) }
    elseif (!$DestinationPathInfo.IsDirectoryExist($Filename))
    { Throw (New-Object System.ArgumentException(($ConvertFormMsgs.ParameterMustBeAdirectory -F $FileName),'Destination')) } 
    
    $ProjectPaths=New-FilesName $psScriptRoot $SourceFI $DestinationPathInfo -verbose:$isVerbose 
  }
  else 
  { 
     #$Destination n'est pas utilisable ou n'a pas été précisé ( $null -> String.Empty) 
    $ProjectPaths=New-FilesName $psScriptRoot $SourceFI
  }

  Write-Debug "Fin des contrôles."

  # Collection des lignes utiles de InitializeComponent() : $Components
  # Note:
  # Le code généré automatiquement par le concepteur Windows Form est inséré 
  # dans la méthode InitializeComponent. 
  # L'intégralité du code d'une méthode C# est délimité par { ... } 
  # On insére ces lignes de code et uniquement celles-ci dans le tableau $Component.
  # -----------------------------------------------------------------------------
  $Components = New-Object System.Collections.ArrayList(400)
  $ErrorProviders =New-Object System.Collections.ArrayList(5)
  [boolean] $isDebutCodeInit = $false
  [string] $FormName=[string]::Empty
  [boolean] $IsUsedPropertiesResources= $false  # On utilise le fichier de ressources des propriétés du projet
  
  Write-Verbose ($ConvertFormMsgs.BeginAnalyze -F $ProjectPaths.Source)

  if ($isLiteral)
  { $Lignes= Get-Content -Literalpath $ProjectPaths.Source -ErrorAction Stop }
  else
  { $Lignes= Get-Content -Path $ProjectPaths.Source -ErrorAction Stop }
  
  Write-Debug "Début de la première analyse"
  foreach ($Ligne in $Lignes)
  {
    if (! $isDebutCodeInit)
    {  # On démarre l'insertion à partir de cette ligne
       # On peut donc supposer que l'on parse un fichier créé par le designer VS
      if ($Ligne.contains('InitializeComponent()')) {$isDebutCodeInit= $true}
    }
    else 
    {  
      if ($Ligne.Trim() -eq [string]::Empty) {continue}
     
       # Fin de la méthode rencontrée ou ligne vide, on quitte l'itération. 
      if (($Ligne.trim() -eq "}") -or ($Ligne.trim() -eq [string]::Empty)) {break}
      
       # C'est une ligne de code, on l'insére 
      if ($Ligne.trim() -ne "{") 
      {    
          # On récupère le nom de la form dans $FormName
          # Note:  On recherche la ligne d'affectation du nom de la Form :  this.Name = "Form1";  
        if ($Ligne -match '^\s*this\.Name\s*=\s*"(?<nom>[^"]+)"\w*' ) 
        { 
           $FormName = $matches["nom"]
           Write-debug "Nom de la forme trouvé : '$FormName'"
        }
        [void]$Components.Add($Ligne)
        Write-Debug "`t`t$Ligne"
       #todo test sous PS v2 et v3
       if (-not $STA)
       {
          $STAReason=[string]::Empty 
          if ($Ligne.contains('System.Windows.Forms.WebBrowser') )
          { $STAReason='component WebBrowser' }
          if ($Ligne.contains('System.ComponentModel.BackgroundWorker') )
          { $STAReason='component BackgroundWorker' }
          if ( $Ligne -match "\s*this\.(.*)\.AllowDrop = true;$")
          { $STAReason='Drag and Drop' }
          if ( $Ligne -match "\s*this\.(.*)\.(AutoCompleteMode|AutoCompleteSource) = System.Windows.Forms.(AutoCompleteMode|AutoCompleteSource).(.*);$")
          { $STAReason='AutoCompleteMode' }
          if ( $STAReason -ne [string]::Empty)
          { 
            $STA=$true
            Write-Warning ($ConvertFormMsgs.AddSTARequirement -F $STAReason)
          }
       }                  
      }
     
     #La form nécessite-t-elle l'usage du fichier resx du projet ?
     if ( ($IsUsedPropertiesResources -eq $false) -and ($Ligne -Match '^(.*)= global::(.*?\.Properties.Resources\.)') )
     { 
       $IsUsedPropertiesResources=$true
       Write-debug "Nécessite le fichier resx du propriétés du projet"
     }
    }#else
  } #foreach

  Write-debug "Nom de la forme: '$FormName'"
  if (!$isDebutCodeInit)
  {  
    $PSCmdlet.WriteError(
    (New-Object System.Management.Automation.ErrorRecord (
         #Recrée l'exception trappée avec un message personnalisé 
	   (new-object ConvertForm.CSParseException( ($ConvertFormMsgs.InitializeComponentNotFound -F $ProjectPaths.Source ))),                         
       "AnalyzeWinformDesignerFileError", 
       "InvalidData",
       ("[{0}]" -f $ProjectPaths.Source)
       )  
    )
    )
    return  
  }
   
  if ($FormName -eq [string]::Empty) 
  {
     $WarningName=[string]::Empty
     if ($ProjectPaths.Source -notMatch "(.*)\.designer\.cs$")
     { $WarningName=$ConvertFormMsgs.DesignerNameNotFound }
    $PSCmdlet.WriteError(
     (New-Object System.Management.Automation.ErrorRecord (
         #Recrée l'exception trappée avec un message personnalisé 
	   (new-object ConvertForm.CSParseException(($ConvertFormMsgs.FormNameNotFound -F $ProjectPaths.Source,$WarningName))),                         
       "AnalyzeWinformDesignerFileError", 
       "InvalidData",
       ("[{0}]" -f $ProjectPaths.Source)
       )  
     )
    )
    return
  }
  
  Backup-Collection $Components "Récupération des lignes de code, de la méthode InitializeComponent, effectuée."
  # Collection de lignes constituant le nouveau script :  $LinesNewScript
  # Note:
  # Les déclarations des composants d'une Form se situent entre les lignes suivantes :
  #
  #   this.SuspendLayout();
  #   ...
  #   // Form 
  #
  # ----------------------------------------
  $LinesNewScript = New-Object System.Collections.ArrayList(600)
  [void]$LinesNewScript.Add( (Add-Header $ProjectPaths.Destination $($MyInvocation.Line) $ProjectPaths.Source ))
  
  If(-not $Secondary)
  {
    [void]$LinesNewScript.Add( (Add-GetScriptDirectory) )
  }
 
   # Le code STA et l'appel de l'API ne seront 
   # pas dans la fonction si -asFunction est précisé
  if ($STA)
  { 
     #Dans le cas d'usage de deux fenêtres, l'une ou l'autre peut utiliser 
     #des composants nécessitant le mode STA. 
     #L'utilisateur remaniera les scripts générés. 
    Write-Debug "[Ajout Code] Add-TestApartmentState"
    [void]$LinesNewScript.Add( (Add-TestApartmentState) ) 
  } 
    
  If ($HideConsole)
  { 
     #Dans le cas d'usage de deux fenêtres, la génération de l'une ou de l'autre ou des deux
     #peut utiliser le paramètre HideConsole. 
     #L'utilisateur remaniera les scripts générés.    
    Write-Debug "[Ajout Code] Win32FunctionsType"
    [void]$LinesNewScript.Add((Add-Win32FunctionsType))
    [void]$LinesNewScript.Add((Add-Win32FunctionsWrapper))
  }

  if( $Secondary)
  { $FunctionName='GenerateSecondaryForm' }
  else
  { $FunctionName='GeneratePrimaryForm' }
  
  if ( $asFunction )
  { 
    [void]$LinesNewScript.Add(@"
Function $FunctionName {
 param ( 
    [ValidateNotNullOrEmpty()]
    [Parameter(Position=0,Mandatory=`$true)]
  [string] `$ScriptPath
 )
"@)
  }

  
  [boolean] $IsTraiteMethodesForm = $False # Jusqu'à la rencontre de la chaîne " # Form1  "
  [boolean] $IsUsedResources= $false       # On utilise un fichier de ressources
  
  #-----------------------------------------------------------------------------
  #  Transforme les déclarations de propriétés sur plusieurs lignes 
  #  en une déclaration sur une seule lignes.   
  #----------------------------------------------------------------------------- 
  if (Test-Path Variable:Ofs)
  {$oldOfs,$Ofs=$Ofs,"`r`n" }
  else 
  { 
    $Ofs=[string]::Empty
    $oldOfs,$Ofs=$Ofs,"`r`n"
  }
  
   #Transforme une collection en une string
  $Temp="$Components"
   #Logiquement on utilise VS et Convert-Form pour le designer graphique et les event 
   #pas pour renseigner toutes les propriétés de type texte 
  $Temp=$Temp -replace "\s{2,}\| ","| "
  $Ofs=$oldOfs
  $Components = New-Object System.Collections.ArrayList($null)
   #Transforme une string en une collection
  $Components.AddRange($Temp.Split("`r`n"))
  Remove-Variable Temp
  
  
  Write-Debug "Début de la seconde analyse"
  for ($i=0; $i -le $Components.Count-1 ;$i++)
  {    
      #Contrôle la présence d'un composant de gestion de ressources (images graphique principalement)
     if ($IsUsedResources -eq $false)
     {
       $crMgr=[regex]::match($Components[$i],"\s= new System\.ComponentModel\.ComponentResourceManager\(typeof\((.*)\)\);$")
       if ($crMgr.success)
       {
         $IsUsedResources = $True
         Write-Debug "IsUsedResources : $IsUsedResources"
         continue
       }
     }
      # Recherche les noms des possibles ErrorProvider 
      #Ligne :  this.errorProvider2 = new System.Windows.Forms.ErrorProvider(this.components);
      #Write-Debug "Test ErrorProviders: $($Components[$i])"
     if ($Components[$i] -match ('^\s*this\.(.*) = new System.Windows.Forms.ErrorProvider\(this.components\);$'))
     { 
        [void]$ErrorProviders.Add($Matches[1])
        Write-Debug "Find ErrorProviders : $Matches[1]"
        continue
     }
    
    # -----------------------------------------------------------------------------------------------------------------
      #On supprime les lignes ressemblant à : 
         # // 
         # // errorProviderN
         # // 
         # this.errorProviderN.ContainerControl = this;
      # Elles seront recrées lors de la phase d'analyse des lignes restantes
      # A ce point on connait tous les ErrorProvider déclarés
       
       #on test si la ligne courante contient une affectation concernant un des Errorproviders trouvé précédement
      $ErrorProviders |`
        #Pour chaque éléments on construit la regex
      ForEach  {
         $StrMatch="^\s*this.$_.ContainerControl = this;$"
         if ($Components[$i] -match $StrMatch)
         {
           Write-Debug "Match Foreach ErrorProvider"
            #On efface le contenu de la ligne et les 3 précédentes
           -3..0|%{ $Components[$i+$_]=[string]::Empty}
         }#If
      }#ForEach
     # -----------------------------------------------------------------------------------------------------------------
      
      # Suppression des lignes contenant un appel aux méthodes suivantes : SuspendLayout, ResumeLayout et PerformLayout
      #  SuspendLayout() force Windows à ne pas redessiner la form. 
      #Ligne se terminant seulement par Layout(false); ou Layout(true); ou Layout();
      if ($Components[$i] -match ('Layout\((false|true)??\);$'))
      {$Components[$i]=[string]::Empty;continue}
  
        #Les lignes suivantes ne sont pas prise en compte 
        #   this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
        #   this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
      if ($Components[$i].Contains('AutoScale'))
      {$Components[$i]=[string]::Empty;Continue}
  
      # Aucun équivalent ne semble exister en Powershell pour ces commandes :
      # Pour les contrôles : DataGridView, NumericUpDown et PictureBox
      # Suppression des lignes de gestion du DataBinding. 
      if ($Components[$i].Contains('((System.ComponentModel.ISupportInitialize)(') )
      {$Components[$i]=[string]::Empty;Continue}
  }#for
  Backup-Collection $Components 'Modifications des déclarations multi-lignes effectuées.'
  #-----------------------------------------------------------------------------
  #  Fin de traitements des propriétés "multi-lignes"
  #----------------------------------------------------------------------------- 
  
  If(-not $Secondary)
  {
     Write-Debug "[Ajout Code] chargement des assemblies"
     $Assemblies=@('System.Windows.Forms','System.Drawing')
     
     [void]$LinesNewScript.Add($ConvertFormMsgs.LoadingAssemblies)
     Add-LoadAssembly $LinesNewScript $Assemblies
    #[void]$LinesNewScript.Add( (Add-GetScriptDirectory) )
  }

  if ($IsUsedPropertiesResources)
  { 
    try {
      Push-Location "$($ProjectPaths.SourcePath)\Resources"
      
      [void]$LinesNewScript.Add( (Add-ManagePropertiesResources "$($ProjectPaths.Sourcename)Properties"))
      $rsxSource = Join-Path $ProjectPaths.SourcePath 'Properties\Resources.resx'
      $rsxDestination = Join-Path $ProjectPaths.DestinationPath ($ProjectPaths.SourceName+'Properties.resources')
      New-ResourcesFile -Source $rsxSource -Destination $rsxDestination -isLiteral:$isLiteral -EA $ErrorActionPreference -verbose:$isVerbose
    } finally {
      Pop-Location
    }
  }

  if ($IsUsedResources)
  { 
    [void]$LinesNewScript.Add( (Add-ManageResources $ProjectPaths.Sourcename)) 
  	$rsxSource = Join-Path $ProjectPaths.SourcePath ($ProjectPaths.SourceName+'.resx')
    $rsxDestination = Join-Path $ProjectPaths.DestinationPath ($ProjectPaths.SourceName+'.resources')
    New-ResourcesFile -Source $rsxSource -Destination $rsxDestination -isLiteral:$isLiteral -EA $ErrorActionPreference -verbose:$isVerbose 
  }

  #On ajoute la création de la form avant tout autre composant
  #Le code de chaque composant référençant cet objet est assuré de son existence
  [void]$LinesNewScript.Add("`$$FormName = New-Object System.Windows.Forms.Form`r`n")
  
  Write-Debug "Début de la troisième analyse"
  $progress=0
  $setBrkPnt=$true
  $BPLigneRead,$BPLigneWrite=$null
  
   #Lance la modification du texte d'origine
  foreach ($Ligne in $Components)
  {
      Write-debug "---------Traite la ligne : $Ligne"
     if ($setBrkPnt -and ($DebugPreference -ne "SilentlyContinue"))
     {
       $BPLigneRead=Set-PSBreakpoint -Variable Ligne -Mode Read -Action { Write-Debug "[R]$Ligne"}
       $BPLigneWrite=Set-PSBreakpoint -Variable Ligne -Mode Write -Action { Write-Debug "[W]$Ligne"}
       $setBrkPnt=$false
     }
     $progress++                     
     Write-Progress -id 1 -activity ($ConvertFormMsgs.TransformationProgress -F $Components.Count) -status $ConvertFormMsgs.TransformationProgressStatus -percentComplete (($progress/$Components.count)*100)
       #On supprime les espaces en début et en fin de chaînes
       #Cela facilite la construction des expressions régulières
     $Ligne = $Ligne.trim()
     if ($Ligne -eq [string]::Empty) {Continue} #Ligne suivante
  
       # On ajoute la création d'un événement
       # Gestion d'un event d'un composant :  this.btnRunClose.Click += new System.EventHandler(this.btnRunClose_Click);
  
       # La ligne débute par "this" suivi d'un point puis du nom du composant puis du nom de l'event
       # this.TxtBoxSaisirNombre.Validating += new System.ComponentModel.CancelEventHandler(this.TxtBox1_Validating);
     if ($Ligne -match '^this\.?[^\.]+\.\w+ \+= new [A-Za-z0-9_\.]+EventHandler\(') 
     { 
         # On récupére le nom du composant et le nom de l'événement dans $T[1],$T[2]
        $T=$Ligne.Split(@('.','+'))
         #On ajoute le scriptblock gérant l'événement
        [void]$LinesNewScript.Add( (Add-EventComponent $T[1] $T[2].Trim()) )
        Continue
     }
        #Gestion d'un event de la form : this.Load += new System.EventHandler(this.Form1_Load);
     elseif ($Ligne -match '^this\.?\w+ \+= new [A-Za-z0-9_\.]+EventHandler\(') 
     {
        # On récupére le nom du composant et le nom de l'événement dans $T[1],$T[2]
       $T=$Ligne.Split(@('.','+'))
       $EventName=$T[1].Trim()
        #On génère par défaut ces deux événements
       if (($EventName -eq "FormClosing") -or ($EventName -eq "Shown")) {continue}
        #On ajoute le scriptblock gérant l'événement
       [void]$LinesNewScript.Add( (Add-EventComponent $FormName $EventName) )
       Continue
     }
        
  # ------------ Traitement des lignes. Toutes ne sont pas encore supportées, i.e. correctement analysées
  
       #Recherche l'affectation d'une valeur d'énumération par une capture
       # Trois groupe: 1- Les caractères à gauche de '= ', i.e. en début de ligne
       #				       2- Les caractères à droite de '= ' et avant le dernier '.'
       #				       3- Les caractères après le dernier '.'
       # Pour renforcer la reconnaissance on opére avant la suppression du ';' ( fin d'instruction C#)
  
       # On ne modifie pas les lignes du type :
       #       this.bindingNavigator1.AddNewItem = this.bindingNavigatorAddNewItem;
     $MatchTmp =[Regex]::Match($Ligne,"^(.*?) = (this|global::|\(\().*")   
     if ($MatchTmp.Success -eq $false)
     {$Ligne = $Ligne -replace "^(.*)= (.*)\.(\w+);$", '$1=[$2]::$3'}
  
      # Suppression du token C# de fin de ligne 
     $Ligne = $Ligne -replace '\s*;\s*$',''
     
      # Suppression du token d'appel de méthode. ATTENTION. Utile uniquement pour les constructeurs !
     $Ligne = $Ligne -replace "\(\)$",''
  
      # Les lignes commentées le restent et le traitement de la ligne courante se poursuit
     $Ligne = $Ligne -replace "^//",'#'
      
      # Remplacement des types boolean par les variables dédiées
      #Pour une affectation ou dans un appel de méthode 
     $Ligne = $Ligne -replace " true",' $true'
     $Ligne = $Ligne -replace " false",' $false'
      
      #Pour une affectation uniquement
     $Ligne = $Ligne -replace ' = null$',' = $null'

      #Pour une affectation uniquement
      $Ligne = $Ligne -replace ' = this$'," = `$$FormName"
  
      # Remplacement du format de typage des données
      #PB A quoi cela correspond-il ? si on remplace ici pb par la suite sur certaines lignes
      # A priori le traitement n'est pas complet et fausse les analyses suivantes.
      #$Ligne = $Ligne -replace "\((\w+\.\w+\.\w+\.\w+)\)", '[$1]' 
       
       # Remplacement, dans le cadre du remplissage d'objets avec des valeurs, de 
       # la chaîne "new XXXXXX[] {" 
     $Ligne = $Ligne -replace "new [A-Za-z0-9_\.]+\[\] \{",'@('
      # Tjs dans le cadre du remplissage de listbox, remplacement de "})" par "))"
     $Ligne = $Ligne -replace "}\)$",'))'
  
  #TODO : BUG dans la reconnaissance du pattern. Décomposer la ligne qui peut être complexe
  #				  Saisie : "Test : &é"''((--èè_çà)=+-*/.$¨^%,?;:§~#{'[(-|è`_\ç^à@)]=}"
  #				  C#     : "Test : &Ã©\"\'\'((--Ã¨Ã¨_Ã§Ã )=+-*/.$Â¨^%,?;:Â§~#{\'[(-|Ã¨`_\\Ã§^Ã @)]=}"});
  #				  PS     : "Test : &é\"\'\'((--èè_çà)=+-*/.$¨^%,?;:§~#{\'[(--borè`_\\ç^à@)]=}"))
  
       # si on trouve \'  entre 2 guillemets on le remplace par '
       # si on trouve \" entre 2 guillemets on le remplace par "
       # si on trouve \\ entre 2 guillemets on le remplace par \
       # si on trouve | entre 2 guillemets on ne le remplace pas
       # si on trouve || et qu'il n'est pas entre 2 guillemets on le remplace par -or (OR logique)
  
       # BUG : Remplacement de l'opérateur binaire OR
       #ATTENTION ne pas le modifier avant l'analyse des lignes de déclaration de fontes !!!
      #$ligne = $ligne.replace("|", '-bor')
  
       # Recherche dans les lignes commentées le nom de la form, 
       # le nombre d'espace entre # et Form1 importe peu mais il doit y en avoir au moins un.
      if ($Ligne -match "^#\s+" + $FormName) 
      {
         $IsTraiteMethodesForm = $True
          # On ajoute le constructeur de la Form
         [void]$LinesNewScript.Add("# $FormName")
          #On ajoute les possibles ErrorProvider
         if ($ErrorProviders.Count -gt 0)
         { 
            [string[]]$S=$ErrorProviders|% {Add-ErrorProvider $_ $FormName}
            [void]$LinesNewScript.Add("$S")
         } 
          # Il n'existe qu'une ligne de ce type
         Continue 
      }
      if ($IsTraiteMethodesForm)
      {   # On modifie les chaînes débutant par "this"
          # Ex : "this.Controls.Add(this.maskedTextBox1) devient "$Form1.Controls.Add(this.maskedTextBox1)" 
         $Ligne = $Ligne -replace "^this.(.*)", "`$$FormName.`$1"
          # Ensuite on remplace toutes les occurences de "this". 
          # Ex :"$Form.Controls.Add(this.button1)" devient "$Form1.Controls.Add($button1)"         
         if ($Ligne.Contains('this.'))  
         { $ligne = $Ligne.replace('this.', '$') }
      }
      else
      {   # On modifie les chaînes débutant par "this" qui opérent sur les composants
          # ,on remplace toutes les occurences de "this". 
          # Ex : "this.treeView1.TabIndex = 18" devient "$treeView1.TabIndex = 18" 
         if ($Ligne.StartsWith('this.')) 
         { $Ligne = $Ligne.replace('this.','$') }
      }
      #Recherche this en tant que premier paramètre d'une méthode
      #  $AddonFrm.toolTip1.SetToolTip(this, "Retrieve dependencies of a script")
      # transformé en :
      #  $toolTip1.SetToolTip($AddonFrm, "Retrieve dependencies of a script")
      $Ligne = $Ligne -replace '^(\$.*?)\.(.*?\.SetToolTip)\(this,(.*)$',"`$$`$2(`$$FormName,`$3"
        
        #Remplace le token d'appel d'un constructeur d'instance des composants graphiques. 
        # this.PanelMainFill = new System.Windows.Forms.Panel();
      $Ligne = $Ligne.replace(' new ', ' New-Object ')
       #Todo BUG
       #     this.tableLayoutPanelFill.ColumnStyles.Add(new System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType.Percent, 50F));
       #     this.tableLayoutPanelFill.RowStyles.Add(new System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType.Percent, 50F));
       # result :
       #     $tableLayoutPanelFill.ColumnStyles.Add(New-Object System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType.Percent, 50F))
       #
       #projet : ConvertForm\TestsWinform\Test5Panel\FrmTest5PanelTableLayoutPanel.Designer.cs

      $ligne = $Ligne.replace('(new ', '(New-Object ')
      
      $Ligne = $Ligne -replace "(^.*= New-Object System.Drawing.SizeF\()([0-9]+)F, ([0-9]+)F\)$", '$1$2, $3)'
       #Traite les ressources 
      If ($IsUsedResources)
      {   
         $Ligne = $Ligne -replace '^(.*?) = \(\((.*)\)\(resources.GetObject\("(.*)"\)\)\)$', '$1= [$2] $Resources["$3"]'
      }

      if ($IsUsedPropertiesResources -and ($Ligne -match '^(?<Object>.*) = global::(.*?\.Properties.Resources\.)(?<Key>.*)$'))
      { 
        # Transforme : this.pictureBox1.Image = global::TestFrm.Properties.Resources.Koala;
        #  en        : pictureBox1.Image = $PropertiesResources["Koala"]
        #
        # Koala est le nom d'une clé du fichier resx du projet : 
        # TestFrm.Properties est un espace de nom, .Resources est un nom de classe et Koala une propriété statique
        # les fichiers associée :
        #  Projet\Frm\Properties\Resources.Designer.cs
        #  Projet\Frm\Properties\Resources.resx
       $nl='{0}= $PropertiesResources["{1}"]' -F $Matches.Object,$Matches.Key
       [void]$LinesNewScript.Add($nl)
       continue
      }
  # Todo BUG
# ConvertForm\TestsWinform\Test14BoitesDeDialogue\FrmTest14BoitesDeDialogue.Designer.cs
#       #
#       $toolStripMenuItem2.DropDownItems.AddRange(@(
#       $toolStripMenuItem11))
#       $toolStripMenuItem2.Name = "toolStripMenuItem2"
#       resources.ApplyResources(this.toolStripMenuItem2, "toolStripMenuItem2")
#       $toolStripMenuItem4.Name = "toolStripMenuItem4"
#       resources.ApplyResources(this.toolStripMenuItem4, "toolStripMenuItem4")  
      
  #    resources.ApplyResources(this.rdbtnEnglish, "rdbtnEnglish");
  #    this.rdbtnFrench.AccessibleDescription = null;
  #    this.toolTipFr.SetToolTip(this.rdbtnEnglish, resources.GetString("rdbtnEnglish.ToolTip"));  
  #
  #result :
#     $rdbtnEnglish.AccessibleDescription = null
#     $rdbtnEnglish.AccessibleName = null
#     resources.ApplyResources(this.rdbtnEnglish, "rdbtnEnglish")
#     $rdbtnEnglish.BackgroundImage = null
#     $rdbtnEnglish.Font = null
#     $rdbtnEnglish.Name = "rdbtnEnglish"
#     $rdbtnEnglish.TabStop = $true
#     $toolTipFr.SetToolTip($rdbtnEnglish, resources.GetString("rdbtnEnglish.ToolTip"))  


  #
  #Projet: ConvertForm\TestsWinform\Test19Localisation\FrmMain.Designer.cs
  #
  # révision de la gestion des ressources
  #       Write-host $ligne
  #        $Ligne = $Ligne -replace "^(.*)= \(\((.*)\)\(resources.GetObject\((.*)\)\)\)$", '$1= [$2] $Resources[$3]'
  #        Write-host $ligne
  #          #$$$2 échappe le caractère dollar dans une regex
  #        $Ligne = $Ligne -replace "^(.*)\(this.(.*), resources.GetString\((.*)\)\)$", '$1($$$2, $Resources[$3])'
  #        Write-host $ligne
          
  
  # -------  Traite les propriétés .Font
      $MatchTmp =[Regex]::Match($Ligne,'^(.*)(\.Font =.*System.Drawing.Font\()(.*)\)$')   
      if ($MatchTmp.Success -eq $true)
      { 
          #On traite la partie paramètres d'une déclaration 
         $ParametresFont = Select-PropertyFONT $MatchTmp
         $ligne = ConvertTo-Line $MatchTmp (1,2) $ParametresFont
         [void]$LinesNewScript.Add($ligne+')')
         continue
      }
  
  # -------  Traite les propriétés .Anchor
     #la ligne suivante est traité précédement et ne match pas
     # this.button2.Anchor = System.Windows.Forms.AnchorStyles.None;
     #$button5.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Left)| System.Windows.Forms.AnchorStyles.Right)))
     $MatchTmp =[Regex]::Match($Ligne,'^(.*)(\.Anchor =.*System.Windows.Forms.AnchorStyles\))(.*)\)$')   
      if ($MatchTmp.Success -eq $true)
      { 
          #On traite la partie paramètres d'une déclaration 
         $ParametresAnchor = Select-PropertyANCHOR $MatchTmp
         $Ligne = ConvertTo-Line $MatchTmp (1) $ParametresAnchor
          #todo la function ConvertTo-Line est à revoir. Inadapté dans ce cas
          #$button1[System.Windows.Forms.AnchorStyles]"Top,Bottom,Left"
         $ligne = $ligne.replace('[System.','.Anchor = [System.')
         [void]$LinesNewScript.Add($Ligne)
         continue
      }
  
  # -------  Traite les propriétés .ShortcutKeys
     #this.toolStripMenuItem2.ShortcutKeys = ((System.Windows.Forms.Keys)((System.Windows.Forms.Keys.Alt | System.Windows.Forms.Keys.A)));
     $MatchTmp =[Regex]::Match($Ligne,'^(.*)(\.ShortcutKeys = \(\(System.Windows.Forms.Keys\))(.*)\)$')   
      if ($MatchTmp.Success -eq $true)
      { 
          #On traite la partie paramètres d'une déclaration 
         $ParametresShortcutKeys = Select-PropertyShortcutKeys $MatchTmp
         $Ligne = ConvertTo-Line $MatchTmp (1) $ParametresShortcutKeys
          #todo la function ConvertTo-Line est à revoir. Inadapté dans ce cas
          #$button1[System.Windows.Forms.AnchorStyles]"Top,Bottom,Left"
         $ligne = $ligne.replace('[System.','.ShortcutKeys = [System.')
         [void]$LinesNewScript.Add($Ligne)
         continue
      }
  
  # -------  Traite les appels de la méthode FormArgb
      $MatchTmp =[Regex]::Match($Ligne,'^(.*)( = System.Drawing.Color.FromArgb\()(.*)\)$') 
      if ($MatchTmp.Success -eq $true)
      { 
          #On traite la partie paramétres d'une déclaration 
         $ParametresRGB = Select-ParameterRGB $MatchTmp
         $Ligne = ConvertTo-Line $MatchTmp (1,2) $ParametresRGB
         $Ligne = $Ligne.Replace('System.Drawing.Color.FromArgb','[System.Drawing.Color]::FromArgb')
         [void]$LinesNewScript.Add($Ligne+')')
         continue
      }                                                                 
   # -------  Traite les appels de méthode statique
     #System.Parse("-00:00:01");
     #System.TimeSpan.Parse("-00:00:01");
     #System.T1.T2.T3.Parse("-00:00:01");
     #todo : regex en une passe 
     if ($Ligne -notmatch '^(.*) =\s*(\$|\()')
     { 
      # Write-Debug "Change méthode statique : $Ligne"
       $Ligne = $Ligne -replace '^(.*) =\s*(.[^\s]*)\.(.[^\.\s]*?)\(','$1 = [$2]::$3(' 
     } 
     
     Write-debug '---------------------'      
      [void]$LinesNewScript.Add($Ligne)
   } #foreach

  if ($DebugPreference -ne "SilentlyContinue")
  { $BPLigneRead,$BPLigneWrite | Remove-PSBreakpoint }
  Write-Debug "Conversion du code CSharp effectuée."
  
  [void]$LinesNewScript.Add( (Add-SpecialEventForm $FormName -HideConsole:$HideConsole))
   
  Write-Debug "[Ajout Code] Appel à la méthode ShowDialog/Dispose"
  [void]$LinesNewScript.Add("`$ModalResult=`$$FormName.ShowDialog()")

  If ($IsUsedResources)
  {  
    Write-Debug "[Ajout Code]Libération des ressources"
    [void]$LinesNewScript.Add($ConvertFormMsgs.DisposeResources)
    [void]$LinesNewScript.Add('$Reader.Close()') 
  }
  
  If ($IsUsedPropertiesResources)
  {  
    Write-Debug "[Ajout Code]Libération des ressources des propriétés du projet"
    [void]$LinesNewScript.Add('$PropertiesReader.Close()') 
  }

  [void]$LinesNewScript.Add($ConvertFormMsgs.DisposeForm)
  #Showdialog() need explicit Dispose()
  [void]$LinesNewScript.Add("`$$FormName.Dispose()")
  
  If ($HideConsole)
  {
     Write-Debug "[Ajout de code] Show-Window"
     [void]$LinesNewScript.Add('Show-Window')
  }
  
  if ( $asFunction )
  {  
    [void]$LinesNewScript.Add("}# ${FunctionName}`r`n")
    if (-not $Secondary)
    {
      [void]$LinesNewScript.Add("#Todo : When you use several addons, rename the '$FunctionName' function.") 
      [void]$LinesNewScript.Add('#Todo : Complete and uncomment the next line.')
      [void]$LinesNewScript.Add("#`$psISE.CurrentPowerShellTab.AddOnsMenu.Submenus.Add('Todo DisplayName', {$FunctionName},'ALT+F5')")
    }
  }
  
     # Ecriture du fichier de sortie
  try {
     if ((!$isDestinationBounded -and $isLiteral) -or $isDestinationLiteral)
     { $DestinationExist=Test-Path -LiteralPath $ProjectPaths.Destination }
     else
     { $DestinationExist=Test-Path -Path $ProjectPaths.Destination }
	 
      if (!$Force -and $DestinationExist)
      {  
        $Choice=Read-Choice ($ConvertFormMsgs.ReadChoiceCaption -F $ProjectPaths.Destination) $ConvertFormMsgs.ReadChoiceMessage
        if ($Choice -eq $ChoiceNO)
        { Write-Warning $ConvertFormMsgs.OperationCancelled; Return }
      }
  
      Write-Verbose ($ConvertFormMsgs.GenerateScript -F $ProjectPaths.Destination)
      if ((!$isDestinationBounded -and $isLiteral) -or $isDestinationLiteral)
      { Out-File -InputObject $LinesNewScript -LiteralPath $ProjectPaths.Destination -Encoding $Encoding -Width 999 }
      else
      { Out-File -InputObject $LinesNewScript -FilePath $ProjectPaths.Destination -Encoding $Encoding -Width 999 }
   } catch {
       #[System.UnauthorizedAccessException] #fichier protégé en écriture
       #[System.IO.IOException] #Espace insuffisant sur le disque.
      $PSCmdlet.WriteError(
        (New-Object System.Management.Automation.ErrorRecord (           
           $_.Exception,                         
           "CreateScriptError", 
           "WriteError",
           ("[{0}]" -f $ProjectPaths.Destination)
           )  
        )
      )  
      return  
   }

   Write-Verbose $ConvertFormMsgs.SyntaxVerification 
   $SyntaxErrors=@(Test-PSScript -Filepath $ProjectPaths.Destination -IncludeSummaryReport)
   if ($SyntaxErrors.Count -gt 0)
   { Write-Error -Message ($ConvertFormMsgs.SyntaxError -F $ProjectPaths.Destination) -Category "SyntaxError" -ErrorId "CreateScriptError" -TargetObject  $ProjectPaths.Destination }
     
   if ($Passthru)
   {
     Write-Debug "Emission de l'objet fichier : $($ProjectPaths.Destination)"
     Get-ChildItem -LiteralPath $ProjectPaths.Destination
   } 
   Write-Debug ("[{0}] Fin d'analyse du script." -F $MyInvocation.MyCommand)
   Write-Verbose ($ConvertFormMsgs.ConversionComplete -F $ProjectPaths.Source)
  }#process
} #Convert-Form


function Test-PSScript {  
# .ExternalHelp ConvertForm-Help.xml           
  [CmdletBinding()] 
    [OutputType([System.String])] 
   param(                                
      [Parameter(Mandatory=$true, Position=0, ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true)]  
      [ValidateNotNullOrEmpty()]  
      [Alias('PSPath','FullName')]  
      [System.String[]] $FilePath, 

      [Switch]$IncludeSummaryReport 
   ) 

   begin 
   { $total=$fails=$FileUnknown=0 }   

   process 
   { 
       $FilePath | 
        Foreach-Object { 
           if(Test-Path -LiteralPath $_ -PathType Leaf) 
           { 
              $Path = Convert-Path -LiteralPath $_  
  
              $Errors = $null 
              $Content = Get-Content -LiteralPath $Path  
              $Tokens = [System.Management.Automation.PsParser]::Tokenize($Content,[ref]$Errors) 
              if($Errors -ne $null) 
              { 
                 $fails++ 
                 $Errors | 
                  Foreach-Object {  
                    $CurrentError=$_
                    $CurrentError.Token | 
                     Add-Member -MemberType NoteProperty -Name Path -Value $Path -PassThru | 
                     Add-Member -MemberType NoteProperty -Name ErrorMessage -Value $CurrentError.Message -PassThru 
                 } 
              } 
             $total++
           }#if 
           else 
           { Write-Warning "File unknown :'$_'";$FileUnknown++ } 
       }#for 
   }#process  

   end  
   { 
      if($IncludeSummaryReport)  
      { 
         Write-Verbose "$total script(s) processed, $fails script(s) contain syntax errors,  $FileUnknown file(s) unknown." 
      } 
   } 
}#Test-PSScript

Function OnRemoveConvertForm {
  Remove-Module Transform
}#OnRemoveConvertForm
 
$MyInvocation.MyCommand.ScriptBlock.Module.OnRemove = { OnRemoveConvertForm }
Export-ModuleMember -Function Convert-Form,Test-PSScript 
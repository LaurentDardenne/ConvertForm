##########################################################################
#                               Add-Lib
#                      PowerShell Form Converter
#
# Version : 1.2.1
#
# Révision : $Rev: 180 $
#
# Date    : 1 août 2010
#
# Nom     : Convert-Form.ps1
#
# Usage   : Voir documentation : .\Convert-Form.ps1
#
# Objet   : Conversion d'un formulaire graphique C# (WinForm) créé à partir 
#           de Visual C# 2005/2008 (Express Edition ou supérieure) en un script PowerShell.
#
# D’après une idée originale de Jean-Louis, Robin Lemesle et Arnaud Petitjean.
# La version d’origine a été publiée sur le site PowerShell-Scripting.com.
##########################################################################


Param([string] $Source, 
      [string] $Destination, 
      [switch] $AddInitialize,
      [switch] $DontLoad,
      [switch] $DontShow, 
      [switch] $Force, 
      [switch] $HideConsole,
      [switch] $InvokeInRunspace,
      [switch] $PassThru, 
      [switch] $STA)

#-------------------- Contrôles divers ----------------------------------------------------------------------
Function Get-Usage {
@"
  NAME
    Convert-Form
    
  SYNOPSIS
    Converti un fichier xxx.Designer.cs en un script PowerShell.

  SYNTAX
    Convert-Form.ps1 -Source Form1.Designer.cs -Destination Form1.ps1 [-DontShow] [-DontLoad] [-Force]	

  DETAILED DESCRIPTION
    Ce script permet de convertir un fichier Csharp contenant les déclarations d'une WinForm en un script PowerShell. 
    La construction d'une fenêtre dans Visual Studio génère un fichier nommé NomDuFichier.Designer.cs.
    C'est ce fichier qui constitue la source de ce script, on en extrait les lignes de déclaration des composants insérés 
    sur la fenêtre de votre projet Winform. Si votre projet contient plusieurs Forms, vous devrez exécuter ce script 
    pour chacune d'entre elles.
    
    Si dans Visual Studio vous déclarez des événements spécifiques pour chaque composant, ce script construira une fonction
    pour chacun de ces événements. Le code Csharp contenu dans le corps de la méthode n'est pas converti.  
    
    L'usage de certains composants graphique nécessite le modèle de thread STA, celui-ci ne peut être modifié qu'à l'aide 
    du cmdlet Invoke-Apartment, disponible dans la distribution de ce script ou avec le projet PSCX 1.2 et supérieure.
    
    Il est possible d'exécuter une fenêtre au sein d'un runspace. Pour plus de détails consultez le tutoriel 
    "La notion de runspace sous PowerShell version 1" disponible le site http://laurent-dardenne.developpez.com/

  SYSTEM REQUIREMENTS
    Scripts :
            PackageConvert-Form.ps1
            PackageScripts.ps1
            APIWindows.ps1   (-HideConsole)
            New-Runspace.ps1 (-InvokeInRunspace)  
                PackageWinform.ps1 (optionnel)
    Programme 
            Resgen.exe (SDK .NET)
            PSInvokeApartment.dll (-STA) (cmdlet Invoke-Apartment nécessaire pour PowerShell  V1)
            Visual-Studio Express ou supèrieure (optionnel) 
    
  PARAMETERS
    -Source <String>
      Nom du fichier C# à convertir.
      Ne supporte pas le globbing (*, ?, [abc], etc)
	    Le chemin peut être relatif au drive courant.
	    
      Required?         True
      Position?         1
      Default value     <required>
      Accept pipeline?  False
      Accept wildcards? False

    -Destination <String>
      Nom du fichier généré. On crée un nouveau fichier contenant un script PowerShell.
      Ne supporte pas le globbing (*, ?, [abc], etc).
      Le chemin peut être relatif au drive courant. 
      Si ce paramètre n'est pas précisé on construit le nom du fichier généré de la façon suivante :
       ($Source.FullPathName)\($Source.FileName).ps1

      Required?         False
      Position?          2
      Default value     SourcePath\SourceNameWithoutExtension.ps1
      Accept pipeline?  False
      Accept wildcards? False
			
    -AddInitialize <switch>
      Insère l'appel préalable au script APIWindows.ps1 contenant les fonctions Hide-PSWindow et Show-PsWindow.     
      ATTENTION si vous ne précisez pas ce switch, mais précisez le switch -HideConsole, vous devrez au préalable 
      charger en dot source le fichier APIWindows.ps1
        . .\APIWindows.ps1; .\MaForm.ps1
      Le switch -HideConsole doit être également précisé pour activer cette insertion. 

      Required?         False
      Position?         named
      Default value     False
      Accept pipeline?  False
      Accept wildcards? False			

    -DontLoad <switch>
      Spécifie de ne pas insérer, dans le fichier généré, les appels aux assemblies Winform, etc.

      C'est par exemple le cas d'une fenêtre secondaire n'utilisant pas d'assemblies spécifique (cas le plus probable)
      Dans ce cas l’usage du paramètre –DontShow est recommandé car c’est vous qui déciderez quand afficher ces 
      fenêtres secondaires. Vous devrez donc modifier le script d'appel de la fenêtre principale afin qu’il prenne 
      en charge la création, l'affichage et la destruction des fenêtres secondaires.

      Required?         False
      Position?         named
      Default value     False
      Accept pipeline?  False
      Accept wildcards? False			

    -DontShow <switch>
      Indique de ne pas insérer à la fin du script PS1 généré l'appel à la méthode ShowDialog().
      Dans ce cas on n'insère pas d'appel à `$Form.Dispose(), ni à Show-PSWindow.
      cf. -HideConsole 

      Required?         False
      Position?         named
      Default value     False
      Accept pipeline?  False
      Accept wildcards? False			

    -Force <switch>
      Si le fichier Destination existe il est écrasé sans demande de confirmation. 
      
      Par défaut si vous répondez "Oui" à la question : 
       "Le fichier de destination existe déjà, voulez-vous le remplacer ?" 
      le fichier existant est écrasé.
      Si vous répondez "Non" le script s'arrête sur un avertissement, le fichier destination 
      n'est pas modifié.
      
      Dans tous les cas si le fichier est protégé en écriture ou verrouillé par un 
      autre programme l'opération échoue.

     Note: 
      Après avoir mis à jour votre projet Winform dans Visual Studio, ce qui est souvent le cas, car on ne crée pas 
      une interface graphique en une seule opération, et qu'en suite vous convertissez
      la nouvelle version du fichier Designer.cs, veillez à ne pas préciser ce switch.
      Ainsi vous n'écraserez pas le script existant que vous avez modifié ou alors précisez un nom de fichier différent.
      Pour reporter les modifications du nouveau script dans l'ancien script, l'outil Winmerge vous facilitera la tâche.  

      Required?         False
      Position?         named
      Default value     False
      Accept pipeline?  False
      Accept wildcards? False			

    -HideConsole <switch>
      Spécifie l'insertion des appels à Hide-PSWindow dans le code du gestionnaire d'événement `$Form1.Add_Shown,
      et l'appel à Show-PSWindow après l'appel à `$Form1.Dispose().
      Ainsi au démarrage de la form on cache la console et on la réaffiche une fois la forme close.

      Required?         False
      Position?         named
      Default value     False
      Accept pipeline?  False
      Accept wildcards? False			

    -InvokeInRunspace <switch>
      Indique l'insertion d'un code de création et d'initialisation d'un runspace, dans lequel on exécute l'appel à 
      ShowDialog de la form déclarée dans le fichier généré.  
      
      Exemple de code généré :
         $RSShowDialog=New-RunSpace {$Form1.ShowDialog()} $configurationRS
        
      Required?         False
      Position?         named
      Default value     False
      Accept pipeline?  False
      Accept wildcards? False
      
    -passThru <switch>
      Passe l'objet fichier récemment créé par ce script le long du pipeline. 
      Par défaut, ce script ne passe aucun objet le long du pipeline.      

      Required?         False
      Position?         named
      Default value     False
      Accept pipeline?  False
      Accept wildcards? False			
    
    -STA <switch>
      Autorise les composants nécessitant le modèle de thread STA.
      Dans ce cas on insère dans le script généré, un test de contrôle sur l'état de cloisonnement du thread courant.
      Beta (en cours de test).
      Nécessite sous PowerShell v1, la présence du cmdlet Invoke-Apartment.
      Nécessite sous PowerShell v2, d'exécuter PowerShell en précisant le switch -STA.

      Required?         False
      Position?         named
      Default value     False
      Accept pipeline?  False
      Accept wildcards? False			
  
  INPUT TYPE
   N/A
    	
  RETURN TYPE
    System.IO.FileInfo, SI le switch -passThru est précisé, sinon ne renvoi aucune donnée. 
	
  ERROR MESSAGE
   http://projets.developpez.com/wiki/add-lib/Convert-Form#Code-couleur-des-messages-derreur

  NOTES
  Site : http://projets.developpez.com/wiki/add-lib/Convert-Form 
    

    -------------------------- EXAMPLE 1 --------------------------
     #Précise des noms de chemin complet
    $PathOfForm ="$Home\Mes documents\Visual Studio 2008\Projects\MyForms\MyForms\Form1.Designer.cs"
    .\Convert-Form $PathOfForm C:\Temp\FrmTest.ps1 
    
    -------------------------- EXAMPLE 2 --------------------------
     #Lit le fichier source et écrit le fichier cible dans le répertoire courant.
     #Pas de demande confirmation si le fichier existe déjà
     #Le nom du fichier cible est égal à :
     # "$Home\Mes documents\Visual Studio 2008\Projects\MyForms\MyForms\Form1.ps1
    cd "$Home\Mes documents\Visual Studio 2008\Projects\MyForms\MyForms\ 
    .\Convert-Form Form1.Designer.cs -Force
    
    -------------------------- EXAMPLE 3 --------------------------
     #Converti la form en lui ajoutant le code cachant la fenêtre de la console 
     # durant le temps d'exécution de la fenêtre.
     #On ajoute également l'appel au script APiWindows.ps1. 
    .\Convert-Form Form1.Designer.cs FrmTest.ps1 -HideConsole -AddInitialize

    -------------------------- EXAMPLE 3 --------------------------
     #Autorise la conversion des composants utilisant le model de thread STA
    .\Convert-Form Form1.Designer.cs FrmTest.ps1 -STA

    -------------------------- EXAMPLE 4 --------------------------
     #Génére l'appel à ShowDialog au sein d'un runspace.
     #On émet le nom du fichier généré dans le pipeline afin de lui 
     #ajouter une signature Authenticode 
    .\Convert-Form Form1.Designer.cs FrmTest.ps1 -$InvokeInRunspace -Pass|Signe
    
    Afficher la documentaion page par page :
     .\Convert-From|More
"@
}

if ((!$Source) -and ($Destination))
{ Throw "Vous devez préciser un fichier source."}

if (!$Source)  
   { Get-Usage
     Write-Host "`r`n Codes couleur :"
     Write-Host "`tInformation : Message d'information."
     Write-Host -noNewLine "`tInformation : ";Write-Host "opération réussie." -f Green
     Write-Host -noNewLine "`tInformation : ";Write-Host "opération en échec" -f DarkYellow 
     Write-Host -noNewLine "`tErreur      : ";Write-Host "non-bloquante." -f Yellow 
     Write-Host -noNewLine "`tErreur      : ";Write-Host "grave." -f red 
     Return
   }   

#-------------------------------------------------------------------------------
 #Teste l'existence des scripts nécessaires, puis les charges

     #On charge les méthodes de vérification des prés-requis, 
     # du contrôle de la syntaxe et de la localisation.
if (!(Test-Path function:Test-RequiredItem)) 
 { 
   Throw "La fonction Test-RequiredItem n'existe pas." +
         "Chargez le script PackageScripts.ps1"
 }     

$ScriptPath = Get-ScriptDirectory

     #On charge les méthodes de construction et d'analyse du fichier C#
$PckConvertForm = Join-Path $ScriptPath PackageConvert-Form.ps1
Test-RequiredScripts $PckConvertForm 
 #Test-RequiredCommands aucune
 #Test-RequiredFunctions aucune
.{
  trap [System.Management.Automation.PSSecurityException]
   { Throw $($_.Exception.Message)}
  .$PckConvertForm
}

#-------------------------------------------------------------------------------
 #Load the localized datas for this script
 #Todo
#$ConverFormDatas=import-localizeddata "$ScriptPath\Convert-Form.ps1" #-UICulture:$LocalizedDataCulture


#-------------------------------------------------------------------------------
 #Source est renseigné, on vérifie sa validité  
if (($Source -eq $null) -or ($Source -eq [String]::Empty))
 {Throw "Le paramètre Source ne doit pas être Null ni être une chaîne vide."}
if ([Management.Automation.WildcardPattern]::ContainsWildcardCharacters($Source))
 {Throw "Le globbing n'est pas supporté pour le paramètre `$Source -> $Source"}
   #Le lecteur est-il renseigné ?
if ((Get-QualifierPath $Source)) 
 {   #Oui, mais existe-t-il ?
  if (!(Test-PSDrive $Source -Extract)) 
   {Throw "Le lecteur indiqué n'existe pas -> $Source."}  
 }
else
{  #C'est un chemin relatif
 if (!(split-path $Source -isabsolute))
      #On lit le fichier sur le lecteur courant
  {
    $Source=$ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($Source)
    Write-debug "Resolved Path : $Source"   
  }
}

if (!(Test-Path $Source))
 {Throw "Le fichier source n'existe pas -> $Source"} 

 #Destination est renseigné, on vérifie sa validité  
if ($Destination -ne [String]::Empty)
{
  if ([Management.Automation.WildcardPattern]::ContainsWildcardCharacters($Destination))
   {Throw "le globbing n'est pas supporté pour le paramètre `$Destination -> $Destination"}
  
  $Drv=Get-QualifierPath $Destination
  Write-Debug "Get-QualifierPath = $Drv"
    #Le lecteur est-il renseigné ?
  if ($Drv) 
  {  #Oui, mais Existe-t-il ?
    if (!(Test-PSDrive $Drv)) 
     {Throw "Le lecteur indiqué n'existe pas -> $Destination."}
     #Encore faut-il pouvoir y écrire un fichier ;-)
    if ((Get-PSDrive (($Drv).Replace(":",""))).Provider.Name -ne "FileSystem")
     {Throw "Le PSDrive ($Drv) de destination doit être un PSDrive du fournisseur FileSystem."} 
  }
   #C'est un chemin relatif
   #Le drive courant appartient-il au provider FS ? 
  if (!(Test-CurrentPSProvider "FileSystem"))
   { Throw "Exécutez ce script à partir d'un drive FileSystem ou référencez en un dans le nom du fichier Destination  -> $Destination."}
    #On écrira le fichier sur le lecteur courant
    #On récupère le nom complet du fichier à partir d'un chemin relatif  
    # g:..\test.ps1 ..\t.ps1 .\ts.ps1  ..\..\t.ps1
   $Destination=$ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($Destination)
   Write-debug "Resolved Path : $Destination"   
   $Ext=[System.IO.Path]::GetExtension($Destination)
   if ($Ext -eq [string]::Empty)
    {
      [System.IO.Path]::ChangeExtension($Destination,".ps1")
      Write-Host "L'extension .PS1 a été ajouté au nom du fichier Destination."
    }
   elseif ($Ext -ne ".ps1")
    {
      Write-Warning "Le nom du fichier cible doit être .PS1"
      #[System.IO.Path]::ChangeExtension($Destination,".ps1")
    }
} 
 #On construit les noms de fichier, notamment Destination s'il n'est pas renseigné. 
MakeFilesName

 #Affichage de debug
"Source","Destination","SourceName","SourcePath","DestinationName","DestinationPath"|
 Gv |
 % {Write-Debug ("{0}={1}" -F $_.Name,$_.Value)}

  #Teste s'il n'y a pas de conflit dans les switchs
  #Problème potentiel: la form principale masque la console, la fermeture de la seconde fenêtre réaffichera la console
 If ( ($HideConsole.ISPresent ) -and ($DontLoad.ISPresent) )
  {Write-Warning "Si vous convertissez une form secondaire l'usage du switch -HideConsole n'est pas nécessaire.`n`rSi c'est le cas, réexécutez votre appel sans préciser ce switch."} 
 
 if ($InvokeInRunspace -and $DontShow.IsPresent -eq $false)
   {Write-Warning "Conflit détecté, attention vous appelez deux fois ShowDialog()."} 
 
Write-Debug "Fin des contrôles."
function Finalyze
{
  Write-Debug "[Finalyze] Libération des listes"
  "LinesNewScript","Components","ErrorProviders"|
   Foreach {
    if (Test-Path Variable:$_) 
     {
      $Lst=GV $_
      $Lst.Value.Clear()
      $Lst.Value=$null
     } 
   }
  $ConverFormDatas=$null 
}
 
#-------------------- Fin des Contrôles --------------------------------------------------------------------

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

Write-Host "`r`nDémarrage de l'analyse du fichier $Source"
.{
  trap  [System.NotSupportedException]
  { 
    Write-Warning "Le composant suivant ou une de ces fonctionnalités, requiert le modèle de thread STA (Single Thread Apartment)).`r`nRéessayez avec le paramètre -STA."
    Finalyze
    Throw $_
  }
  trap 
  { 
    Finalyze
    Throw $_
  }
                                           #Tout ou partie du fichier peut être verrouillé
  foreach ($Ligne in Get-Content $Source -ErrorAction Stop)
    {
     if (! $isDebutCodeInit)
        {  # On démarre l'insertion à partir de cette ligne
           # On peut donc supposer que l'on parse un fichier créé par le designer VS
          if ($Ligne.contains("InitializeComponent()")) {$isDebutCodeInit= $true}
        }
     else 
        {  
         #todo le 19/08/2014 une ligne vide entre deux déclarations et/ou contenant des tabulation
         #arrête le traitement
# 			this.txt_name.TabIndex = 2;
# 
# 			this.txt_name.Validating += new System.ComponentModel.CancelEventHandler(this.Txt_nameValidating);         
         
         # Fin de la méthode rencontrée ou ligne vide, on quitte l'itération. 
          if (($Ligne.trim() -eq "}") -or ($Ligne.trim() -eq "")) {break}
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
            if (! $STA.IsPresent)
            { 
              if ( $Ligne.contains("System.Windows.Forms.WebBrowser") )
               {Throw  new-object System.NotSupportedException "Par défaut le composant WebBrowser ne peut fonctionner sous PowerShell V1.0."}
              if ( $Ligne.contains("System.ComponentModel.BackgroundWorker") )
               {Write-Warning "Par défaut les méthodes de thread du composant BackgroundWorker ne peuvent fonctionner sous PowerShell V1.0."}
              if ( $Ligne -match "\s*this\.(.*)\.AllowDrop = true;$")
               {Throw new-object System.NotSupportedException "Par défaut l'opération de drag and drop ne peut fonctionner sous PowerShell V1.0."}
              if ( $Ligne -match "\s*this\.(.*)\.(AutoCompleteMode|AutoCompleteSource) = System.Windows.Forms.(AutoCompleteMode|AutoCompleteSource).(.*);$")
               {Throw new-object System.NotSupportedException "Par défaut la fonctionnalité de saisie semi-automatique pour les contrôles ComboBox,TextBox et ToolStripTextBox doit être désactivée."}
           }#STA
          }
        }#else
    } #foreach
}

Write-debug "Nom de la forme: '$FormName'"
if (!$isDebutCodeInit)
  { Throw "La méthode InitializeComponent() est introuvable dans le fichier $Source.`n`rLa conversion ne peut s'effectuer."}
 
if ($FormName -eq "") 
{
   $BadName=""
   if ($Source -notMatch "(.*)\.designer\.cs$")
    {$BadName="Vérifiez que le nom du fichier est bien celui généré par le designer de Visual Studio : Form.Designer.cs."}
   Throw "Le nom de la form est introuvable dans la méthode InitializeComponent() du fichier $Source.`n`rLa conversion ne peut s'effectuer.`n`r$BadName"  
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
[void]$LinesNewScript.Add( (Create-Header $Destination $($MyInvocation.Line) ))

if ($STA.IsPresent)
  { 
   Write-Debug "[Ajout Code] Add-TestApartmentState"
   [void]$LinesNewScript.Add( (Add-TestApartmentState) ) 
  } 
  
If ( ($HideConsole.ISPresent ) -and ($AddInitialize.ISPresent) )
  { 
   Write-Debug "[Ajout Code] . .\APIWindows.ps1"
   [void]$LinesNewScript.Add(". .\APIWindows.ps1" )
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
 { #TestLib : set-psdebug -strict
  $Ofs=""
  $oldOfs,$Ofs=$Ofs,"`r`n"
 }

 #Transforme une collection en une string
$Temp="$Components"
 #Logiquement on utilise VS et Convert-Form pour le designer graphique et les event 
 #pas pour renseigner toutes les propriétés texte 
$Temp=$Temp -replace "\s{2,}\| ","| "
$Ofs=$oldOfs
$Components = New-Object System.Collections.ArrayList($null)
 #Transforme une string en une collection
$Components.AddRange($Temp.Split("`r`n"))
rv Temp


Write-Debug "Début de la seconde analyse"
for ($i=0; $i -le $Components.Count-1 ;$i++)
{    
    #Contrôle la présence d'un composant de gestion de ressources (images graphique principalement)
   if ($IsUsedResources -eq $false){
     $crMgr=[regex]::match($Components[$i],"\s= new System\.ComponentModel\.ComponentResourceManager\(typeof\((.*)\)\);$")
     if ($crMgr.success){
       Write-Debug "IsUsedResources : True"
       $IsUsedResources = $True
       $Components[$i]=AjouteGestionRessources
       continue
     }
   }
    # Recherche les noms des possibles ErrorProvider 
    #Ligne :  this.errorProvider2 = new System.Windows.Forms.ErrorProvider(this.components);
    #Write-Debug "Test ErrorProviders: $($Components[$i])"
   if ($Components[$i] -match ("^\s*this\.(.*) = new System.Windows.Forms.ErrorProvider\(this.components\);$"))
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
          -3..0|%{ $Components[$i+$_]=""}
        }#If
     }#ForEach
   # -----------------------------------------------------------------------------------------------------------------
    
    # Suppression des lignes contenant un appel aux méthodes suivantes : SuspendLayout, ResumeLayout et PerformLayout 
    #Ligne se terminant seulement par Layout(false); ou Layout(true); ou Layout();
   if ($Components[$i] -match ("Layout\((false|true)??\);$"))
     {$Components[$i]="";continue}
    
   if ($Components[$i].Contains("AutoScale"))
     {$Components[$i]="";Continue}

    # Aucun équivalent ne semble exister en Powershell pour ces commandes :
    # Pour les contrôles : DataGridView, NumericUpDown et PictureBox
    # Suppression des lignes de gestion du DataBinding. 
   if ($Components[$i].Contains("((System.ComponentModel.ISupportInitialize)(" ))
     {$Components[$i]="";Continue}
}#for
Backup-Collection $Components "Modifications des déclarations multi-lignes effectuées."
#-----------------------------------------------------------------------------
#  Fin de traitements des propriétés "multi-lignes"
#----------------------------------------------------------------------------- 

if ($IsUsedResources -eq $true)
 { CompileRessources }

If($DontLoad.ISPresent -eq $False)
 {
   Write-Debug "[Ajout Code] chargement des assemblies"
   $Assemblies=@("System.Windows.Forms","System.Drawing")
   if ($IsUsedResources)
    {$Assemblies +="System.Resources"}
     
	 [void]$LinesNewScript.Add("# Chargement des assemblies externes")
	 Create-LoadAssembly $LinesNewScript $Assemblies
 }

Write-Debug "Début de la troisième analyse"
$progress=0
 #Lance la modification du texte d'origine
foreach ($Ligne in $Components)
 {
    $progress++                     
    write-progress -id 1 -activity "Transformation du code source ($($Components.count) lignes)" -status "Patientez" -percentComplete (($progress/$Components.count)*100)
      #On supprime les espaces en début et en fin de chaînes
      #Cela facilite la construction des expressions régulières
    $Ligne = $Ligne.trim()
    if ($Ligne -eq "") {Continue} #Ligne suivante

     # On ajoute la création d'un événement
     # Gestion d'un event d'un composant :  this.btnRunClose.Click += new System.EventHandler(this.btnRunClose_Click);

      # La ligne débute par "this" suivi d'un point puis du nom du composant puis du nom de l'event
      # this.TxtBoxSaisirNombre.Validating += new System.ComponentModel.CancelEventHandler(this.TxtBox1_Validating);
    if ($Ligne -match "^this\.?[^\.]+\.\w+ \+= new [A-Za-z0-9_\.]+EventHandler\(") 
     { 
        # On récupére le nom du composant et le nom de l'événement dans $T[1],$T[2]
       $T=$Ligne.Split(@(".","+"))
        #On ajoute le scriptblock gérant l'événement
       [void]$LinesNewScript.Add( (Create-EventComponent $T[1] $T[2].Trim()) )
       Continue
     }
        #Gestion d'un event de la form : this.Load += new System.EventHandler(this.Form1_Load);
    elseif ($Ligne -match "^this\.?\w+ \+= new [A-Za-z0-9_\.]+EventHandler\(") 
      {
        # On récupére le nom du composant et le nom de l'événement dans $T[1],$T[2]
       $T=$Ligne.Split(@(".","+"))
       $EventName=$T[1].Trim()
        #On génère par défaut ces deux événements
       if (($EventName -eq "FormClosing") -or ($EventName -eq "Shown")) {continue}
        #On ajoute le scriptblock gérant l'événement
       [void]$LinesNewScript.Add( (Create-EventComponent $FormName $EventName) )
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
    $MatchTmp =[Regex]::Match($Ligne,"^.*= this.*")   
    if ($MatchTmp.Success -eq $false)
     {$Ligne = $Ligne -replace "^(.*)= (.*)\.(\w+);$", '$1=[$2]::$3'}

     # Suppression du token C# de fin de ligne 
    $Ligne = $Ligne -replace ";$",''

     # Suppression du token d'appel de méthode. ATTENTION. Utile uniquement pour les constructeurs !
    $Ligne = $Ligne -replace "\(\)$",''

     # Les lignes commentées le restent mais le traitement de la ligne courante se poursuit
    $Ligne = $Ligne -replace "^//",'#'
    
     # Remplacement des types boolean par les variables dédiées 
    $Ligne = $Ligne -replace " true",' $true'
    $Ligne = $Ligne -replace " false",' $false'

     # Remplacement du format de typage des données
     #PB A quoi cela correspond-il ? si on remplace ici pb par la suite sur certaine ligne
     # A prioris le traitement n'est pas complet et fausse les analyses suivantes.
    #$Ligne = $Ligne -replace "\((\w+\.\w+\.\w+\.\w+)\)", '[$1]' 
     
      # Remplacement, dans le cadre du remplissage d'objets avec des valeurs, de 
      # la chaîne "new XXXXXX[] {" 
    $Ligne = $Ligne -replace "new [A-Za-z0-9_\.]+\[\] \{",'@('
     # Tjs dans le cadre du remplissage de listbox, remplacement de "})" par "))"
     #if ($Ligne.EndsWith("})")) {$Ligne = $Ligne.replace("})", '))')}
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
        [void]$LinesNewScript.Add("`$$FormName = new-object System.Windows.Forms.form")
         #On ajoute les possibles ErrorProvider
         if ($ErrorProviders.Count -gt 0)
          { [void]$LinesNewScript.Add( ($ErrorProviders|% {Add-ErrorProvider $_ $FormName} ) ) }
         # Il n'existe qu'une ligne de ce type
        Continue 
       }
    if ($IsTraiteMethodesForm)
       {  # On modifie les chaînes débutant par "this"
          # Ex : "this.Controls.Add(this.maskedTextBox1) devient "$Form1.Controls.Add(this.maskedTextBox1)" 
         $Ligne = $Ligne -replace "^this.(.*)", "`$$FormName.`$1"
          # Ensuite on remplace toutes les occurences de "this". 
          # Ex :"$Form.Controls.Add(this.button1)" devient "$Form1.Controls.Add($button1)"         
         if ($Ligne.Contains("this."))  
          {$ligne = $Ligne.replace("this.", "$")}
       }
    else
       {  # On modifie les chaînes débutant par "this" qui opérent sur les composants
          # ,on remplace toutes les occurences de "this". 
          # Ex : "this.treeView1.TabIndex = 18" devient "$treeView1.TabIndex = 18" 
         if ($Ligne.StartsWith("this.")) 
           {$Ligne = $Ligne.replace("this.",'$')}
       }
      
      #Remplace le token d'appel d'un constructeur d'instance des composants graphiques. 
      # this.PanelMainFill = new System.Windows.Forms.Panel();
    $Ligne = $Ligne.replace(" new ", " new-object ")
     #Todo this.tableLayoutPanelFill.ColumnStyles.Add(new System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType.Percent, 50F));
    $ligne = $Ligne.replace("(new ", "(new-object ")
    
    $Ligne = $Ligne -replace "(^.*= new-object System.Drawing.SizeF\()([0-9]+)F, ([0-9]+)F\)$", '$1$2, $3)'
     #Traite les ressources 
    If ($IsUsedResources)
     {   
       $Ligne = $Ligne -replace "^(.*)= \(\((.*)\)\(resources.GetObject\(`"(.*)`"\)\)\)$", '$1= [$2] $Ressources["$3"]'
# todo
# révision de la gestion des ressources
#       Write-host $ligne
#        $Ligne = $Ligne -replace "^(.*)= \(\((.*)\)\(resources.GetObject\((.*)\)\)\)$", '$1= [$2] $Ressources[$3]'
#        Write-host $ligne
#          #$$$2 échappe le caractère dollar dans une regex
#        $Ligne = $Ligne -replace "^(.*)\(this.(.*), resources.GetString\((.*)\)\)$", '$1($$$2, $Ressources[$3])'
#        Write-host $ligne
        
     }
     
# -------  Traite les propriétés .Font
    $MatchTmp =[Regex]::Match($Ligne,'^(.*)(\.Font =.*System.Drawing.Font\()(.*)\)$')   
    if ($MatchTmp.Success -eq $true)
     { 
        #On traite la partie paramètres d'une déclaration 
       $ParametresFont = ParseProprieteFONT $MatchTmp
       $ligne = ReconstruitLigne $MatchTmp (1,2) $ParametresFont
       [void]$LinesNewScript.Add($ligne+")")
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
       $ParametresAnchor = ParseProprieteANCHOR $MatchTmp
       $Ligne = ReconstruitLigne $MatchTmp (1) $ParametresAnchor
        #todo la function ReconstruitLigne est à revoir. Inadapté dans ce cas
        #$button1[System.Windows.Forms.AnchorStyles]"Top,Bottom,Left"
       $ligne = $ligne.replace("[System.",".Anchor = [System.")
       [void]$LinesNewScript.Add($Ligne)
       continue
     }

# -------  Traite les propriétés .ShortcutKeys
   #this.toolStripMenuItem2.ShortcutKeys = ((System.Windows.Forms.Keys)((System.Windows.Forms.Keys.Alt | System.Windows.Forms.Keys.A)));
   $MatchTmp =[Regex]::Match($Ligne,'^(.*)(\.ShortcutKeys = \(\(System.Windows.Forms.Keys\))(.*)\)$')   
    if ($MatchTmp.Success -eq $true)
     { 
        #On traite la partie paramètres d'une déclaration 
       $ParametresShortcutKeys = ParseProprieteSHORTcutKeys $MatchTmp
       $Ligne = ReconstruitLigne $MatchTmp (1) $ParametresShortcutKeys
        #todo la function ReconstruitLigne est à revoir. Inadapté dans ce cas
        #$button1[System.Windows.Forms.AnchorStyles]"Top,Bottom,Left"
       $ligne = $ligne.replace("[System.",".ShortcutKeys = [System.")
       [void]$LinesNewScript.Add($Ligne)
       continue
     }

# -------  Traite les appels de la méthode FormArgb
    $MatchTmp =[Regex]::Match($Ligne,'^(.*)( = System.Drawing.Color.FromArgb\()(.*)\)$') 
    if ($MatchTmp.Success -eq $true)
      { 
         #On traite la partie paramétres d'une déclaration 
        $ParametresRGB = ParseParametres_rgb $MatchTmp
        $Ligne = ReconstruitLigne $MatchTmp (1,2) $ParametresRGB
        $Ligne = $Ligne.Replace("System.Drawing.Color.FromArgb","[System.Drawing.Color]::FromArgb")
        [void]$LinesNewScript.Add($Ligne+")")
        continue
      }
# ------- Fertig !     
    [void]$LinesNewScript.Add($Ligne)
 }  # foreach
Write-Debug "Conversion du code CSharp effectuée."

 [void]$LinesNewScript.Add( (Add-SpecialEventForm $FormName))
 If ($IsUsedResources)
  {  
    Write-Debug "[Ajout Code]Libération des ressources"
    [void]$LinesNewScript.Add(" #Libération des ressources")
    [void]$LinesNewScript.Add("`$Reader.Close()  #Appel Dispose") 
  }
 
 If( $dontShow.ISPresent -eq $false)
  { 
    Write-Debug "[Ajout Code] Appel à la méthode ShowDialog/Dispose"
    [void]$LinesNewScript.Add("`$ModalResult=`$$FormName.ShowDialog()") 
    [void]$LinesNewScript.Add(" #Libération de la Form")
    [void]$LinesNewScript.Add("`$$FormName.Dispose()")
 }
 If (!$dontShow.ISPresent -and $HideConsole.ISPresent )
  {
    Write-Debug "[Ajout Code] Show-PSWindow"
    [void]$LinesNewScript.Add("Show-PSWindow")
  }

 if ($InvokeInRunspace)
  { 
    Write-Debug "[Ajout Code] Invoke Form in Runspace"
    [void]$LinesNewScript.Add( (Add-InvokeFormInRunspace $Destination $FormName)) 
  }
 
   # Ecriture du fichier de sortie
 &{
    # On utilise un scriptblock pour bénéficier d'un trap local,
    # sinon le trap est global au script 
   trap [System.UnauthorizedAccessException] #fichier protégé en écriture
    { Finalyze; throw $_} 
   trap [System.IO.IOException] #Espace insuffisant sur le disque.
    { Finalyze; throw $_} 
   
   &{ 
     if ((!$Force) -and (Test-Path $Destination))
     {  
        #Affiche le détail du fichier concerné
      gci $Destination|Select LastWriteTime,mode,FullName|fl|out-host
      Write-Host "Le fichier de destination existe déjà, voulez-vous le remplacer ?`n`r$Destination"
      $Continuer =$True
      $Reponse = Read-Host "[O] Oui [N] Non"
      while ($Continuer) 
       {
        Switch ($Reponse)
        {
         "O" {$Continuer =$false}
         "N" {Write-Warning "Opération abandonnée."; Finalyze;exit}
         default {$Reponse = Read-Host "[O] Oui [N] Non"}
        }
       }
     }

     $LinesNewScript | Out-File -FilePath $Destination -Encoding Default
     Write-Host "Génération du script $Destination`r`n" -F Green
     Write-Host "-------- Début de la vérification de la syntaxe du script généré ----------" 
      $CheckResult=CheckSyntaxErrors $Destination -verbose
     Write-Host "-------- Fin de la vérification de la syntaxe du script généré ----------"
     if (!$CheckResult)
      {Write-Host "La syntaxe du script généré est invalide." -f DarkYellow }
   }
 }

  If ($dontShow.ISPresent -and $HideConsole.ISPresent )
  {
    Write-host "Pensez à appeler la méthode Show-PSWindow après `$$FormName.ShowDialog()."
  }
 
 Finalyze
 
 if ($passThru)
 {
   Write-Debug "Emission de l'objet fichier : $Destination"
   gci $Destination
 } 
 Write-Debug ("[{0}] Fin du script atteinte." -F $MyInvocation.MyCommand)

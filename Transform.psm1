# PowerShell ConvertForm 
# Transform module
# Objet   : Regroupe des fonctions de transformation de 
#           code CS en code PowerShell.

#todo la génération de code peut utiliser des string localisées.

 #Création du header
."$psScriptRoot\Tools\Add-Header.ps1"

function Convert-DictionnaryEntry($Parameters) 
{   #Converti un DictionnaryEntry en une string "clé=valeur clé=valeur..." 
  "$($Parameters.GetEnumerator()|% {"$($_.key)=$($_.value)"})"
}#Convert-DictionnaryEntry

function Backup-Collection($Collection,$Message)
{ #Sauvegarde dans un fichier temporaire unique le contenu de la collection de lignes en cours d'analyse
  if ( $DebugPreference -ne "SilentlyContinue") 
  { 
   if  ($Collection -is  [System.Collections.IEnumerable])
   {
     $TempFile = [IO.Path]::GetTempFileName()
     $Collection|Set-Content $TempFile
     Write-Debug $Message
     Write-Debug "Sauvegarde dans le fichier temporaire : $TempFile"
   } 
  else {Write-Warning "Backup-Collection : La variable `$Collection n'est pas une collection d'objet."} 
  }
}

Function Add-LoadAssembly{
 param (
  [System.Collections.ArrayList] $Liste,
  [String[]] $Assemblies
 )
 #Charge une liste d'assemblies .NET 
 #On les suppose présent dans le GAC
 #Add-Type -Path "FullPath\filename.dll" 
 foreach ($Assembly in $Assemblies)
 { [void]$Liste.Add("Add-Type -AssemblyName $Assembly") }
 [void]$Liste.Add("")
}

Function Add-EventComponent([String] $ComponentName, [String] $EventName)
{ #Crée et ajoute un événement d'un composant.
  #Par défaut le scriptbloc généré affiche un message d'information

  $UnderConstruction = "[void][System.Windows.Forms.MessageBox]::Show(`"L'évènement $ComponentName.Add_$EventName n'est pas implémenté.`")"
   #La syntaxe d'ajout d'un délégué est : Add_NomEvénément 
   # où le nom de l'événement est celui du SDK .NET
   #On construit le nom de la fonction appellée par le gestionnaire d'événement
  $OnEvent_Name="On{0}_{1}" -f ($EventName,$ComponentName)
  $Fonction ="function $OnEvent_Name {{`r`n`t{0}`r`n}}`r`n" -f ($UnderConstruction)
   #On double le caractère '{' afin de pouvoir l'afficher
  $EvtHdl= "`${0}.Add_{1}( {{ {2} }} )`r`n" -f ($ComponentName, $EventName, $OnEvent_Name)
# Here-string    
@"
$Fonction
$EvtHdl
"@
}

function Add-SpecialEventForm([String] $FormName)
{ # Ajoute des méthodes d'évènement spécifiques à la forme principale
  #FormClosing
    # Permet à l'utilisateur de : 
    #   -déterminer la cause de la fermeture
    #   -autoriser ou non la fermeture

 $Entête = "function OnFormClosing_{0}{{" -f ($FormName)
 $Close  = "`${0}.Add_FormClosing( {{ OnFormClosing_{0}}} )" -f ($FormName)

  #FormShown
 $CallHidefnct=""
 If ($HideConsole)
   #On affiche la fenêtre mais on cache la console 
  {$CallHidefnct="Hide-PSWindow;"}
   #Replace au premier plan la fenêtre en l'activant.
   # Form1.topmost=$true est inopérant
 $Shown  = "`${0}.Add_Shown({{{1}`${0}.Activate()}})" -f ($FormName,$CallHidefnct)

# Here-string  
@"
$Entête 
`t# `$this est égal au paramètre sender (object)
`t# `$_ est égal au paramètre  e (eventarg)

`t# Déterminer la raison de la fermeture :
`t#   if ((`$_).CloseReason -eq [System.Windows.Forms.CloseReason]::UserClosing)

`t#Autorise la fermeture
`t(`$_).Cancel= `$False
}
$Close
$Shown
"@
}

function Add-ManageRessources{
 #Ajoute le code gérant un fichier de ressources et ce à l'aide d'une "here-string"
  # 1 fonction
  # 2 test d'existence du fichier
  # 3 récupération dans une hastable des ressources de la Winform

# Here-string   
 param (
  [string] $SourceName
 )
 
@"

function Get-ScriptDirectory
{  #Renvoi le nom du répertoire d'un script parent, celui appelé sur la ligne de commande.
   # By J.Snover
  `$Invocation = (Get-Variable MyInvocation -Scope 1).Value
  Split-Path `$Invocation.MyCommand.Path
}

`$ScriptPath = Get-ScriptDirectory
`$RessourcesPath= Join-Path `$ScriptPath "$SourceName.resources"
if ( !(Test-Path `$RessourcesPath))
 {
  Write-Warning "Le fichier de ressources n'existe pas :``n``r `$RessourcesPath"
  break; # Sinon le script est en exception qq lignes plus tard
 }

  #Gestion du fichier des ressources
`$Reader = new-Object System.Resources.ResourceReader("`$RessourcesPath")
`$Ressources=@{}
`$Reader.GetEnumerator()|% {`$Ressources.(`$_.Name)=`$_.value}
 
 # Création des composants
"@         
}#Add-ManageRessources

function Convert-Enum([String] $Enumeration)
{ #Converti une valeur d'énumération
  # un.deux.trois en [un.deux]::trois
 $Enumeration = $Enumeration.trim()
  # recherche (et capture) en fin de chaîne un mot précédé d'un point lui-même précédé de n'importe quel caractères
 $Enumeration -replace "(.*)\.(\w+)$", '[$1]::$2'
}

function Select-ParameterEnumeration([String]$NomEnumeration, [String] $Parametres)
{ #Voir le fichier  "..\Documentations\Analyse des propriétés.txt"
 #Gére les propriétés Font et Anchor

  $Valeurs= $Parametres.Split("|")
  $NbValeur = $Valeurs.Count
   
   #Une seule valeur, on la convertie
  if ($NbValeur -eq 1 )
  { return Convert-Enum $Parametres} 

   #Valeur 1 :
   #         ((Nom.Enumeration)((Nom.Enumeration.VALEUR
    # recherche (et capture) en fin de chaîne un mot précédé d'un point lui-même précédé de n'importe quel caractères
  $Valeurs[0]= ($Valeurs[0] -replace "^.*\.(.*)$", '$1').Trim()
 
   #Valeur 2..n :
   #     Nom.Enumeration.VALEUR)    
   # recherche (et capture) en fin de chaîne une parenthèse précédée de caractères uniquement précédés d'un point lui-même précédé de n'importe quel caractères
  for ($i=1;$i -le $NbValeur-2;$i++)
  { $Valeurs[$i]= ($Valeurs[$i] -replace "^.*\.([a-zA-Z]*)\)$", '$1').Trim() }

   #Dernière valeur  :
   #         Nom.Enumeration.VALEUR))  
   # ou      Nom.Enumeration.VALEUR)))  
   # recherche (et capture) en fin de chaîne deux parenthèses précédées de caractères ou de chiffre uniquement précédés d'un point lui-même précédé de n'importe quel caractères
  $Valeurs[$NbValeur-1]= ($Valeurs[$NbValeur-1] -replace "^.*\.([a-zA-Z0-9]+)\)+$", '$1').Trim()
  return "[$NomEnumeration]`"{0}`"" -F ([string]::join(",", $Valeurs))
}

function Select-PropertyFONT([System.Text.RegularExpressions.Match] $MatchStr)
{ #Analyse une déclaration d'une propriété Font
   #Pour la chaîne:  $label1.Font = New-Object System.Drawing.Font("Arial Black", 9.75F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)))
	# $MatchStr contient 4 groupes :
	#  0- la ligne compléte
	#  1- $label1
	#  2- .Font = New-Object System.Drawing.Font(
	#  3- "Arial Black", 9.75F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0))

    #Récupère les paramètres du constructeur
  $Parametres= [Regex]::Split($MatchStr.Groups[3].value,",")
    #Le premier est tjr le nom de la fonte de caractère
    #Le second est tjr la taille de la fonte de caractère dans ce cas on supprime le caractère 'F' 
    #indiquant un type double
  $Parametres[1]=$Parametres[1] -replace "F",''
  
   #Teste les différentes signatures de constructeurs
   #On parcourt toute la liste du nombre de paramètre possibles, les uns à la suite des autres.
  Switch ($Parametres.count)
  { 
    {$_ -eq 3} {  #Est-ce un paramètre de type System.Drawing.GraphicsUnit ?
                 if ( $Parametres[2].Contains("System.Drawing.GraphicsUnit") )
         		 {$Parametres[2]=Convert-Enum $Parametres[2]}
         		   #si non c'est donc un paramètre de type System.Drawing.FontStyle ?
       			 else { $Parametres[2]=Select-ParameterEnumeration "System.Drawing.FontStyle" $Parametres[2] }
     		   }

    {$_ -ge 4} {  #Le troisième est tjr de type FontStyle
   	   			  #Le quatrième est tjr de type GraphicsUnit
                 $Parametres[2]= Select-ParameterEnumeration "System.Drawing.FontStyle" $Parametres[2]
                 $Parametres[3]=Convert-Enum $Parametres[3]
               }
                 
    {$_ -ge 5} {  #On récupére uniquement la valeur du paramètre : ((byte)(123))
                  # Un ou plusieurs chiffres :                        [0-9]+
                 $Parametres[4]=$Parametres[4] -replace "\(\(byte\)\(([0-9]+)\)\)", '$1' 
               }

    #6 Le sixième (true - false) est traité par la suite dans le script principal

                  #Pb :/
    {$_ -ge 7} { throw ("Cas imprévu : {0}" -f ($MatchStr.Groups[3].value)) }
  }
  
  return $Parametres
}
function Select-PropertyANCHOR([System.Text.RegularExpressions.Match] $MatchStr)
{ #Analyse une déclaration d'une propriété Anchor
   #Pour la chaîne: $comboBox1.Anchor = ((System.Windows.Forms.AnchorStyles)((((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom)| System.Windows.Forms.AnchorStyles.Left)| System.Windows.Forms.AnchorStyles.Right)));

	# $MatchStr contient 4 groupes :
	#  0- la ligne compléte
	#  1- $comboBox1
	#  2- .Anchor = ((System.Windows.Forms.AnchorStyles)
	#  3- (((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom)| System.Windows.Forms.AnchorStyles.Left)| System.Windows.Forms.AnchorStyles.Right));

 #Peut être codé dans l'appelant mais cela documente un peu plus
 return Select-ParameterEnumeration "System.Windows.Forms.AnchorStyles" $MatchStr.Groups[3].value
}

function Select-PropertyShortcutKeys([System.Text.RegularExpressions.Match] $MatchStr)
{ #Analyse une déclaration d'une propriété ShortcutKeys
   #Pour la chaîne: this.toolStripMenuItem2.ShortcutKeys = ((System.Windows.Forms.Keys)((System.Windows.Forms.Keys.Alt | System.Windows.Forms.Keys.A)));

	# $MatchStr contient 4 groupes :
	#  0- la ligne compléte
	#  1- $comboBox1
	#  2- .ShortcutKeys = ((System.Windows.Forms.Keys)
	#  3- ((System.Windows.Forms.Keys.Alt | System.Windows.Forms.Keys.A)));

 #Peut être codé dans l'appelant mais cela documente un peu plus
 return Select-ParameterEnumeration "System.Windows.Forms.Keys" $MatchStr.Groups[3].value
}

function Select-ParameterRGB([System.Text.RegularExpressions.Match] $MatchStr)
{ #Analyse les paramétres d'un appel de la méthode FromArgb
   #Pour la chaîne:  $CaseàCocher.FlatAppearance.MouseDownBackColor = System.Drawing.Color.FromArgb(((int)(((byte)(192)))), ((int)(((byte)(255)))), ((int)(((byte)(192)))))
	# $MatchStr contient 4 groupes :
	#  0- la ligne compléte
	#  1- $CaseàCocher.FlatAppearance.MouseDownBackColor
	#  2-  = System.Drawing.Color.FromArgb(
	#  3- ((int)(((byte)(192)))), ((int)(((byte)(255)))), ((int)(((byte)(192))))
	 
    #Récupère les 3 paramètres
  $Parametres= [Regex]::Split($MatchStr.Groups[3].value,",")
  for ($i=0; $i -lt $Parametres.count; $i++)
	  # On récupére uniquement la valeur du paramètre : ((int)(((byte)(192))))
	  #Recherche ( et capture) en début de chaine une suite de caractère suivis d'une parenthèse suivi de 
	  #un ou plusieurs chiffres suivis par une ou plusieurs parenthèses
  { $Parametres[$i]=$Parametres[$i]  -replace "^(.*)\(([0-9]+)\)+", '$2' }
   
  return $Parametres
}

function ConvertTo-StringBuilder([System.Text.RegularExpressions.Match] $MatchStr, [Array] $NumerosOrdonnes)
 {  #On reconstruit le début d'une chaîne à partir d'une expression parsée
   # $NumerosOrdonnes : Contient les numéros des groupes à insérer dans la nouvelle chaîne
   $Result=new-object System.Text.StringBuilder
   foreach ($Num in $NumerosOrdonnes)
   { [void]$Result.Append($MatchStr.Groups[$Num].value) }
   return $Result
 }
 
function ConvertTo-Line([System.Text.RegularExpressions.Match] $MatchStr, [Array] $NumerosOrdonnes,[string[]] $Parametres )
{ #Utilisé pour reconstruire une proprieté.

   #On reconstruit l'intégralité d'un chaîne parsée et transformée
  $Sb=ConvertTo-StringBuilder $MatchStr $NumerosOrdonnes
  [void]$Sb.Append( [string]::join(",", $Parametres)) 
  return $Sb.ToString()
}

function New-FilesName{
  #Construit les paths et noms de fichier à partir de $Source et $Destination
 param(
   [string] $ScriptPath,
    
   [System.IO.FileInfo]$SourceFI,
   
    #PSPathInfo ou string
   $Destination
 )

  #Le fichier de ressource posséde une autre construction que le nom du fichier source
  #On garde le nom de la Form car on peut avoir + fichiers .Designer.cs
   # en entrée                 : -Source C:\VS\Projet\PS\Form1.Designer.cs -Destination C:\Temp\Destination.ps1
   # fichier ressource associé : C:\VS\Projet\PS\Form1.resx        
   # fichier ressource généré  : C:\Temp\Form1.ressources
   # fichier de log généré     : C:\Temp\Destination.Log
  $ProjectPaths=@{
     Source=$SourceFI.FullName
     SourcePath = $SourceFI.DirectoryName
     SourceName = ([System.IO.Path]::GetFilenameWithoutExtension($SourceFI.FullName)) -replace ".designer",''
  }
 
  if ($Destination -eq [String]::Empty)
  { 
      #Construit le nom à partir du nom de fichier source
     $ProjectPaths.Destination="$($ProjectPaths.SourcePath)\$($ProjectPaths.SourceName).ps1"
  }
  else 
  { 
      #Récupère le nom analysé
     $ProjectPaths.Destination=$Destination.GetFileName()
     if ([System.IO.Path]::GetExtension($ProjectPaths.Destination) -eq [string]::Empty)
     {
        $ProjectPaths.Destination=[System.IO.Path]::ChangeExtension($ProjectPaths.Destination,".ps1")
        Write-Verbose "L'extension .ps1 a été ajouté au nom du fichier Destination."
     }
  }

  $DestinationFI=New-object System.IO.FileInfo $ProjectPaths.Destination
  $ProjectPaths.DestinationPath = $DestinationFI.DirectoryName
  $ProjectPaths.DestinationName = ([System.IO.Path]::GetFilenameWithoutExtension($DestinationFi.FullName))

  Write-Debug 'BuildFiles ProjectPaths :' ; Convert-DictionnaryEntry $ProjectPaths|Foreach {Write-Debug $_}
  Write-Verbose "Le fichier source : $($ProjectPaths.Source)"
  Write-Verbose "Le fichier destination  : $($ProjectPaths.Destination)"
  
  $ProjectPaths 
} #New-FilesName

function New-RessourcesFile{ 
#Compile le fichier contenant les ressources d'un formulaire, ex : Form1.resx
 param (
  $ProjectPaths
 ) 
  
  write-Debug "Compile les ressources"
   #On génére le fichier de ressources
   #todo + versions de resgen ?
   #todo error ou warning ?
  $Resgen="$psScriptRoot\ResGen.exe" 
  if ( !(Test-Path $Resgen))
  { write-host "Le programme générant les ressources est introuvable : $Resgen" -F DarkYellow }
  else
  {
	 $SrcResx = Join-Path $ProjectPaths.SourcePath ($ProjectPaths.SourceName+".resx")
	 if ( !(Test-Path $SrcResx))
	 { Write-Host "Le fichier de ressources est introuvable : $SrcResx" -F DarkYellow }
	 else
	 {
	   $DestResx = Join-Path $ProjectPaths.DestinationPath ($ProjectPaths.SourceName+".resources")
	   $Log=Join-Path $ProjectPaths.DestinationPath ("$($ProjectPaths.DestinationName).log")
	   if ((Test-Path $Log))
	   { 
	      trap  
          {Write-Warning "Suppression du fichier impossible : $Log"; Continue}
	      Remove-Item $Log 
	   }
	     #Message de debug
       "Resgen","SrcResx","DestResx","Log"|Gv |% {Write-Debug ("{0}={1}" -F $_.Name,$_.Value)}
	 
	    #Redirige le handle d'erreur vers le handle standard de sortie
	   $ResultExec=.$Resgen $SrcResx $DestResx 2>&1
	   $ResultExec|Out-File -width 999 $Log
	   if ($LastExitCode -ne 0)
	   { Write-Warning "Erreur($LastExitCode) lors de la génération du fichier de ressources . Consultez le fichier $log" }
	   else 
       { Write-Verbose "Génération du fichier de ressources $DestResx`r`n" }
	 }
  } 
}

function Add-ErrorProvider([String] $ComponentName, [String] $FormName)
{ #Ajoute le texte suivant après la ligne de création de la form,
  #le component ErrorProvider référence la Form contenant les composants qu'il doit gérer
   
  #  #
  #  # errorProviderX
     #
  #  $errorProviderX.ContainerControl = $Form1

# Here-string  
@"
`#
`# $ComponentName
`#
$("`${0}.ContainerControl = `${1}" -F $ComponentName,$FormName)  
"@
} #Add-ErrorProvider

function Add-TestApartmentState {
  #Le switch -STA est détecté,, on ajoute un test sur le modèle du thread courant.
@"

 #Utiliser le paramètre -STA.
if ([System.Threading.Thread]::CurrentThread.GetApartmentState() -ne [System.Threading.ApartmentState]::STA )
{Throw "Le script courant nécessite que le modèle du thread actuel soit [System.Threading.ApartmentState]::STA (Single Thread Apartment)." }

"@
} #Add-TestApartmentState

function Clear-KeyboardBuffer {
 while ($Host.UI.RawUI.KeyAvailable) 
 { $null=$Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown, IncludeKeyUp")}
}

function Read-Choice{
  param(
      $Caption, 
      $Message,
        [ValidateSet("Yes","No")]
      $DefaultChoice="No"
  )
  
  Clear-KeyboardBuffer
  $Yes = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes"
  $No = New-Object System.Management.Automation.Host.ChoiceDescription "&No"
  $Choices = [System.Management.Automation.Host.ChoiceDescription[]]($Yes,$No)
  $Host.UI.PromptForChoice($Caption,$Message,$Choices,([byte]($DefaultChoice -eq "no")))
}

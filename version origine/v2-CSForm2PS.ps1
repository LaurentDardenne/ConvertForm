##########################################################################
#                    www.PowerShell-Scripting.com
#
#                      PowerShell Form Converter
#
# Version : 0.2
#
# Nom     : CSForm2PS.ps1
#
# Usage   : CSForm2PS.ps1 -source <Form1.Designer.cs> -dest <Form1.ps1>
#
# Objet   : Conversion d'un formulaire graphique C# (form) créé à partir 
#           de Visual C# 2005 Express Edition en PowerShell
#
# 
# Date    : Avril 2007
#
# D’après une idée originale de Jean-Louis, Robin Lemesle et Arnaud Petitjean.
# La version d’origine a été publiée sur le site PowerShell-Scripting.com.
##########################################################################

param ([string]$source, [string]$dest)


# Programme source CSharp à analyser
$csFilename = $source
#
# fichier destination PowerShell
$psFileName = $dest
#
# Collection des lignes utiles de InitializeComponent() : $component
# ------------------------------------------------------------------
[string[]] $component = @()
[boolean] $debut = $false
foreach ($ligne in (get-content $csFileName))
{
 if (! $debut)
	{ if ($ligne.contains("InitializeComponent()")) {$debut = $true}
	}
 else 
	{ if (($ligne.trim() -eq "}") -or ($ligne.trim() -eq "")) {break}
	  if ($ligne.trim() -ne "{") {$component += $ligne}
	}
}
# On récupère le nom de la form dans $formName
# --------------------------------------------
$formName = ""
foreach ($ligne in $component)
{ if ($ligne -match '^\s*this\.Name\s*=\s*"(?<nom>[^"]+)"\w*' ) 
	{$formName = $matches["nom"]; break}
}
if ($formName -eq "") { write-output "Nom de la form non trouvé"; exit}

# Collection des lignes résultat :  $resul
# ----------------------------------------
[string[]] $resul = @()
$resul += '[void][Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")'
[boolean] $debut = $true	# jusqu'à la rencontre de // Form
foreach ($ligne in $component)
{
	$ligne = $ligne.trim()
	$util = $true		# Cette ligne est-elle utile ?
	if ($ligne.Contains("Layout")) {$util = $false}
	if ($ligne.Contains("AutoScale")) {$util = $false}
	if ($ligne -eq "") {$util = $false}
	if ($util)
		{
		 if ($ligne.EndsWith(";"))     {$ligne = $ligne.SubString(0, $ligne.Length-1) }
		 if ($ligne.EndsWith("()"))    {$ligne = $ligne.SubString(0, $ligne.Length-2) }
		 if ($ligne.StartsWith("//"))  {$ligne = "#" + $ligne.SubString(2)}
		 if ($ligne.Contains(" new ")) {$ligne = $ligne.replace(" new ", " new-object ")}
		 #if ($ligne.Contains("\r"))    {$ligne = $ligne.replace("\r",'`r')}
		 #if ($ligne.Contains("\n"))    {$ligne = $ligne.replace("\n",'`n')}
		 if ($ligne -match "^this\.(?<nom>[^\.]+)\.Clic\w+") {$ligne = '$' + $matches["nom"] + ".Add_Click({})"}
		 if ($ligne.Contains(" true")) {$ligne = $ligne.replace(" true", ' $true')}
		 if ($ligne.Contains(" false")) {$ligne = $ligne.replace(" false", ' $false')}

  		 # Remplacement de "new object[] {" dans le cadre du remplissage de listbox avec des valeurs
		 if ($ligne.Contains("new object[] {")) {$ligne = $ligne.replace("new object[] {", '@(')}
		 # Tjs dans le cadre du remplissage de listbox, remplacement de "})" par "))"
		 if ($ligne.EndsWith("})")) {$ligne = $ligne.replace("})", '))')}

		 $TestForm = "^#\s+" + $formName
		 if ($ligne -match $TestForm) 
			{
			 $debut = $false
			 $resul += '$' + "$formName = new-object System.Windows.Forms.form"
			}
		 if ($debut)
			{
			 if ($ligne.StartsWith("this.")) {$ligne = $ligne.replace("this.",'$')}
			}
		 else
			{
			 if ($ligne.StartsWith("this.")) {$ligne = "$" + $formName + $ligne.SubString(4)}
			 if ($ligne.Contains("this."))   {$ligne = $ligne.replace("this.", "$")}
			}
		 $resul += $ligne
		
		}	# if ($util)
}	# foreach
$resul += "$" + $formname + ".ShowDialog()"

# Ecriture du fichier de sortie
# -----------------------------
$resul | out-file -filepath $psFileName -encoding default
#

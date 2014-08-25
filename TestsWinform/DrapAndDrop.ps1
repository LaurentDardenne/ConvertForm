################################################################################ 
#
#  Nom     : G:\PS\PSDrapAndDrop\PSDrapAndDrop\DrapAndDrop.ps1
#  Version : 0.1
#  Auteur  :
#  Date    : le 23/09/2008
@"
Historique :
(Soit substitution CVS)
$Log$
(soit substitution SVN)
$LastChangedDate$
$Rev$
"@>$Null 
#
################################################################################

# Chargement des assemblies externes
[void][Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
[void][Reflection.Assembly]::LoadWithPartialName("System.Drawing")

$splitContainer1 = new-object System.Windows.Forms.SplitContainer
$lstBxGauche = new-object System.Windows.Forms.ListBox
$lstBxDroite = new-object System.Windows.Forms.ListBox
#
# splitContainer1
#
$splitContainer1.Dock =[System.Windows.Forms.DockStyle]::Fill
$splitContainer1.Location = new-object System.Drawing.Point(0, 0)
$splitContainer1.Name = "splitContainer1"
#
# splitContainer1.Panel1
#
$splitContainer1.Panel1.Controls.Add($lstBxGauche)
#
# splitContainer1.Panel2
#
$splitContainer1.Panel2.Controls.Add($lstBxDroite)
$splitContainer1.Size = new-object System.Drawing.Size(904, 266)
$splitContainer1.SplitterDistance = 447
$splitContainer1.TabIndex = 0
#
# lstBxGauche
#
$lstBxGauche.AllowDrop = $True #Si $False OK
$lstBxGauche.Dock =[System.Windows.Forms.DockStyle]::Fill
$lstBxGauche.FormattingEnabled = $true
$lstBxGauche.Location = new-object System.Drawing.Point(0, 0)
$lstBxGauche.Name = "lstBxGauche"
$lstBxGauche.Size = new-object System.Drawing.Size(447, 264)
$lstBxGauche.TabIndex = 0
function OnDragOver_lstBxGauche($Sender,$e){
   #Autorise seulement les données de type : fichier 
 if (e.Data.GetDataPresent([DataFormats]::FileDrop) -eq $false)
   {$e.Effect = [DragDropEffects]::None}
 $e.Effect = [DragDropEffects]::Copy
}

$lstBxGauche.Add_DragOver( { OnDragOver_lstBxGauche $lstBxGauche $EventArgs} )
function OnDragDrop_lstBxGauche($Sender,$e){
  #Si c'est la source est un fichier on autorise le relaché sur le composant
 if (! $e.Data.GetDataPresent([DataFormats]::FileDrop))
  { $e.Effect = [DragDropEffects]::None }
 else 
  { $e.Effect = [DragDropEffects]::Copy}	
}

$lstBxGauche.Add_DragDrop( { OnDragDrop_lstBxGauche $lstBxGauche $EventArgs} )
function OnDragEnter_lstBxGauche($Sender,$e){
 #On récupère les données de type fichier uniquement
 if ($e.Data.GetDataPresent([DataFormats]::FileDrop))
  {
       #Un ou plusieurs fichiers
      string[] $Fichiers = (string[])$e.Data.GetData([DataFormats]::FileDrop);

       #Effectue l'opération de drag-and-drop, 
       #ici l'opération est une copie du nom de fichier.
      if ($e.Effect == [DragDropEffects]::Copy)
      {
              $lstBxGauche.Items.Clear();
              foreach ($NomDeFichier in $Fichiers)
              {
                  $lstBxGauche.Items.Add($NomDeFichier);
                  $lstBxDroite.Items.Add($NomDeFichier);
              }
              $lstBxDroite.Items.Add("-------- {0} fichiers ajoutés --------" -F $Fichiers.Length);
      }
  }	
}

$lstBxGauche.Add_DragEnter( { OnDragEnter_lstBxGauche $lstBxGauche $EventArgs} )
#
# lstBxDroite
#
$lstBxDroite.Dock =[System.Windows.Forms.DockStyle]::Fill
$lstBxDroite.FormattingEnabled = $true
$lstBxDroite.Location = new-object System.Drawing.Point(0, 0)
$lstBxDroite.Name = "lstBxDroite"
$lstBxDroite.Size = new-object System.Drawing.Size(453, 264)
$lstBxDroite.TabIndex = 0
#
$FrmMain = new-object System.Windows.Forms.form
#
$FrmMain.ClientSize = new-object System.Drawing.Size(904, 266)
$FrmMain.Controls.Add($splitContainer1)
$FrmMain.Name = "FrmMain"
$FrmMain.Text = "PowerShell - Drag and Drop"
function OnFormClosing_FrmMain($Sender,$e){ 
	# $this est égal au paramètre sender (object)
	# $_ est égal au paramètre  e (eventarg)

	# Déterminer la raison de la fermeture :
	#   if (($_).CloseReason -eq [System.Windows.Forms.CloseReason]::UserClosing)

	#Autorise la fermeture
	($_).Cancel= $False
}
$FrmMain.Add_FormClosing( { OnFormClosing_FrmMain $FrmMain $EventArgs} )
$FrmMain.Add_Shown({$FrmMain.Activate()})
 #Déclenche une exception si un composant déclare AllowDrop=$true
$FrmMain.ShowDialog()
 #Libération des ressources
$FrmMain.Dispose()


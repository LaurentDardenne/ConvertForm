################################################################################ 
#
#  Name    : G:\PS\ConvertForm\Demo\DemoTreeView\DemoTreeView\FrmTreeDemo.ps1 ((fichier FrmTreeDemo.ps1 d'origine)  
#  Version : 0.1
#  Author  :
#  Date    : 12/02/2015
#
#  Generated with PowerShell V4.0
#  Invocation Line   : Convert-Form -path G:\PS\ConvertForm\Demo\DemoTreeView\DemoTreeView\FrmTreeDemo.Designer.cs
#  Source            : G:\PS\ConvertForm\Demo\DemoTreeView\DemoTreeView\FrmTreeDemo.Designer.cs
################################################################################

function Get-ScriptDirectory
{ #Return the directory name of this script
  $Invocation = (Get-Variable MyInvocation -Scope 1).Value
  Split-Path $Invocation.MyCommand.Path
}

$ScriptPath = Get-ScriptDirectory

# Chargement des assemblies externes
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing


$ResourcesPath= Join-Path $ScriptPath "FrmTreeDemo.resources"
if ( !(Test-Path $ResourcesPath))
{
  Write-Error "Le fichier de ressources n'existe pas : $ResourcesPath"
  break; 
}
  #Gestion du fichier des ressources
$Reader = new-Object System.Resources.ResourceReader($ResourcesPath)
$Resources=@{}
$Reader.GetEnumerator()|% {$Resources.($_.Name)=$_.value}
 
 # Création des composants
$FrmTreeView = New-Object System.Windows.Forms.Form

$components = New-Object System.ComponentModel.Container
System.ComponentModel.ComponentResourceManager resources = New-Object System.ComponentModel.ComponentResourceManager(typeof(FrmTreeView))
$pnlFill = New-Object System.Windows.Forms.Panel
$treeDirectories = New-Object System.Windows.Forms.TreeView
$pnlBottom = New-Object System.Windows.Forms.Panel
$btnClose = New-Object System.Windows.Forms.Button
$imgLstExplorer = New-Object System.Windows.Forms.ImageList($components)
#
# pnlFill
#
$pnlFill.Controls.Add($treeDirectories)
$pnlFill.Dock =[System.Windows.Forms.DockStyle]::Fill
$pnlFill.Location = New-Object System.Drawing.Point(0, 0)
$pnlFill.Name = "pnlFill"
$pnlFill.Size = New-Object System.Drawing.Size(498, 421)
$pnlFill.TabIndex = 0
#
# treeDirectories
#
$treeDirectories.CheckBoxes = $true
$treeDirectories.Dock =[System.Windows.Forms.DockStyle]::Fill
$treeDirectories.ImageIndex = 0
$treeDirectories.ImageList = $imgLstExplorer
$treeDirectories.Location = New-Object System.Drawing.Point(0, 0)
$treeDirectories.Name = "treeDirectories"
$treeDirectories.SelectedImageIndex = 0
$treeDirectories.Size = New-Object System.Drawing.Size(498, 421)
$treeDirectories.TabIndex = 0

function OnNodeMouseClick_treeDirectories {
	[void][System.Windows.Forms.MessageBox]::Show("L'évènement $ComponentName.Add_$EventName n'est pas implémenté.")
}

$treeDirectories.Add_NodeMouseClick( { OnNodeMouseClick_treeDirectories } )


function OnNodeMouseDoubleClick_treeDirectories {
	[void][System.Windows.Forms.MessageBox]::Show("L'évènement $ComponentName.Add_$EventName n'est pas implémenté.")
}

$treeDirectories.Add_NodeMouseDoubleClick( { OnNodeMouseDoubleClick_treeDirectories } )

#
# pnlBottom
#
$pnlBottom.Controls.Add($btnClose)
$pnlBottom.Dock =[System.Windows.Forms.DockStyle]::Bottom
$pnlBottom.Location = New-Object System.Drawing.Point(0, 382)
$pnlBottom.Name = "pnlBottom"
$pnlBottom.Size = New-Object System.Drawing.Size(498, 39)
$pnlBottom.TabIndex = 1
#
# btnClose
#
$btnClose.Location = New-Object System.Drawing.Point(392, 4)
$btnClose.Name = "btnClose"
$btnClose.Size = New-Object System.Drawing.Size(75, 23)
$btnClose.TabIndex = 0
$btnClose.Text = "Close"
$btnClose.UseVisualStyleBackColor = $true

function OnClick_btnClose {
	[void][System.Windows.Forms.MessageBox]::Show("L'évènement $ComponentName.Add_$EventName n'est pas implémenté.")
}

$btnClose.Add_Click( { OnClick_btnClose } )

#
# imgLstExplorer
#
$imgLstExplorer.ImageStream= [System.Windows.Forms.ImageListStreamer] $Resources["imgLstExplorer.ImageStream"]
$imgLstExplorer.TransparentColor =[System.Drawing.Color]::Transparent
$imgLstExplorer.Images.SetKeyName(0, "File.ico")
$imgLstExplorer.Images.SetKeyName(1, "Directory.ico")
#
# FrmTreeView
#
$FrmTreeView.ClientSize = New-Object System.Drawing.Size(498, 421)
$FrmTreeView.Controls.Add($pnlBottom)
$FrmTreeView.Controls.Add($pnlFill)
$FrmTreeView.Name = "FrmTreeView"
$FrmTreeView.StartPosition =[System.Windows.Forms.FormStartPosition]::CenterScreen
$FrmTreeView.Text = "Demo Treeview"

function OnFormClosing_FrmTreeView{ 
	# $this parameter is equal to the sender (object)
	# $_ is equal to the parameter e (eventarg)

	# The CloseReason property indicates a reason for the closure :
	#   if (($_).CloseReason -eq [System.Windows.Forms.CloseReason]::UserClosing)

	#Sets the value indicating that the event should be canceled.
	($_).Cancel= $False
}

$FrmTreeView.Add_FormClosing( { OnFormClosing_FrmTreeView} )

$FrmTreeView.Add_Shown({$FrmTreeView.Activate()})
$ModalResult=$FrmTreeView.ShowDialog()
# Libération des ressources
$Reader.Close()
# Libération de la Form
$FrmTreeView.Dispose()

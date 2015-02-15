################################################################################ 
#
#  Name    : FrmTreeDemo2.ps1  (fichier FrmTreeDemo.ps1 modifié) 
#  Version : 0.1
#  Author  :
#  Date    : 12/02/2015
#
#  Generated with PowerShell V4.0
#  Source            : Demo\DemoTreeView\DemoTreeView\FrmTreeDemo.Designer.cs
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


$ResourcesPath= Join-Path $ScriptPath "FrmTreeDemo2.resources"
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
    $CurrentNode=$_.Node
    Write-Debug "OnClick_treeVwDirectories. Current $($CurrentNode.Text)"
    #$CurrentNode|Write-Properties
    If ($CurrentNode.Nodes.Count -eq 0) #Todo refresh
    {
      Write-Debug "Read current node : $($CurrentNode.FullPath) "
      if ($CurrentNode.Tag.IsDirectory)
      {
         #-LiteralPath : gestion des wildcard PS 'Nom[1]'
         #Join-Path : gestion du backslash
         Get-ChildItem -LiteralPath (Join-Path $CurrentNode.FullPath '')| 
         Foreach {
          Write-Debug "Add $_"
          $newFile=New-NodeFile -Path $_
          [void]$CurrentNode.Nodes.Add($newFile)
         }
         $CurrentNode.Expand()
      }
    }
}

$treeDirectories.Add_NodeMouseClick( { OnNodeMouseClick_treeDirectories } )

# function OnNodeMouseDoubleClick_treeDirectories {
# 	[void][System.Windows.Forms.MessageBox]::Show("L'évènement treeDirectories.Add_NodeMouseDoubleClick n'est pas implémenté.")
# }
# 
# $treeDirectories.Add_NodeMouseDoubleClick( { OnNodeMouseDoubleClick_treeDirectories } )

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
	$FrmTreeView.Close()
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

Function New-InfoNode{
 #Crée et renvoie un objet qui sera inséré 
 # dans la propriété 'Tag' d'un TreeNode         
  param(
     [Parameter(Mandatory=$True,position=0)]
    [Boolean] $IsDirectory,
     [Parameter(Mandatory=$True,position=1)]
    [Boolean] $isEmpty
  )

  [pscustomobject]@{
    PSTypeName='InfoNode';
    IsDirectory=$IsDirectory;
    isEmpty=$(
      If ($IsDirectory -and $isEmpty) 
      {$True} 
      elseif (-Not $IsDirectory)
      {$False}
    )  
   }
}# New-InfoNode

Function New-TreeNode {
 #Crée et renvoi un TreeNode
  param(
     [Parameter(Mandatory=$True,position=0)]
    $Path,
     [Parameter(Mandatory=$True,position=1)]
    [Boolean] $IsDirectory,
      [Parameter(Mandatory=$True,position=2)]
    [Boolean] $isEmpty
  )
 
  $Node = New-Object System.Windows.Forms.TreeNode
   #Deux icones: File et Directory
   #$false=0 -> File icon
  $ImageIndex=[byte]$isDirectory
  $Node.ImageIndex = $ImageIndex
  $Node.SelectedImageIndex = $ImageIndex
  
   #Texte affiché dans l'étiquette du nœud d'arbre.
  $Node.Text = $Path.Name.TrimEnd('\') #root C:\
  #$Node.Name = $Path.FullName
  $Node.Tag = New-InfoNode -isDirectory $IsDirectory  -isEmpty $isEmpty
  Write-Output $Node
}#New-TreeNode

Function New-NodeFile{
 #crée et renvoi un Node pointant sur une entrée de fichier
 param(
     [Parameter(Mandatory=$True,position=0)]
    $Path
 )
  $Files=$Null
  $isDirectory=$Path.PSIsContainer
  if ($isDirectory)
  { $Files=@([System.IO.Directory]::GetFiles($Path.FullName,'*.*','TopDirectoryOnly'))}
  
  New-TreeNode -path $Path -IsDirectory $IsDirectory -isEmpty ($Files.Count -eq 0)
}# New-NodeFile

$Root=New-NodeFile -Path (Get-Item 'C:\')
[void]$treeDirectories.Nodes.Add($Root)
$treeDirectories.Nodes.Expand()

$FrmTreeView.Add_Shown({$FrmTreeView.Activate()})
$ModalResult=$FrmTreeView.ShowDialog()
# Libération des ressources
$Reader.Close()
# Libération de la Form
$FrmTreeView.Dispose()

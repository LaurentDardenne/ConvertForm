################################################################################ 
#
#  Nom     : C:\temp\result\SelectModuleFrm.ps1  
#  Version : 0.1
#  Auteur  :
#  Date    : le 24/09/2014
#
#  Généré sous PowerShell V3.0
#  Appel   : Convert-Form -Path G:\PS\ConvertForm\TestsWinform\AddonISE\SelectModuleFrm.Designer.cs  -Destination c:\temp\result -Secondary -asFunction
########################################################################

Function SelectModuleForm {
 param ( 
    [ValidateNotNullOrEmpty()]
    [Parameter(Position=0,Mandatory=$true)]
   $Parent,

    [ValidateNotNullOrEmpty()]
    [Parameter(Position=1,Mandatory=$true)]
  [string] $ScriptPath,
  
    [ValidateNotNullOrEmpty()]
    [Parameter(Position=2,Mandatory=$true)]
  [string] $FormTitle,
  
    [Parameter(Position=3,Mandatory=$true)]
   #System.Management.Automation.CommandInfo[] 
  $Command
 )

$SelectModuleFrm = New-Object System.Windows.Forms.Form

$lstbxModulesName = New-Object System.Windows.Forms.ListBox
#
# lstbxModulesName
#
$lstbxModulesName.Dock =[System.Windows.Forms.DockStyle]::Fill
$lstbxModulesName.FormattingEnabled = $true
$lstbxModulesName.Location = New-Object System.Drawing.Point(0, 0)
$lstbxModulesName.Name = "lstbxModulesName"
$lstbxModulesName.Size = New-Object System.Drawing.Size(345, 130)
$lstbxModulesName.TabIndex = 0

function OnDoubleClick_lstbxModulesName {
 $SelectModuleFrm.DialogResult="Ok"
 $SelectModuleFrm.Close()
}
$lstbxModulesName.Add_DoubleClick( { OnDoubleClick_lstbxModulesName } )

#
# SelectModuleFrm
#
$SelectModuleFrm.ClientSize = New-Object System.Drawing.Size(345, 130)
$SelectModuleFrm.Controls.Add($lstbxModulesName)
$SelectModuleFrm.Name = "SelectModuleFrm"
$SelectModuleFrm.Text = $FormTitle
$SelectModuleFrm.StartPosition = "CenterParent"
$SelectModuleFrm.DialogResult="Ok"

function OnLoad_SelectModuleFrm {
  $Command|
    Foreach { 
        #Version est à 0.0 si elle n'est pas renseignée
       $Text="{0} , version : {1}" -F $_.ModuleName,$_.Module.Version
       [void]$lstbxModulesName.Items.Add($Text)               
    }
  #Command par défaut utilisée par PS
 $lstbxModulesName.SelectedIndex=0
}
$SelectModuleFrm.Add_Load( { OnLoad_SelectModuleFrm } )

$SelectModuleFrm.Add_Shown({$SelectModuleFrm.Activate()})

 #Permet de centrer la fenêtre dans la fenêtre principale
$ModalResult=$SelectModuleFrm.ShowDialog($Parent)

 #Le bouton Close renvoie 'Cancel'
if ($ModalResult-eq 'Ok') 
{
  #Renvoi la commande sélectionnée
  Write-output $Command[$lstbxModulesName.SelectedIndex]
}

# Libération de la Form
$SelectModuleFrm.Dispose()
}# SelectModuleForm



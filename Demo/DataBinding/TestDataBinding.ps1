################################################################################ 
#
#  Nom     : TestDataBinding.ps1
# Version : 1.2.1
#
# Révision : $Rev: 180 $
#  Auteur  :
# Date    : 1 août 2010
#
################################################################################
 #Création du tableau d'objet
$ArrayList= new-object System.Collections.ArrayList

$Global:Number=0
function CreateItem {
 $Global:Number++
    
 $Item = new-object PSObject
                
#Affichage des infos
  $Item=$Item | Add-Member -membertype Noteproperty `
                    -name Name `
                    -value "Nom$Number" -pass|`
     Add-Member -membertype Noteproperty `
                -name Description `
                -value "description$Number" -pass|`
     Add-Member -membertype Noteproperty `
                -name IP_Address `
                -value "IPAddresse$Number" -pass|`
     Add-Member -membertype Noteproperty `
                -name Passerelle `
                -value "GW$Number" -pass|`
     Add-Member -membertype Noteproperty `
                -name DNS_Prim `
                -value "DNS1-$Number" -pass|`
     Add-Member -membertype Noteproperty `
                -name DNS_Sec `
                -value "DNS2-$Number" -pass
  #etc
 [void]$ArrayList.Add($Item)	

}
1..5|% {CreateItem}

# Chargement des assemblies externes
[void][Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
[void][Reflection.Assembly]::LoadWithPartialName("System.Drawing")

$pnlHaut = new-object System.Windows.Forms.Panel
$pnlBas = new-object System.Windows.Forms.Panel
$BtnClose = new-object System.Windows.Forms.Button
$BtnAddItem = new-object System.Windows.Forms.Button
$lstBoxObjects = new-object System.Windows.Forms.ListBox
#
# pnlHaut
#
$pnlHaut.Controls.Add($lstBoxObjects)
$pnlHaut.Dock =[System.Windows.Forms.DockStyle]::Fill
$pnlHaut.Location = new-object System.Drawing.Point(0, 0)
$pnlHaut.Name = "pnlHaut"
$pnlHaut.Size = new-object System.Drawing.Size(566, 329)
$pnlHaut.TabIndex = 0
#
# pnlBas
#
$pnlBas.Controls.Add($BtnAddItem)
$pnlBas.Controls.Add($BtnClose)
$pnlBas.Dock =[System.Windows.Forms.DockStyle]::Bottom
$pnlBas.Location = new-object System.Drawing.Point(0, 265)
$pnlBas.Name = "pnlBas"
$pnlBas.Size = new-object System.Drawing.Size(566, 64)
$pnlBas.TabIndex = 1
#
# BtnClose
#
$BtnClose.Location = new-object System.Drawing.Point(464, 29)
$BtnClose.Name = "BtnClose"
$BtnClose.Size = new-object System.Drawing.Size(75, 23)
$BtnClose.TabIndex = 0
$BtnClose.Text = "Close"
$BtnClose.UseVisualStyleBackColor = $true
function OnClick_BtnClose{
	$Form1.Close()
}

$BtnClose.Add_Click( { OnClick_BtnClose } )
#
# BtnAddItem
#
$BtnAddItem.Location = new-object System.Drawing.Point(334, 29)
$BtnAddItem.Name = "BtnAddItem"
$BtnAddItem.Size = new-object System.Drawing.Size(83, 23)
$BtnAddItem.TabIndex = 1
$BtnAddItem.Text = "Add item"
$BtnAddItem.UseVisualStyleBackColor = $true
function OnClick_BtnAddItem{
  CreateItem
  #If you are bound to a data source that does not implement the IBindingList interface, such as an ArrayList, 
  #the bound control's data will not be updated when the data source is updated.
  # la suite : http://msdn.microsoft.com/en-us/library/w67sdsex.aspx
  $lstBoxObjects.DataSource = $Null
  $lstBoxObjects.DataSource = $ArrayList
  $lstBoxObjects.DisplayMember = "Name"; 
  #$lstBoxObjects.Refresh()
}

$BtnAddItem.Add_Click( { OnClick_BtnAddItem } )
#
# lstBoxObjects
#
$lstBoxObjects.Dock =[System.Windows.Forms.DockStyle]::Fill
$lstBoxObjects.FormattingEnabled = $true
$lstBoxObjects.Location = new-object System.Drawing.Point(0, 0)
$lstBoxObjects.Name = "lstBoxObjects"
$lstBoxObjects.Size = new-object System.Drawing.Size(566, 329)
$lstBoxObjects.TabIndex = 0

 # --BINDING --
  #On lie la listbox avec le tableau $Arraylist
$lstBoxObjects.DataSource = $ArrayList
  #On visualise la propriété Name
$lstBoxObjects.DisplayMember = "Name"; 


#
$Form1 = new-object System.Windows.Forms.form
#
$Form1.ClientSize = new-object System.Drawing.Size(566, 329)
$Form1.Controls.Add($pnlBas)
$Form1.Controls.Add($pnlHaut)
$Form1.Name = "Form1"
$Form1.Text = "Test DataBinding"
function OnFormClosing_Form1{ 
	# $this est égal au paramètre sender (object)
	# $_ est égal au paramètre  e (eventarg)

	# Déterminer la raison de la fermeture :
	#   if (($_).CloseReason -eq [System.Windows.Forms.CloseReason]::UserClosing)

	#Autorise la fermeture
	($_).Cancel= $False
}
$Form1.Add_FormClosing( { OnFormClosing_Form1 } )
$Form1.Add_Shown({$Form1.Activate()})
$Form1.ShowDialog()
 #Libération des ressources
$Form1.Dispose()

Write-Host "Liste d'item :"
$ArrayList|ft


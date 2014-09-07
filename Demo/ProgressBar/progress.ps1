################################################################################ 
#
#  Nom     : progress.ps1
# Version : 1.2.1
#
# Révision : $Rev: 180 $
#  Auteur  : Laurent Dardenne
# Date    : 1 août 2010
#
################################################################################

# Chargement des assemblies externes
[void][Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
[void][Reflection.Assembly]::LoadWithPartialName("System.Drawing")

$components = new-object System.ComponentModel.Container
$timer1 = new-object System.Windows.Forms.Timer($components)
$panel1 = new-object System.Windows.Forms.Panel
$progressBar1 = new-object System.Windows.Forms.ProgressBar
#
# timer1
#
$timer1.Enabled = $true
$progressbar1.value=0
$progressbar1.Minimum=0
$progressbar1.Maximum=100
$progressbar1.MarqueeAnimationSpeed=1
function OnTick_timer1{
#	 1..100|% {$progressbar1.value =$_;Write-host $_;start-sleep -m 20}
$timer1.Enabled = $false
#$FrmTest15ProgressBarTimer.Close()
}
$timer1.Add_Tick( { OnTick_timer1 } )
#
# panel1
#
$panel1.Controls.Add($progressBar1)
$panel1.Dock =[System.Windows.Forms.DockStyle]::Fill
$panel1.Location = new-object System.Drawing.Point(0, 0)
$panel1.Name = "panel1"
$panel1.Size = new-object System.Drawing.Size(199, 32)
$panel1.TabIndex = 1
#
# progressBar1
#
$progressBar1.Dock =[System.Windows.Forms.DockStyle]::Fill
$progressBar1.Location = new-object System.Drawing.Point(0, 0)
$progressBar1.Name = "progressBar1"
$progressBar1.Size = new-object System.Drawing.Size(199, 32)
$progressBar1.Style =[System.Windows.Forms.ProgressBarStyle]::Continuous
#$progressBar1.Style =[System.Windows.Forms.ProgressBarStyle]::Blocks
#$progressBar1.Style =[System.Windows.Forms.ProgressBarStyle]::Marquee
$progressBar1.TabIndex = 1
#
$FrmTest15ProgressBarTimer = new-object System.Windows.Forms.form
#
$FrmTest15ProgressBarTimer.ClientSize = new-object System.Drawing.Size(199, 32)
$FrmTest15ProgressBarTimer.Controls.Add($panel1)
$FrmTest15ProgressBarTimer.Name = "FrmTest15ProgressBarTimer"
$FrmTest15ProgressBarTimer.Text = "Form1"
function OnFormClosing_FrmTest15ProgressBarTimer{ 
	# $this est égal au paramètre sender (object)
	# $_ est égal au paramètre  e (eventarg)

	# Déterminer la raison de la fermeture :
	#   if (($_).CloseReason -eq [System.Windows.Forms.CloseReason]::UserClosing)

	#Autorise la fermeture
	($_).Cancel= $False
}
$FrmTest15ProgressBarTimer.Add_FormClosing( { OnFormClosing_FrmTest15ProgressBarTimer} )

$Sb={
  #On connait le nombre d'item
 1..100|% {$progressbar1.value =$_;Write-host $_;start-sleep -m 20}
 $progressbar1.value=0
 
  #On connait le nombre d'item de la collection
  #Traitement en 2 passes
 $Col=gcm
 $progressbar1.Maximum=$Col.Count
 $Col|% {$progressbar1.value++;Write-host $_.name;start-sleep -m 20}
  
  #On ne connait pas le nombre d'item de la collection
  #Traitement en 1 passes
 $progressbar1.Maximum=1000 #valeur arbitraire
 $progressbar1.value=0
 gcm|% {$progressbar1.value++;Write-host $_.name;start-sleep -m 20}
 #$progressbar1.Value=1000 #Inutile ici car on ferme la forme tout de suite après
 
 $FrmTest15ProgressBarTimer.Close()
}

 #Active la fenêtre et exécute le traitement
$FrmTest15ProgressBarTimer.Add_Shown({$FrmTest15ProgressBarTimer.Activate();&$Sb})
$FrmTest15ProgressBarTimer.ShowDialog()
 #Libération des ressources
$FrmTest15ProgressBarTimer.Dispose()



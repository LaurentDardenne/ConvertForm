Throw "Paramètrage nécessaire`r`nModifiez la ligne : $fileSystemWatcher1.Path = 'C:\\Temp\\FileWatch'"

################################################################################ 
#
#  Name    : G:\PS\ConvertForm\TestsWinform\Test24FileWatcher\Form1.ps1
#  Version : 0.1
#  Author  :
#  Date    : 01/10/2015
#
#  Generated with ConvertForm module version 1.1
#  PowerShell version 4.0
#
#  Invocation Line   : Convert-Form -Path G:\PS\ConvertForm\TestsWinform\Test24FileWatcher\Form1.Designer.cs
#  Source            : G:\PS\ConvertForm\TestsWinform\Test24FileWatcher\Form1.Designer.cs
################################################################################


function RemoveEventHandler{
param($Object,$EventName)
    #On travaille sur le type de l'instance
  $MyType=$Object.GetType()
   #Récupère l'événement par son nom
  $Event=$MyType.GetEvent($EventName)
   #Un event à un délégué privé
  $bindingFlags = [Reflection.BindingFlags]"GetField,NonPublic,Instance"
   #On récupère la valeur du délégué privé
   #Pour un FSW le nom du champ est différent de $EventName  
  $EventField = $MyType.GetField("on${EventName}Handler",$bindingFlags)
  $Deleguate=$EventField.GetValue($Object)
  if ($Deleguate -ne $null)
  {
     #Récupère la liste des 'méthodes' à appeler par l'event
    $Deleguate.GetInvocationList()|
    Foreach {
        #On supprime tous les abonnements  
       $Event.RemoveEventHandler($Object,$_)
    }
  }
  else { Write-debug "`t '$EventName' delegates is NULL." }  
} #RemoveEventHandler  
   
function Get-ScriptDirectory
{ #Return the directory name of this script
  $Invocation = (Get-Variable MyInvocation -Scope 1).Value
  Split-Path $Invocation.MyCommand.Path
}

$ScriptPath = Get-ScriptDirectory

# Chargement des assemblies externes
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$FrmMain = New-Object System.Windows.Forms.Form

$btnOK = New-Object System.Windows.Forms.Button
$btnQuit = New-Object System.Windows.Forms.Button
$listView1 = New-Object System.Windows.Forms.ListView
$fileSystemWatcher1 = New-Object System.IO.FileSystemWatcher
#
# btnOK
#
$btnOK.DialogResult = [System.Windows.Forms.DialogResult]::OK
$btnOK.Location = New-Object System.Drawing.Point(184, 227)
$btnOK.Name = "btnOK"
$btnOK.Size = New-Object System.Drawing.Size(75, 23)
$btnOK.TabIndex = 0
$btnOK.Text = "Ok"
$btnOK.UseVisualStyleBackColor = $true
#
# btnQuit
#
$btnQuit.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
$btnQuit.Location = New-Object System.Drawing.Point(86, 227)
$btnQuit.Name = "btnQuit"
$btnQuit.Size = New-Object System.Drawing.Size(75, 23)
$btnQuit.TabIndex = 1
$btnQuit.Text = "Quitter"
$btnQuit.UseVisualStyleBackColor = $true
#
# listView1
#
$listView1.Location = New-Object System.Drawing.Point(12, 12)
$listView1.Name = "listView1"
$listView1.Size = New-Object System.Drawing.Size(247, 198)
$listView1.TabIndex = 2
$listView1.UseCompatibleStateImageBehavior = $false
#
# fileSystemWatcher1
#
  #Observe le nom du fichier uniquement
$fileSystemWatcher1.NotifyFilter = [System.IO.NotifyFilters]::FileName 
$fileSystemWatcher1.Path = 'C:\\Temp\\FileWatch' #Syntaxe C# à respecter, on double les '\'. Chemin UNC possible
$fileSystemWatcher1.Filter = '*.*'
$fileSystemWatcher1.SynchronizingObject = $FrmMain
 #https://msdn.microsoft.com/fr-fr/library/system.io.filesystemwatcher.internalbuffersize%28v=vs.110%29.aspx
#$fileSystemWatcher1.InternalBufferSize= 4 * 4Kb  #Par défaut 8Kb

function OnError_fileSystemWatcher1 {
    $Current=$_ # System.IO.ErrorEventArgs 
                # https://msdn.microsoft.com/fr-fr/library/vstudio/system.io.filesystemeventargs%28v=vs.100%29.aspx
    $FSWException = $Current.GetException()                    
	Write-Error "fileSystemWatcher erreur : $FSWException"
}

$fileSystemWatcher1.Add_Error( { OnError_fileSystemWatcher1 } )

function OnCreated_fileSystemWatcher1 {
    $Event=$_ # System.IO.FileSystemEventArgs 
                # https://msdn.microsoft.com/fr-fr/library/vstudio/system.io.filesystemeventargs%28v=vs.100%29.aspx
	Write-Warning "fileSystemWatcher file created : $($Event.Name)"
    $script:listView1.Items.Add($Event.FullPath)
}

$fileSystemWatcher1.Add_Created( { OnCreated_fileSystemWatcher1 } )


function OnDeleted_fileSystemWatcher1 {
  # System.IO.FileSystemEventArgs 
  # https://msdn.microsoft.com/fr-fr/library/vstudio/system.io.filesystemeventargs%28v=vs.100%29.aspx
 	#[void][System.Windows.Forms.MessageBox]::Show("L'évènement fileSystemWatcher1.Add_Deleted n'est pas implémenté.")
  Write-Warning "L'évènement fileSystemWatcher1.Add_Deleted n'est pas implémenté." 
}
 
$fileSystemWatcher1.Add_Deleted( { OnDeleted_fileSystemWatcher1 } )
 
 
function OnRenamed_fileSystemWatcher1 {
  # RenamedEventArgs
  # https://msdn.microsoft.com/fr-fr/library/vstudio/system.io.renamedeventargs%28v=vs.100%29.aspx
 	#[void][System.Windows.Forms.MessageBox]::Show("L'évènement fileSystemWatcher1.Add_Renamed n'est pas implémenté.")
  Write-Warning "L'évènement fileSystemWatcher1.Add_Renamed n'est pas implémenté." 
}
 
$fileSystemWatcher1.Add_Renamed( { OnRenamed_fileSystemWatcher1 } )

#
# FrmMain
#
$FrmMain.ClientSize = New-Object System.Drawing.Size(284, 262)
$FrmMain.Controls.Add($listView1)
$FrmMain.Controls.Add($btnQuit)
$FrmMain.Controls.Add($btnOK)
$FrmMain.Name = "FrmMain"
$FrmMain.Text = "Démo FileSystemWatcher"

function OnFormClosing_FrmMain{ 
	# $this parameter is equal to the sender (object)
	# $_ is equal to the parameter e (eventarg)

	# The CloseReason property indicates a reason for the closure :
	#   if (($_).CloseReason -eq [System.Windows.Forms.CloseReason]::UserClosing)

	#Sets the value indicating that the event should be canceled.
	($_).Cancel= $False
}

$FrmMain.Add_FormClosing( { OnFormClosing_FrmMain} )

$FrmMain.Add_Shown({$FrmMain.Activate()})

try {
 #A configurer en fin de paramétrage. 
 #L'activation peut déclencher des exceptions
 $fileSystemWatcher1.EnableRaisingEvents = $true 
 $ModalResult=$FrmMain.ShowDialog()
} catch {
 Write-Error "Inside FSW form : $_"
} finally { 
    
  if ($null -ne $fileSystemWatcher1) 
  {  
     #On force l'arrêt de la surveillance
    $fileSystemWatcher1.EnableRaisingEvents = $false
    
     #unsubscribe EventHandler
    RemoveEventHandler $fileSystemWatcher1 'Deleted' 
    RemoveEventHandler $fileSystemWatcher1 'Created'
    RemoveEventHandler $fileSystemWatcher1 'Error'
    RemoveEventHandler $fileSystemWatcher1 'Renamed'    
  
     #On force l'arrêt de la suppression.
    $fileSystemWatcher1.Dispose()
  } 
   # Libération de la Form
  if ($null -ne $FrmMain) 
  { $FrmMain.Dispose() }
}

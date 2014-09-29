 . .\Test.ps1
 ."c:\temp\T2.ps1"
 ."$Dir\$File"
 . $MyScript
 &"c:\temp\T3.ps1"
 &$MyScript

# 
# 
# $DebugLogger.PSDebug("$($_.Exception.GetType().FullName)")
# 
# $Result=$Path.Remove(0, $Root.Length).`
#          Replace('\', [System.IO.Path]::AltDirectorySeparatorChar).`
#          TrimStart([System.IO.Path]::AltDirectorySeparatorChar)   
# $DebugLogger.PSDebug("Items.count: $($Items.count)") #<%REMOVE%>
# $Old.PSObject.Properties.Match("*","Property")|
#   Foreach {
#    $New."$($_.Name)"=$Old."$($_.Name)"
#   }
# 
# Add-Type -Path "$psScriptRoot\$($PSVersionTable.PSVersion)\PSIonicTools.dll"
# $InitializeLogging=$MyInvocation.MyCommand.ScriptBlock.Module.NewBoundScriptBlock(${function:Initialize-Log4NetModule})
# . .\Test.ps1
# ."c:\temp\Test.ps1"
# ."$Dir\$File"
# &"c:\temp\Test.ps1"
# 
# $T=@($PSEventJobError|% {$_})
# 
# $Items[$Borne..($Items.Count-1)]|
#     Where {$_ -ne [string]::Empty}|
#     foreach {
#       $Properties=@{}
#     }
# 
# 
# ."c:\temp\Test.ps1"
# &(Get-Command -Name Map -Type function)
# &(dir function:\map)
# 
# $myMap = (Get-Command -Name map -Type function)
# &($myMap)
# $FileCommands = get-module -name FileCommands
# & $FileCommands Add-File
# 
# function un { 'ok'}
# . un
# &un
# .{"ok"}
# &{"ok"}
# 
#  
# 
# Unregister-PowerShellCommand
# 
# function Get-BitsTransfer { Write-host "Leurre" }
# 
# BitsTransfer\Get-BitsTransfer
# Get-BitsTransfer
#   Get-Ghost   #Erreur
# Disable-PSTrace
# Get-Help #pscx & Microsoft.PowerShell.Core
# gcm
# gzf
# 
# . .\Test.ps1
# ."c:\temp\Test.ps1"
# ."$Dir\$File"
# &"c:\temp\Test.ps1"
# 
# $p=$(dir c:\temp|gc)
# $p2=$(dir|czf)
# $code=@'
# Get-Help
# gcm
# gzf
# $A=$(get-service|Select -unique)
# . .\Test.ps1
# ."c:\temp\Test.ps1"
# ."$Dir\$File"
# &"c:\temp\Test.ps1"
# '@    
# 
# $codeExpand=@"
# Get-ContentHelp
# $B=$(get-Process -name xyz|Stop-process -whatif)
# $B2=$(gzf|Ezf)
# cls
# "@  
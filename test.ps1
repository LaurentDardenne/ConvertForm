cd  G:\PS\ConvertForm\V2
ipmo .\ConvertForm.psd1
#dbgon
$verbosepreference='Continue'

Convert-Form -Source G:\PS\ConvertForm\TestsWinform\Base\Form1.Designer.cs -Destination C:\temp\TestFrm1

$Source='G:\PS\ConvertForm\TestsWinform\Base\Form1.Designer.cs '
$Destination='C:\temp\TestFrm1.ps1'
     
$AddInitialize= @($true,$false)
$DontLoad= @($true,$false)
$DontShow= @($true,$false)
$Force= @($true,$false)
$HideConsole= @($true,$false)
$PassThru= @($true,$false)
     
$STA= @($true,$false)
$cmd=Get-Command Convert-Form
$result=New-TestSetParameters -command $Cmd
$Result.lines|
 Sort-Object|
 foreach {
  pause
  Write-host $_ -fore green
  $_
  }|
 Invoke-Expression
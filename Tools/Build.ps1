#Build.ps1
#Construit la livraison de ConvertForm. 
 [CmdletBinding(DefaultParameterSetName = "Debug")]
 Param(
     [Parameter(ParameterSetName="Release")]
   [switch] $Release
 ) 

Set-Location $ConvertFormTools

try {
 'Psake','DTW.PS.FileSystem'|
 Foreach {
   $name=$_
   Import-Module $Name -EA stop -force
 }
} catch {
 Throw "Module $name is unavailable."
}  

$Error.Clear()
$Configuration=@{"Config"="$($PsCmdlet.ParameterSetName)"}
Invoke-Psake .\Delivery.ps1 -parameters $Configuration -nologo
 


#Build.ps1
#Construit la livraison de ConvertForm. 
 [CmdletBinding(DefaultParameterSetName = "Debug")]
 Param(
     [Parameter(ParameterSetName="Release")]
   [switch] $Release
 ) 
# Le profile utilisateur (Profile_DevCodePlex.Ps1) doit être chargé

Set-Location $ConvertFormTools

try {
 'Psake','Psionic','DTW.PS.FileSystem'|
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

if ($psake.build_success)
{ 
 Invoke-Psake .\BuildZipAndSFX.ps1 -parameters $Configuration -nologo 
}
 


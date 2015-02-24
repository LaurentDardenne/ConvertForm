#Initialize-FilesTest.ps1

if ( -not (test-path Variable:ConvertForm) )
{ Throw 'Variable:ConvertForm do not exist.' } 

Import-Module Pester

if (Test-Path $Env:Temp)
{ $Temp=$Env:Temp }
else
{ $Temp=[System.IO.Path]::GetTempPath() }

$TestDirectory=Join-Path $Temp TestConvertForm
Write-host "Test in $TestDirectory"
rm $TestDirectory -rec -force -ea SilentlyContinue >$null
md $TestDirectory -ea SilentlyContinue >$null

$TestNomDeFichier="$TestDirectory\Test.txt"
"Test Fichier" > $TestNomDeFichier

cd $ConvertFormTests
 
 #Suppose la construction préalable via ..\Tools\Build.Ps1
Import-Module "$ConvertFormLivraison\ConvertForm.psd1" 

Set-Location $ConvertFormTests
Invoke-Pester 
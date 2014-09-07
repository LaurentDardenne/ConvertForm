#requires -version 3.0

#Write these line in the Windows PowerShell profile
# ."$env:PsIonicProfile\Tools\Profile_DevCodePlex.Ps1"
#Créez une variable d'environnement système nommée PsIonic pointant sur votre répertoire de travail
#Puis modifiez les lignes indiquées comme spécfiques au poste de  développement

$SM = [System.Environment+SpecialFolder]::MyDocuments
$PSProfile="$([System.Environment]::GetFolderPath($SM))\WindowsPowerShell"
$PSScripts=$PSProfile+"\Scripts"

$PathRepository='G:\PS' # Spécifique au poste de développement
$ProjectName='ConvertForm'

$PsVersion=$PSVersionTable.PsVersion

Set-Location "$PathRepository\$ProjectName\Tools"

  #Pour cette hashtable on retarde la substitution, 
 #car on référence des clés de la hashtable 'primaire'
$Paths=@{
 Bin='$($Properties.RepositoryLocation)\Bin'; #Debug et Release
 Livraison='C:\Temp\$ProjectName'; # Spécifique au poste de développement, n'est pas versionné. 
                                   # On construit la livraison à partir du référentiel GIT
 Tests='$($Properties.RepositoryLocation)\Tests';
 Tools='$($Properties.RepositoryLocation)\Tools';
 Help='$($Properties.RepositoryLocation)\Documentation';
 Setup='$($Properties.RepositoryLocation)\Setup';
 Logs='C:\Temp\Logs\$ProjectName'   # Spécifique au poste de développement
}

. .\New-ProjectVariable.ps1

$ConvertForm=New-ProjectVariable $ProjectName $PathRepository 'https://git01.codeplex.com/convertform' $Paths
$ConvertForm.NewVariables() #Crée des variables constante d'après les clés de la hashtable $ConvertForm

 #PSDrive sur le répertoire du projet 
$null=New-PsDrive -Scope Global -Name $ConvertForm.ProjectName -PSProvider FileSystem -Root $ConvertFormRepositoryLocation 

Write-Host "Projet $ProjectName - $PsVersion configuré." -Fore Green

rv SM,Paths,ProjectName,PathRepository
Set-Location ..

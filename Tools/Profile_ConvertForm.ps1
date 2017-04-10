Param (
 # Specific to the development computer
 [string] $VcsPathRepository=''
) 

if (Test-Path env:APPVEYOR_BUILD_FOLDER)
{
  $VcsPathRepository=$env:APPVEYOR_BUILD_FOLDER
}

if (!(Test-Path $VcsPathRepository))
{
  Throw 'Configuration error, the variable $VcsPathRepository should be configured.'
}

# Common variable for development computers
if ( $null -eq [System.Environment]::GetEnvironmentVariable('ProfileConvertForm','User'))
{ 
 [Environment]::SetEnvironmentVariable('ProfileConvertForm',$VcsPathRepository, 'User')
  #refresh the Powershell environment provider
 $env:ProfileConvertForm=$VcsPathRepository 
}

 # Specifics variables  to the development computer
$ConvertFormDelivery= "$env:Temp\Delivery\ConvertForm"   
$ConvertFormLogs= "$env:Temp\Logs\ConvertForm" 
$ConvertFormDelivery, $ConvertFormLogs|
 Foreach-Object {
  if (-not (Test-Path $_))
   { new-item $_ -ItemType Directory  > $null }         
 }

 # Commons variable for all development computers
 # Their content is specific to the development computer 
$ConvertFormBin= "$VcsPathRepository\Bin"
$ConvertFormSrc= "$VcsPathRepository"
$ConvertFormHelp= "$VcsPathRepository"
$ConvertFormSetup= "$VcsPathRepository"
$ConvertFormVcs= "$VcsPathRepository"
$ConvertFormTests= "$VcsPathRepository\Tests"
$ConvertFormTools= "$VcsPathRepository\Tools"
$ConvertFormUrl='https://github.com/LaurentDardenne/ConvertForm' 

 #PSDrive to the project directory 
$null=New-PsDrive -Scope Global -Name ConvertForm -PSProvider FileSystem -Root $ConvertFormVcs 

Write-Host 'Settings of the variables of ConvertForm project.' -Fore Green

rv VcsPathRepository


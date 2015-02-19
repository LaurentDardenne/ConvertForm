function New-FileNameTimeStamped{
 param(
  [parameter(Mandatory=$True)]
  [string] $FileName,
  [System.DateTime] $Date=(Get-Date),
  [string] $Format='dd-MM-yyyy-HH-mm-ss')

  $SF=New-object System.IO.FileInfo $FileName 
  "{0}\{1}-{2:$Format}{3}" -F $SF.Directory,$SF.BaseName,$Date,$SF.Extension
}#New-FileNameTimeStamped
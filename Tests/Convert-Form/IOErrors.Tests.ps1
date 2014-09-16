Function Lock-File{
#Verrouille un fichier à des fins de tests
  param([string] $Path)

  New-Object System.IO.FileStream($Path, 
                                  [System.IO.FileMode]::Open, 
                                  [System.IO.FileAccess]::ReadWrite, 
                                  [System.IO.FileShare]::None)
} #Lock-File

Function Set-LockFile{
 param($FileName)   
 $TestLockFile=$null      
 try {
    Write-Debug "Lock $FileName"
    $TestLockFile= Lock-File $FileName
    if ($TestLockFile -ne $null)
    { Convert-Form -Path $Designer -Destination $DestinationDirectory -Force }
    Else 
    { Write-Error "BUG dans le code du test" }
  } finally {
     if ($TestLockFile -ne $null)
     { $TestLockFile.Close() }
  }
}#Set-LockFile

$ProjectDirectory ="$($ConvertForm.RepositoryLocation)\TestsWinform\Test3Menus"
$Designer="$ProjectDirectory\FrmTest3Menus.Designer.cs"
$DestinationDirectory= "$TestDirectory\Test3Menus"

Describe "Valid IO errors" {
   Context "Première passe : création des fichiers du scénario" {
    It "works" {
      Remove-Item $DestinationDirectory -ea SilentlyContinue -recurse -Force -verbose 
      md $DestinationDirectory -ea SilentlyContinue -verbose > $null         

      { Convert-Form -Path $Designer -Destination $DestinationDirectory -Force } | Should not Throw
    }
   }
   
   Context "Seconde passe : Warning sur le verrouillage du fichier log existant 'FrmTest3Menus.resources.log'" {
    It "works" {
      { Set-LockFile "$DestinationDirectory\FrmTest3Menus.resources.log" } | Should not Throw
    }
   }  
    
   Context "Seconde passe : Erreur sur le verrouillage du fichier Designer 'FrmTest3Menus.Designer.cs'" {
    It "fails" {
      { Set-LockFile "$ProjectDirectory\FrmTest3Menus.Designer.cs" } | Should Throw
    }
   }
  
   Context "Seconde passe : Erreur sur le verrouillage du fichier .ps1 'FrmTest3Menus.ps1'" {
    It "fails" {
      { 
        $ErrorActionPreference='Stop'  
         Set-LockFile "$DestinationDirectory\FrmTest3Menus.ps1" 
        $ErrorActionPreference='Continue' 
      } | Should Throw
    }
   }
   
   Context "Seconde passe : Erreur sur le verrouillage du fichier resources 'FrmTest3Menus.resources'" {
    It "fails" {
      {        
        $ErrorActionPreference='Stop'
         Set-LockFile "$DestinationDirectory\FrmTest3Menus.resources" } | Should Throw
        $ErrorActionPreference='Continue'
    }
   }
   
   Context "Seconde passe : Erreur sur le verrouillage du fichier resx 'FrmTest3Menus.resx'" {
    It "fails" {
      { 
        $ErrorActionPreference='Stop'
         Set-LockFile "$ProjectDirectory\FrmTest3Menus.resx" 
        $ErrorActionPreference='Continue'
      } | Should Throw
    }
   }
}

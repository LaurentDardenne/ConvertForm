$ProjectDirectory ="$($ConvertForm.RepositoryLocation)\TestsWinform\Test3Menus"
$Designer="$ProjectDirectory\FrmTest3Menus.Designer.cs"
$DestinationDirectory= "$TestDirectory\Test3Menus"

Describe "Valid Resgen errors" {
    It "Resgen.exe not found" {
      try {
      Rename-item "$($ConvertForm.RepositoryLocation)\ResGen.exe" "$($ConvertForm.RepositoryLocation)\ResGen.exe.test" 
      { 
       $ErrorActionPreference='Stop' 
        Convert-Form -Path $Designer -Destination $DestinationDirectory -Force 
       $ErrorActionPreference='Continue'  
      } | Should Throw
      } finally {
        Rename-item "$($ConvertForm.RepositoryLocation)\ResGen.exe.test" "$($ConvertForm.RepositoryLocation)\ResGen.exe"
      }         
    }

    It "Resource file not found" { 
      copy $Designer $DestinationDirectory -force -verbose
      { 
       $ErrorActionPreference='Stop' 
        Convert-Form -Path "$DestinationDirectory\FrmTest3Menus.Designer.cs" -Destination $DestinationDirectory -Force 
       $ErrorActionPreference='Continue'  
      } | Should Throw         
    }
    
    It "Create resourcefile error " { 
      fsutil file createnew "$DestinationDirectory\FrmTest3Menus.resx" 0 
      { 
       $ErrorActionPreference='Stop' 
        Convert-Form -Path "$DestinationDirectory\FrmTest3Menus.Designer.cs" -Destination $DestinationDirectory -Force 
       $ErrorActionPreference='Continue'  
      } | Should Throw         
    }

}

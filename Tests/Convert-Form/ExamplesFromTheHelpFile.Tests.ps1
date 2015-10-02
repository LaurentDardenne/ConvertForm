#todo nouveau exemples et usage du 'delay-binding scriptblock'

$Designer ="$($ConvertFormRepositoryLocation)\TestsWinform\Base\Form1.Designer.cs"
$DesignerLiteralpath ="$($ConvertForm.RepositoryLocation)\TestsWinform\Test21LiteralPath[AG]Naming\Frm[AG].Designer.cs"

$ScriptFileForm="$($ConvertFormRepositoryLocation)\TestsWinform\Base\Form1.ps1"
$SbRemove={
 if (Test-Path $ScriptFileForm)
 { Remove-Item $ScriptFileForm }
}
$ScriptFileFormLiteral="$($ConvertForm.RepositoryLocation)\TestsWinform\Test21LiteralPath[AG]Naming\Frm[AG].ps1"
$SbRemoveLiteral={
 if (Test-Path $ScriptFileFormLiteral)
 { Remove-Item $ScriptFileFormLiteral}
}


Describe "Exemples du fichier d'aide" {

   Context "Example 1" {
    It "Works" {
      {   
        &$SbRemove
        $FormPath = $Designer
        Convert-Form -Path $FormPath
      } | Should not Throw
    }
   }

   Context "Example 2" {
            
    It "Works" {
      { 
        $FormPath = $Designer
        if (-not (Test-Path 'C:\Temp'))
        {md C:\Temp}
        Convert-Form -Path $FormPath -Destination C:\Temp -Force
      } | Should not Throw
    }
   }

   Context "Example 3" { 
    It "Works" {
      { 
        &$SbRemoveLiteral
        if (-not (Test-Path 'C:\Temp\FormAG'))
        {md C:\Temp\FormAG}
        $ScriptWinform=Convert-Form -LiteralPath $DesignerLiteralpath -DestinationLiteral C:\Temp\FormAG -Encoding Unicode -Passthru -Verbose      
      } | Should not Throw
    }
   }
  
   Context "Example 4" { 
    It "Works" {
      { 
        &$SbRemove
        $FormPath = $Designer
        Convert-Form -Path $FormPath -Secondary      
      } | Should not Throw
    }
   }

   Context "Example 5" { 
    It "Works" {
      { 
        &$SbRemove
        $FormPath = $Designer
        Convert-Form -Path $FormPath -HideConsole     
      } | Should not Throw
    }
   }
}

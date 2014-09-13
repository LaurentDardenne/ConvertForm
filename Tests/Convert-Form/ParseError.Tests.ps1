$DesignerNoInitializeComponentMethod ="$($ConvertForm.RepositoryLocation)\TestsWinform\TestNotWinFormFile\Error.aspx.designer.cs"
$DesignerNoFormName="$($ConvertForm.RepositoryLocation)\TestsWinform\TestNotWinFormFile\NoFormName.Designer.cs"

Describe "ParseError" {
   Context "La méthode InitializeComponent() est introuvable" { 
    It "fails" {
      { Convert-Form -Path $DesignerPanelBadAnalyze -Destination "$TestDirectory"} | Should Throw
    }
   }
   
   Context "Le nom de la Form est introuvable dans la méthode InitializeComponent()" { 
    It "fails" {
      { Convert-Form -Path $DesignerNoFormName -Destination "$TestDirectory"} | Should Throw
    }
   }

}

$DesignerPanelBadAnalyze ="$($ConvertForm.RepositoryLocation)\TestsWinform\Test5Panel\FrmTest5PanelTableLayoutPanel.Designer.cs"

Describe "Syntax error" {
   Context "L'analyse de Panels est erronée" { 
    It "fails" {
      md ($TestDirectory+'\Test5Panel') -ea SilentlyContinue >$null
      { 
        $ErrorActionPreference='Stop'
         Convert-Form -Path $DesignerPanelBadAnalyze -Destination "$TestDirectory\Test5Panel"  -force
        $ErrorActionPreference='Continue'  
      } | Should Throw
    }
   }
}

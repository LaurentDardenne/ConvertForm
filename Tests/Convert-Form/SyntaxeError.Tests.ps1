$DesignerPanelBadAnalyze ="$($ConvertForm.RepositoryLocation)\TestsWinform\Test5Panel\FrmTest5PanelTableLayoutPanel.Designer.cs"

Describe "SyntaxError" {
   Context "L'analyse de Panels est erronée" { 
    It "fails" {
      md ($TestDirectory+'\Test5Panel') -ea SilentlyContinue >$null
      { Convert-Form -Path $DesignerPanelBadAnalyze -Destination "$TestDirectory\Test5Panel"} | Should Throw
    }
   }
}

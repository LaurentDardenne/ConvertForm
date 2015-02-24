$DesignerPanelBadAnalyze ="$($ConvertForm.RepositoryLocation)\TestsWinform\Test5Panel\FrmTest5PanelTableLayoutPanel.Designer.cs"

Function ValidateExpectedContent {
 param($Files,$ExpectedFiles) 
  $Cmp=@(Compare-Object $ExpectedFiles $Files)
  $Result=$Cmp.Count -eq 0
  if ($Result -eq $false)
  {
   Write-host @"
$($cmp|select *)
=> Additional item into the Catalog
<= Missing item into the Catalog
"@
  }
  $Result
}#ValidateExpectedContent

Describe "Syntax error" {
 Context "L'analyse de Panels est erronée" { 
  It "fails" {
    md ($TestDirectory+'\Test5Panel') -ea SilentlyContinue >$null
    { 
      $ErrorActionPreference='Stop'
       Convert-Form -Path $DesignerPanelBadAnalyze -Destination "$TestDirectory\Test5Panel"  -force
      $ErrorActionPreference='Continue'  
    } | Should Throw
  }#it
 }
}#Describe

Describe "Validates the conversion of all projects" {  
  It "only 3 projects fail" {
   #Au 22/09/2014, la conversion de ces projets, et uniquement ceux-ci, provoqueront des erreurs de syntaxe.
     # TestsWinform\TestFrm\Form1.Designer.cs
     # TestsWinform\Test19Localisation\FrmMain.Designer.cs
     # TestsWinform\Test14BoitesDeDialogue\FrmTest14BoitesDeDialogue.Designer.cs
   $ExpectedContent=@(
    'FrmTest5PanelTableLayoutPanel.ps1',
    'FrmMain.ps1',
    'FrmTest14BoitesDeDialogue.ps1'
   )
   
   #Erreur 'Convert-Form : Le nom de la Form est introuvable dans la méthode InitializeComponent() du fichier'
   # pour ces 2 fichiers : 
   # 'G:\PS\ConvertForm\TestsWinform\TestNotWinFormFile\NoFormName.Designer.cs'
   # 'G:\PS\ConvertForm\TestsWinform\Test20ExternalReferences\Form1.Designer.cs'
   
   cd $ConvertForm.RepositoryLocation
 
   # Recherche tous les fichiers Winform d'une arborescence
   # le nom fini uniquement par ".Designer.cs"
   # Le début peut être quelconque  = *
   # sauf = *.ascx.designer.cs
   # sauf = *.aspx.designer.cs
   # sauf les fichiers des répertoires dont le nom finit par "Properties", donc :
   #        sauf = Ressources.designer.cs
   #        sauf = Settings.designer.cs
   try {
     Push-Location "$($ConvertForm.RepositoryLocation)\TestsWinform"
                  #Segment 1 : Recherche tous les fichiers Winform d'une arborescence, on exclut ceux des projets WEB
     $AllFiles=Get-ChildItem -recurse -include *.Designer.cs -exclude *.as[cp]x.designer.cs|
                  #Segment 2 : On exclut les fichiers dont le nom se termine par Properties
                where {(Split-Path ($_).Fullname) -notmatch 'Properties$'}|
                  #Segment 3 : On enregistre le nom complet des fichiers trouvés
                ForEach {($_).Fullname}
   } finally {   
     Pop-Location
   }
  
   $ResultPath="$TestDirectory\Result"
   md $ResultPath -EA SilentlyContinue
   $Error.Clear()
    #Pour un fichier Winform, on récupére le nom du projet puis on exécute le script
    #todo BUG Destination=nom du projet alors que ce doit être le nom du fichier.cs (projet multi-formulaire)
   $AllFiles|% {
      $Name=[IO.Path]::GetFileNameWithoutExtension($_)
      $name= $Name -replace "\.designer"
      #todo créer un répertoire par projet
      Write-Host "Fichier source : $_`r`nFichier cible  : $ResultPath\$Name.ps1"
      try {
         Convert-Form -LiteralPath $_ -DestinationLiteral $ResultPath -force
       } catch {
         Write-error "$name" 
      }
   }
  
   $List=$Error|
           Where {$_.CategoryInfo.Category -eq 'SyntaxError'}|
           Foreach {$_.CategoryInfo.TargetName;Write-Warning "Projet en erreur : $($_.CategoryInfo.TargetName)"}|
           split-path -Leaf

    $Result = ValidateExpectedContent $List $ExpectedContent
    $Result | should be $true
  }#it
}#Describe
 

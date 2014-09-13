$DesignerFileExisting ="$($ConvertForm.RepositoryLocation)\TestsWinform\Base\Form1.Designer.cs"
$DesignerFileExistingLiteralpath ="$($ConvertForm.RepositoryLocation)\TestsWinform\Test21LiteralPath[AG]Naming\Frm[AG].Designer.cs"

Describe "PathParameters" {
   Context "Le paramètre Path (..) doit être un nom de fichier" {
     It "fails" {
       { Convert-Form -Path .. -Destination .. }| Should Throw
     }
   }

   Context "Le paramètre Path (.) doit être un nom de fichier" {
     It "fails" {
       { Convert-Form -Path . -Destination ..} | Should Throw
     }
   }

   Context "Le paramètre Destination (.) doit être un nom de fichier" {
     It "fails" {
       { Convert-Form -Path $DesignerFileExisting -Destination .} | Should Throw
     }
   }

   Context "Le paramètre Destination (..) doit être un nom de fichier" {
     It "fails" {
       { Convert-Form -Path $DesignerFileExisting -Destination ..} | Should Throw
     }
   }
   
   Context "-Destination ET -DestinationLiteral : Les paramètres sont exclusifs" {
     It "fails" {
       { Convert-Form -Path $DesignerFileExisting -Destination .. -DestinationLiteral ..}| Should Throw
     }
   }

   Context "-Path NOK : Le globbing n'est pas supporté" { 
    It "fails" {
      md ($TestDirectory+'\Frm[AZ]') -ea SilentlyContinue > $null
      md ($TestDirectory+'\Frm`[AZ`]') -ea SilentlyContinue > $null       
      { Convert-Form -Path $DesignerFileExistingLiteralpath -Destination "$TestDirectory\Frm[AZ]"} | Should Throw
    }
   }

   Context "-Path OK -Destination NOK : Le globbing n'est pas supporté" { 
    It "fails" {
      { Convert-Form -Path $DesignerFileExisting -Destination "$TestDirectory\Frm[AZ]"} | Should Throw
    }
   }

   Context "-LiteralPath OK -Destination NOK: Le globbing n'est pas supporté" { 
    It "fails" {
      { Convert-Form -LiteralPath $DesignerFileExistingLiteralpath -Destination "$TestDirectory\Frm[AZ]"} | Should Throw
    }
   }

   Context "-Path : Le fichier n'existe pas" {
     It "fails" {
       { Convert-Form -Path 'c:\temp\NotExist.Designer.cs' -Destination .} | Should Throw
     }
   }

   Context "-LiteralPath : Le fichier n'existe pas" {
     It "fails" {
       { Convert-Form -LiteralPath 'c:\temp\NotExist.Designer.cs' -Destination .} | Should Throw
     }
   }

   Context "-Path: Le chemin du fichier n'existe pas" {
     It "fails" {
       { Convert-Form -Path 'C:\NotExist\MainForm.Designer.cs' -Destination .} | Should Throw
     }
   }

    Context "-LiteralPath: Le chemin du fichier n'existe pas" {
     It "fails" {
       { Convert-Form -LiteralPath 'C:\NotExist\MainForm.Designer.cs' -Destination .} | Should Throw
     }
   }

   Context "-Path OK -DestinationLiteral NOK: Le répertoire n'existe pas" { 
    It "fails" {
      { Convert-Form -Path $DesignerFileExisting -DestinationLiteral ($TestDirectory+'\Frm[AZ]\NotExist') -force} | Should Throw
    }
   }
   
   Context "-LiteralPath OK -DestinationLiteral NOK: Le répertoire n'existe pas" { 
    It "fails" {
      { Convert-Form -LiteralPath $DesignerFileExisting -DestinationLiteral ($TestDirectory+'\Frm[AZ]\NotExist') -force} | Should Throw
    }
   }

   Context "-Destination : Le répertoire n'existe pas" {
     It "fails" {
       { Convert-Form -Path $DesignerFileExisting -Destination 'C:\PathNotexist'} | Should Throw
     }
   }

   Context "Path OK -Destination NOK : Le lecteur indiqué n'existe pas" {
     It "fails" {
       { Convert-Form -Path $DesignerFileExisting -Destination 'H:\Temp\pathExist'} | Should Throw
     }
   }

   Context "-Path OK -Destination NOK: Le chemin doit pointer sur le FileSystem" {
     It "fails" {
       { Convert-Form -Path $DesignerFileExisting -Destination 'Hklm:\Software\frm.ps1'} | Should Throw
     }
   }

   Context "-Path : Le lecteur indiqué n'existe pas" {
     It "fails" {
       { Convert-Form -Path 'H:\PS\MainForm.Designer.cs' -Destination .} | Should Throw
     }
   }

   Context "-Path : Le chemin doit pointer sur le FileSystem" {
     It "fails" {
       { Convert-Form -Path 'Hklm:\Software\MainForm.Designer.cs' -Destination .} | Should Throw
     }
   }

   Context "-Path OK -DestinationLiteral OK: Le globbing est supporté" { 
    It "Works" {
      { Convert-Form -Path $DesignerFileExisting -DestinationLiteral ($TestDirectory+'\Frm[AZ]') -force} | Should not Throw
    }
   }
      
   Context "-Literal OK : la construction du chemin destination est correcte" {
    It "works" {
      { Convert-Form -LiteralPath $DesignerFileExistingLiteralpath -Force } | Should not Throw
    }
   }
}
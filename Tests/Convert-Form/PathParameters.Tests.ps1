$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")
. "$here\$sut"

$DesignerFileExisting ='$($ConvertForm.RepositoryLocation)\TestsWinform\Base\Form1.Designer.cs'

Describe "PathParameters" {
   Context "Le paramètre Source doit être un nom de fichier" {
     It "fails" {
        Convert-Form -Source .. -Destination .. -ErrorAction SilentlyContinue| Should Throw
     }
   }

   Context "Le paramètre Source doit être un nom de fichier" {
     It "fails" {
        Convert-Form -Source . -Destination ..| Should Throw
     }
   }

   Context "Le paramètre Destination doit être un nom de fichier" {
     It "fails" {
        Convert-Form -Source $DesignerFileExisting -Destination .| Should Throw
     }
   }

   Context "Le paramètre Destination doit être un nom de fichier" {
     It "fails" {
        Convert-Form -Source $DesignerFileExisting -Destination ..| Should Throw
     }
   }

   Context "Le fichier n'existe pas" {
     It "fails" {
        Convert-Form -Source 'c:\temp\NotExist.Designer.cs' -Destination .| Should Throw
     }
   }

   Context "Le fichier n'existe pas" {
     It "fails" {
        Convert-Form -Source 'c:\NotExist\MainForm.Designer.cs' -Destination .| Should Throw
     }
   }

   Context "Le lecteur indiqué n'existe pas" {
     It "fails" {
        Convert-Form -Source 'H:\PS\MainForm.Designer.cs' -Destination .| Should Throw
     }
   }

   Context "Le chemin doit pointer sur le FileSystem" {
     It "fails" {
        Convert-Form -Source 'Hklm:\Software\MainForm.Designer.cs' -Destination .| Should Throw
     }
   }

   Context "Le répertoire n'existe pas" {
     It "fails" {
        Convert-Form -Source $DesignerFileExisting -Destination 'C:\Notexist\Frm1.ps1'| Should Throw
     }
   }

   Context "Le lecteur indiqué n'existe pas" {
     It "fails" {
        Convert-Form -Source $DesignerFileExisting -Destination 'H:\Temp\Exist.ps1'| Should Throw
     }
   }

   Context "Le chemin doit pointer sur le FileSystem" {
     It "fails" {
        Convert-Form -Source $DesignerFileExisting -Destination 'Hklm:\Software\frm.ps1'| Should Throw
     }
   }
}
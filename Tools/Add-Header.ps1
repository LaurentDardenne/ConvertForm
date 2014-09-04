#Peut être modifié selon vos besoins.

Function Add-Header([String] $NomScript, $InvocationLine)
{ #Crée l'entête du script

 $Date="{0:d}" -f [DateTime]::Today #Format JJ/MM/AAAA
 $Line ="#" * 80
 
  #Ces info de logs devrait être placés en fin de fichier sources.
  # Doc SVN: http://svnbook.red-bean.com/en/1.1/ch07s02.html#svn-ch-7-sect-2.3.4
@"
$Line 
`#
`#  Nom     : $NomScript
`#  Version : 0.1
`#  Auteur  :
`#  Date    : le $Date
`#
`#  Généré sous PowerShell V$($PSVersionTable.PSVersion)
`#  Appel   : $InvocationLine
<#
Historique :
(Soit substitution CVS)
`$Log`$
(soit substitution SVN)
`$LastChangedDate`$
`$Rev`$
#>
$Line

"@
}


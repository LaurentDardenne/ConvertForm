ConvertFrom-StringData @'
 FileSystemPathRequired=Le chemin doit pointer sur le FileSystem.
 FileSystemPathRequiredForCurrentLocation=L'usage de chemin relatif, nécessite que le chemin courant pointe sur le système de fichier : {0}
 GlobbingUnsupported=Le globbing n'est pas supporté pour ce paramètre : {0} 
 DriveNotFound=Le lecteur indiqué n'existe pas  : '{0}'  
 ItemNotFound=Le fichier est introuvable : '{0}' 
 
 BeginAnalyze=Démarrage de l'analyse du fichier '{0}'
 ComponentRequireSTA=Le composant suivant ou une de ces fonctionnalités, requiert le modèle de thread STA (Single Thread Apartment)).`r`nRéessayez avec le paramètre -STA.
 InitializeComponentNotFound=La méthode InitializeComponent() est introuvable dans le fichier {0}.`n`rLa conversion ne peut s'effectuer.
 
 DesignerNameNotFound=`n`r.Vérifiez que le nom du fichier source est bien celui généré par le designer de Visual Studio : FormName.Designer.cs.
 FormNameNotFound=Le nom de la Form est introuvable dans la méthode InitializeComponent() du fichier '{0}'.`n`rLa conversion ne peut s'effectuer.`n`r{1}"  
 TransformationProgress=Transformation du code source ({0}) lignes
 TransformationProgressStatus=Veuillez patienter
 ReadChoiceCaption=Le fichier de destination existe déjà : '{0}'
 ReadChoiceMessage=Voulez-vous le remplacer ?
 OperationCancelled=Opération abandonnée.
 
 GenerateScript=Génération du script '{0}'`r`n
 SyntaxVerification=Vérification de la syntaxe du script généré.
 
 ConversionComplete=Conversion terminée : '{0}' 
 
 ParameterHideConsoleNotNecessary=Si vous convertissez une form secondaire l'usage du switch -HideConsole n'est pas nécessaire.`n`rSi c'est le cas, réexécutez votre appel sans préciser ce switch. 
 ParameterStringEmpty=Le paramètre '{0}' ne peut être une chaîne vide.
 ThisParameterRequiresThisParameter=Le paramètre '{0}' nécessite de déclarer le paramètre '{1}'.
'@ 

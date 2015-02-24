ConvertFrom-StringData @'
 FileSystemPathRequired=The path must be on file system : {0}
 FileSystemPathRequiredForCurrentLocation=L'usage de chemin relatif, nécessite que le chemin courant pointe sur le système de fichier : {0}
 GlobbingUnsupported=Le globbing n'est pas supporté pour ce paramètre : {0} 
 ParameterMustBeAfile=Le paramètre doit référencer un nom de fichier et pas un nom de répertoire : {0}
 ParameterMustBeAdirectory=Le paramètre doit référencer un nom de répertoire et pas un nom de fichier : {0}
 DriveNotFound=Le lecteur indiqué n'existe pas : '{0}'  
 ItemNotFound=Le fichier n'existe pas : '{0}'
 PathNotFound=Le répertoire n'existe pas : '{0}'  
 
 BeginAnalyze=Démarrage de l'analyse du fichier '{0}'
 InitializeComponentNotFound=La méthode InitializeComponent() est introuvable dans le fichier {0}. La conversion ne peut s'effectuer.
 
 DesignerNameNotFound=Vérifiez que le nom du fichier source est bien celui généré par le designer de Visual Studio.
 FormNameNotFound=Le nom de la Form est introuvable dans la méthode InitializeComponent() du fichier '{0}'. La conversion ne peut s'effectuer.{1}  
 TransformationProgress=Transformation du code source ({0}) lignes
 TransformationProgressStatus=Veuillez patienter
 ReadChoiceCaption=Le fichier de destination existe déjà : '{0}'
 ReadChoiceMessage=Voulez-vous le remplacer ?
 OperationCancelled=Opération abandonnée.
 
 GenerateScript=Génération du script '{0}'
 SyntaxVerification=Vérification de la syntaxe du script généré.
 SyntaxError=La syntaxe du script généré contient des erreurs. Pour obtenir le détail des erreurs, exécutez : Test-PSScript '{0}' 
 
 ConversionComplete=Conversion terminée : '{0}' 
 
 ParameterIsExclusif=Utilisez soit le paramètre 'Destination', soit le paramètre 'DestinationLiteral', mais pas les deux en même temps.
 ParameterIsNotAllow=Le paramètre 'Secondary' indique la conversion d'un formulaire secondaire, le paramètre 'HideConsole' ne peut être précisé que lors d'une conversion d'un formulaire primaire.
 AddSTARequirement=Ajout du contrôle du modèle de thread STA. Raison : {0}

 LoadingAssemblies=# Chargement des assemblies externes
 DisposeResources=# Libération des ressources
 DisposeForm=# Libération de la Form 
'@ 


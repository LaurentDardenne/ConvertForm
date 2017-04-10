2014-09-06    Version 2.0.0

  Add xml help FR
  Add exception management
  
  Fix localization
 
  Migration Powershell v1 to v3 and modules refactoring
  

2008-05-03    Version 0.7
  - Corrections :
  - l'imbrication de controls (panel) est possible.
  - de l'analyse autour du mot "Layout", certains événements d'une Winform contiennent ce mot
  - de la reconnaissance de Regex autour des énumérations C#.
  A l'origine on ne prenait en compte que 4 délimiteurs, aujourd'hui on ne tient plus compte
  du nombre de délimiteurs :
  origine :
  [System.Windows.Forms.DialogResult]::Cancel
  correction :
  [System.Drawing.SystemColors]::MenuBar
  [System.Drawing.Forms.MonthCalendar.HitArea]::Vertical
  
  - Ajout :
  - Prise en compte du composant Datagrid et BindingNavigator (fonctions de base)
  - Ajout de la compilation du fichier de ressources d'une Winform (Images BMP,Gif,ico,...).
  - Vérification des chemin d'accès des paramètres
  - Vérification des prérequis (Commande/Scripts/Fonctions)
  - prise en charge des différentes déclarations d'une propriété Font (6 surcharges ):
      C#: this.label1.Font = new System.Drawing.Font("Arial Black", 9.75F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
      PS: $label1.Font = new-object System.Drawing.Font("Arial Black", 9.75,[System.Drawing.FontStyle]::Bold,[System.Drawing.GraphicsUnit]:oint, 0)
  - prise en charge de la déclaration d'un appel de méthode static FromArgb :
      C#: this.CaseàCocher.FlatAppearance.MouseDownBackColor = System.Drawing.Color.FromArgb(((int)(((byte)(192)))), ((int)(((byte)(255)))), ((int)(((byte)(192)))));
      PS: $CaseàCocher.FlatAppearance.MouseDownBackColor = [System.Drawing.Color]::FromArgb(192,255,192)
  - prise en charge des différentes déclarations d'une propriété Anchor
      C# : this.comboBox1.Anchor = ((System.Windows.Forms.AnchorStyles)((((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom)));
      PS : $button1 = [System.Windows.Forms.AnchorStyles]"Bottom,Top"
  - prise en charge des différentes déclarations d'une propriété ShortcutKeys
      C# : this.toolStripMenuItem2.ShortcutKeys = ((System.Windows.Forms.Keys) ((System.Windows.Forms.Keys.Alt | System.Windows.Forms.Keys.A)));
      PS : $toolStripMenuItem2.ShortcutKeys = [System.Windows.Forms.Keys]"Alt,A"
  - prise en charge des propriété de type SizeF (System.Drawing.SizeF(6F, 13F)
  - Contrôle sur la présence du composant System.Windows.Forms.WebBrowser. S'il est présent -> exception
  - Contrôle sur la présence du composant BackgroundWorker. S'il est présent -> avertisssement.
  - de la gestion de tous les événements déclarés
  - par défaut des événements add_actived et FormClosing
  - [switch] $DontLoad. Ne génére pas le code de chargement des assemblies, cas d'une form secondaire.
  
  - Modifications :
  - La gestion des déclarations des propriétés Font, Anchor et ShortcutKeys a nécessité une itération supplémentaire
  sur la totalité des lignes à convertir. Certaines déclarations peuvent être sur 2 ou 3 lignes.
  A l'origine le script partait du principe qu'une suite d'instructions était sur une seule ligne .
  - On utilise des ArrayList au lieu de tableau (redimensionnement possible) et des StringBuilder
  - suite aux remarque de Janel : nom de script normé (Convert-Form), suppression de variables
  temporaires inutiles (nom de fichier en double)

2008-03-29    Version 0.6.2
  - Ajout :
  - [Switch] $Confirm. Informe l'utilisateur que le fichier destination existe déjà.
  - Nouveau script contenant les functions suppémentaires : PackageConvertForm.ps1

2008-02-26    Version 0.6.1
  - Ajout :
  - Function Create-Header pour la création d'un entête de script
  - Function Load-Assembly pour la prise en compte de System.Drawing


2008-02-23    Version 0.6
  - Ajout :
  - Documentation du parsing.
  - Modifications :
  - Simplification des traitements
  - Toutes les traitements 'unique', tel que la suppression de ligne, déclenche l'itération suivante.
  - Renommage des variables de contrôle
  

2008-02-10    Version 0.5
  - Modification :
  - Renommage de variables
  - Ajouts :
  - Contrôle des arguments de la ligne de commande
  - Commentaires
  - Validation de la syntaxe du script généré en fin de traitement
  - Tests de tous les contrôles communs, des menus et barre d'outils (en cours)
  Note: Les lignes ((System.ComponentModel.ISupportInitialize) des dataGridView1 sont dédiés il me semble au datasource.


2008-02-03    Version 0.4  (Laurent Dardenne)
  - Ajout de l'argument -dontshow pour supprimer l'affichage de la form à la fin du script PS1 généré
  - Remplacement de "new XXXXXX[] {" dans le cadre du remplissage d'objets avec des valeurs (type listbox)
  - Traitement des enumerations (format [XXXX.XXXX.XXXX.XXXX]:XXX)
  - Suppression de la déclaration des évenements (à rajouter par développeur)
  - Suppression des ISupportInitialize
  - Remplacement du format de typage des données
  - Remplacement de l'opérateur binaire OR

  
2007-05-11    Version 0.2 
  Original version (Jean-Louis, Robin Lemesle et Arnaud Petitjean)

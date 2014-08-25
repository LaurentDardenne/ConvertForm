using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using System.Globalization;

namespace Test19Localisation
{
    /// <summary>
    /// Tutoriel : Localisation de vos applications .NET avec Visual Studio
    /// Thomas Lebrun http://morpheus.developpez.com/localisationdotnet/
    /// </summary>
    public partial class FrmMain : Form
    {

        private System.Resources.ResourceManager RM = null;

        // Liste des CultureInfo
        private CultureInfo EnglishCulture = new CultureInfo("en-US");
        private CultureInfo FrenchCulture = new CultureInfo("fr-FR");
        
        public FrmMain()
        {
            //
            // Requis pour la prise en charge du Concepteur Windows Forms
            //

            // Définition de la culture par défaut
            //System.Threading.Thread.CurrentThread.CurrentUICulture = FrenchCulture;
            System.Threading.Thread.CurrentThread.CurrentUICulture = EnglishCulture;

            InitializeComponent();
        }


        private void rdbtnFrench_CheckedChanged(object sender, EventArgs e)
        {
            if (rdbtnFrench.Checked)
            {
                System.Threading.Thread.CurrentThread.CurrentUICulture = FrenchCulture;
                
            }
            else
            {
                System.Threading.Thread.CurrentThread.CurrentUICulture = EnglishCulture;
            }
        }

        private void FrmMain_Load(object sender, EventArgs e)
        {
            // LeResourceManager prend en paramètre : nom_du_namespace.nom_de_la_ressource_principale
            RM = new System.Resources.ResourceManager("Test19Localisation.FrmMain", typeof(FrmMain).Assembly);
        }
    }
}

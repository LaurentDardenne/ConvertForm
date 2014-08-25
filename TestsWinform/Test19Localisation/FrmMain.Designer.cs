namespace Test19Localisation
{
    partial class FrmMain
    {
        /// <summary>
        /// Variable nécessaire au concepteur.
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        /// <summary>
        /// Nettoyage des ressources utilisées.
        /// </summary>
        /// <param name="disposing">true si les ressources managées doivent être supprimées ; sinon, false.</param>
        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null))
            {
                components.Dispose();
            }
            base.Dispose(disposing);
        }

        #region Code généré par le Concepteur Windows Form

        /// <summary>
        /// Méthode requise pour la prise en charge du concepteur - ne modifiez pas
        /// le contenu de cette méthode avec l'éditeur de code.
        /// </summary>
        private void InitializeComponent()
        {
            this.components = new System.ComponentModel.Container();
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(FrmMain));
            this.rdbtnFrench = new System.Windows.Forms.RadioButton();
            this.rdbtnEnglish = new System.Windows.Forms.RadioButton();
            this.toolTipFr = new System.Windows.Forms.ToolTip(this.components);
            this.SuspendLayout();
            // 
            // rdbtnFrench
            // 
            this.rdbtnFrench.AccessibleDescription = null;
            this.rdbtnFrench.AccessibleName = null;
            resources.ApplyResources(this.rdbtnFrench, "rdbtnFrench");
            this.rdbtnFrench.BackgroundImage = null;
            this.rdbtnFrench.Font = null;
            this.rdbtnFrench.Name = "rdbtnFrench";
            this.rdbtnFrench.TabStop = true;
            this.toolTipFr.SetToolTip(this.rdbtnFrench, resources.GetString("rdbtnFrench.ToolTip"));
            this.rdbtnFrench.UseVisualStyleBackColor = true;
            this.rdbtnFrench.CheckedChanged += new System.EventHandler(this.rdbtnFrench_CheckedChanged);
            // 
            // rdbtnEnglish
            // 
            this.rdbtnEnglish.AccessibleDescription = null;
            this.rdbtnEnglish.AccessibleName = null;
            resources.ApplyResources(this.rdbtnEnglish, "rdbtnEnglish");
            this.rdbtnEnglish.BackgroundImage = null;
            this.rdbtnEnglish.Font = null;
            this.rdbtnEnglish.Name = "rdbtnEnglish";
            this.rdbtnEnglish.TabStop = true;
            this.toolTipFr.SetToolTip(this.rdbtnEnglish, resources.GetString("rdbtnEnglish.ToolTip"));
            this.rdbtnEnglish.UseVisualStyleBackColor = true;
            // 
            // toolTipFr
            // 
            this.toolTipFr.IsBalloon = true;
            this.toolTipFr.ToolTipIcon = System.Windows.Forms.ToolTipIcon.Info;
            this.toolTipFr.ToolTipTitle = "Information";
            // 
            // FrmMain
            // 
            this.AccessibleDescription = null;
            this.AccessibleName = null;
            resources.ApplyResources(this, "$this");
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.BackgroundImage = null;
            this.Controls.Add(this.rdbtnEnglish);
            this.Controls.Add(this.rdbtnFrench);
            this.Font = null;
            this.Icon = null;
            this.Name = "FrmMain";
            this.toolTipFr.SetToolTip(this, resources.GetString("$this.ToolTip"));
            this.Load += new System.EventHandler(this.FrmMain_Load);
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.RadioButton rdbtnFrench;
        private System.Windows.Forms.RadioButton rdbtnEnglish;
        private System.Windows.Forms.ToolTip toolTipFr;
    }
}


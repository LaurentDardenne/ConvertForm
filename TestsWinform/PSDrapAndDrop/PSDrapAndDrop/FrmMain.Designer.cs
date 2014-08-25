namespace PSDrapAndDrop
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
            this.splitContainer1 = new System.Windows.Forms.SplitContainer();
            this.lstBxGauche = new System.Windows.Forms.ListBox();
            this.lstBxDroite = new System.Windows.Forms.ListBox();
            this.splitContainer1.Panel1.SuspendLayout();
            this.splitContainer1.Panel2.SuspendLayout();
            this.splitContainer1.SuspendLayout();
            this.SuspendLayout();
            // 
            // splitContainer1
            // 
            this.splitContainer1.Dock = System.Windows.Forms.DockStyle.Fill;
            this.splitContainer1.Location = new System.Drawing.Point(0, 0);
            this.splitContainer1.Name = "splitContainer1";
            // 
            // splitContainer1.Panel1
            // 
            this.splitContainer1.Panel1.Controls.Add(this.lstBxGauche);
            // 
            // splitContainer1.Panel2
            // 
            this.splitContainer1.Panel2.Controls.Add(this.lstBxDroite);
            this.splitContainer1.Size = new System.Drawing.Size(904, 266);
            this.splitContainer1.SplitterDistance = 447;
            this.splitContainer1.TabIndex = 0;
            // 
            // lstBxGauche
            // 
            this.lstBxGauche.AllowDrop = true;
            this.lstBxGauche.Dock = System.Windows.Forms.DockStyle.Fill;
            this.lstBxGauche.FormattingEnabled = true;
            this.lstBxGauche.Location = new System.Drawing.Point(0, 0);
            this.lstBxGauche.Name = "lstBxGauche";
            this.lstBxGauche.Size = new System.Drawing.Size(447, 264);
            this.lstBxGauche.TabIndex = 0;
            this.lstBxGauche.DragOver += new System.Windows.Forms.DragEventHandler(this.lstBxGauche_DragOver);
            this.lstBxGauche.DragDrop += new System.Windows.Forms.DragEventHandler(this.lstBxGauche_DragDrop);
            this.lstBxGauche.DragEnter += new System.Windows.Forms.DragEventHandler(this.lstBxGauche_DragEnter);
            // 
            // lstBxDroite
            // 
            this.lstBxDroite.Dock = System.Windows.Forms.DockStyle.Fill;
            this.lstBxDroite.FormattingEnabled = true;
            this.lstBxDroite.Location = new System.Drawing.Point(0, 0);
            this.lstBxDroite.Name = "lstBxDroite";
            this.lstBxDroite.Size = new System.Drawing.Size(453, 264);
            this.lstBxDroite.TabIndex = 0;
            // 
            // FrmMain
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(904, 266);
            this.Controls.Add(this.splitContainer1);
            this.Name = "FrmMain";
            this.Text = "PowerShell - Drag and Drop";
            this.splitContainer1.Panel1.ResumeLayout(false);
            this.splitContainer1.Panel2.ResumeLayout(false);
            this.splitContainer1.ResumeLayout(false);
            this.ResumeLayout(false);

        }

        #endregion

        private System.Windows.Forms.SplitContainer splitContainer1;
        private System.Windows.Forms.ListBox lstBxGauche;
        private System.Windows.Forms.ListBox lstBxDroite;
    }
}


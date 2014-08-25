namespace Test18TreeView
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
            this.pnlBas = new System.Windows.Forms.Panel();
            this.btnClose = new System.Windows.Forms.Button();
            this.treeView = new System.Windows.Forms.TreeView();
            this.btnBranche = new System.Windows.Forms.Button();
            this.btnFeuille = new System.Windows.Forms.Button();
            this.imageList1 = new System.Windows.Forms.ImageList(this.components);
            this.pnlBas.SuspendLayout();
            this.SuspendLayout();
            // 
            // pnlBas
            // 
            this.pnlBas.Controls.Add(this.btnFeuille);
            this.pnlBas.Controls.Add(this.btnBranche);
            this.pnlBas.Controls.Add(this.btnClose);
            this.pnlBas.Dock = System.Windows.Forms.DockStyle.Bottom;
            this.pnlBas.Location = new System.Drawing.Point(0, 276);
            this.pnlBas.Name = "pnlBas";
            this.pnlBas.Size = new System.Drawing.Size(392, 37);
            this.pnlBas.TabIndex = 0;
            // 
            // btnClose
            // 
            this.btnClose.DialogResult = System.Windows.Forms.DialogResult.OK;
            this.btnClose.Location = new System.Drawing.Point(283, 8);
            this.btnClose.Name = "btnClose";
            this.btnClose.Size = new System.Drawing.Size(79, 23);
            this.btnClose.TabIndex = 0;
            this.btnClose.Text = "Fermer";
            this.btnClose.UseVisualStyleBackColor = true;
            // 
            // treeView
            // 
            this.treeView.Dock = System.Windows.Forms.DockStyle.Fill;
            this.treeView.Location = new System.Drawing.Point(0, 0);
            this.treeView.Name = "treeView";
            this.treeView.Size = new System.Drawing.Size(392, 276);
            this.treeView.TabIndex = 1;
            // 
            // btnBranche
            // 
            this.btnBranche.Location = new System.Drawing.Point(157, 8);
            this.btnBranche.Name = "btnBranche";
            this.btnBranche.Size = new System.Drawing.Size(98, 23);
            this.btnBranche.TabIndex = 1;
            this.btnBranche.Text = "Ajout branche";
            this.btnBranche.UseVisualStyleBackColor = true;
            this.btnBranche.Click += new System.EventHandler(this.btnBranche_Click);
            // 
            // btnFeuille
            // 
            this.btnFeuille.Location = new System.Drawing.Point(31, 8);
            this.btnFeuille.Name = "btnFeuille";
            this.btnFeuille.Size = new System.Drawing.Size(91, 23);
            this.btnFeuille.TabIndex = 2;
            this.btnFeuille.Text = "Ajout feuille";
            this.btnFeuille.UseVisualStyleBackColor = true;
            this.btnFeuille.Click += new System.EventHandler(this.btnFeuille_Click);
            // 
            // imageList1
            // 
            this.imageList1.ImageStream = ((System.Windows.Forms.ImageListStreamer)(resources.GetObject("imageList1.ImageStream")));
            this.imageList1.TransparentColor = System.Drawing.Color.Transparent;
            this.imageList1.Images.SetKeyName(0, "116.png");
            this.imageList1.Images.SetKeyName(1, "95.png");
            this.imageList1.Images.SetKeyName(2, "101.png");
            // 
            // FrmMain
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(392, 313);
            this.Controls.Add(this.treeView);
            this.Controls.Add(this.pnlBas);
            this.Name = "FrmMain";
            this.Text = "Demo TreeView";
            this.Load += new System.EventHandler(this.FrmMain_Load);
            this.pnlBas.ResumeLayout(false);
            this.ResumeLayout(false);

        }

        #endregion

        private System.Windows.Forms.Panel pnlBas;
        private System.Windows.Forms.Button btnClose;
        private System.Windows.Forms.TreeView treeView;
        private System.Windows.Forms.Button btnFeuille;
        private System.Windows.Forms.Button btnBranche;
        private System.Windows.Forms.ImageList imageList1;
    }
}


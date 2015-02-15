namespace DemoTreeView
{
    partial class FrmTreeView
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
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(FrmTreeView));
            this.pnlFill = new System.Windows.Forms.Panel();
            this.treeDirectories = new System.Windows.Forms.TreeView();
            this.pnlBottom = new System.Windows.Forms.Panel();
            this.btnClose = new System.Windows.Forms.Button();
            this.imgLstExplorer = new System.Windows.Forms.ImageList(this.components);
            this.pnlFill.SuspendLayout();
            this.pnlBottom.SuspendLayout();
            this.SuspendLayout();
            // 
            // pnlFill
            // 
            this.pnlFill.Controls.Add(this.treeDirectories);
            this.pnlFill.Dock = System.Windows.Forms.DockStyle.Fill;
            this.pnlFill.Location = new System.Drawing.Point(0, 0);
            this.pnlFill.Name = "pnlFill";
            this.pnlFill.Size = new System.Drawing.Size(498, 421);
            this.pnlFill.TabIndex = 0;
            // 
            // treeDirectories
            // 
            this.treeDirectories.CheckBoxes = true;
            this.treeDirectories.Dock = System.Windows.Forms.DockStyle.Fill;
            this.treeDirectories.ImageIndex = 0;
            this.treeDirectories.ImageList = this.imgLstExplorer;
            this.treeDirectories.Location = new System.Drawing.Point(0, 0);
            this.treeDirectories.Name = "treeDirectories";
            this.treeDirectories.SelectedImageIndex = 0;
            this.treeDirectories.Size = new System.Drawing.Size(498, 421);
            this.treeDirectories.TabIndex = 0;
            this.treeDirectories.NodeMouseClick += new System.Windows.Forms.TreeNodeMouseClickEventHandler(this.treeDirectories_NodeMouseClick);
            this.treeDirectories.NodeMouseDoubleClick += new System.Windows.Forms.TreeNodeMouseClickEventHandler(this.treeDirectories_NodeMouseDoubleClick);
            // 
            // pnlBottom
            // 
            this.pnlBottom.Controls.Add(this.btnClose);
            this.pnlBottom.Dock = System.Windows.Forms.DockStyle.Bottom;
            this.pnlBottom.Location = new System.Drawing.Point(0, 382);
            this.pnlBottom.Name = "pnlBottom";
            this.pnlBottom.Size = new System.Drawing.Size(498, 39);
            this.pnlBottom.TabIndex = 1;
            // 
            // btnClose
            // 
            this.btnClose.Location = new System.Drawing.Point(392, 4);
            this.btnClose.Name = "btnClose";
            this.btnClose.Size = new System.Drawing.Size(75, 23);
            this.btnClose.TabIndex = 0;
            this.btnClose.Text = "Close";
            this.btnClose.UseVisualStyleBackColor = true;
            this.btnClose.Click += new System.EventHandler(this.btnClose_Click);
            // 
            // imgLstExplorer
            // 
            this.imgLstExplorer.ImageStream = ((System.Windows.Forms.ImageListStreamer)(resources.GetObject("imgLstExplorer.ImageStream")));
            this.imgLstExplorer.TransparentColor = System.Drawing.Color.Transparent;
            this.imgLstExplorer.Images.SetKeyName(0, "File.ico");
            this.imgLstExplorer.Images.SetKeyName(1, "Directory.ico");
            // 
            // FrmTreeView
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(498, 421);
            this.Controls.Add(this.pnlBottom);
            this.Controls.Add(this.pnlFill);
            this.Name = "FrmTreeView";
            this.StartPosition = System.Windows.Forms.FormStartPosition.CenterScreen;
            this.Text = "Demo Treeview";
            this.pnlFill.ResumeLayout(false);
            this.pnlBottom.ResumeLayout(false);
            this.ResumeLayout(false);

        }

        #endregion

        private System.Windows.Forms.Panel pnlFill;
        private System.Windows.Forms.Panel pnlBottom;
        private System.Windows.Forms.TreeView treeDirectories;
        private System.Windows.Forms.Button btnClose;
        private System.Windows.Forms.ImageList imgLstExplorer;
    }
}


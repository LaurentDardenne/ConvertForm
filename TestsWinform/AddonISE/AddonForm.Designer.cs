namespace AddonISE
{
    partial class AddonFrm
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
            this.pnlBackground = new System.Windows.Forms.Panel();
            this.splitContainer = new System.Windows.Forms.SplitContainer();
            this.lstbxModules = new System.Windows.Forms.ListBox();
            this.lstbxErrors = new System.Windows.Forms.ListBox();
            this.toolTip1 = new System.Windows.Forms.ToolTip(this.components);
            this.btnExecute = new System.Windows.Forms.Button();
            this.btnInsert = new System.Windows.Forms.Button();
            this.pnlBottom = new System.Windows.Forms.Panel();
            this.btnCancel = new System.Windows.Forms.Button();
            this.pnlBackground.SuspendLayout();
            this.splitContainer.Panel1.SuspendLayout();
            this.splitContainer.Panel2.SuspendLayout();
            this.splitContainer.SuspendLayout();
            this.pnlBottom.SuspendLayout();
            this.SuspendLayout();
            // 
            // pnlBackground
            // 
            this.pnlBackground.Controls.Add(this.splitContainer);
            this.pnlBackground.Dock = System.Windows.Forms.DockStyle.Fill;
            this.pnlBackground.Location = new System.Drawing.Point(0, 0);
            this.pnlBackground.Name = "pnlBackground";
            this.pnlBackground.Size = new System.Drawing.Size(414, 310);
            this.pnlBackground.TabIndex = 0;
            // 
            // splitContainer
            // 
            this.splitContainer.Cursor = System.Windows.Forms.Cursors.Default;
            this.splitContainer.Dock = System.Windows.Forms.DockStyle.Fill;
            this.splitContainer.Location = new System.Drawing.Point(0, 0);
            this.splitContainer.Name = "splitContainer";
            this.splitContainer.Orientation = System.Windows.Forms.Orientation.Horizontal;
            // 
            // splitContainer.Panel1
            // 
            this.splitContainer.Panel1.Controls.Add(this.lstbxModules);
            // 
            // splitContainer.Panel2
            // 
            this.splitContainer.Panel2.Controls.Add(this.lstbxErrors);
            this.splitContainer.Size = new System.Drawing.Size(414, 310);
            this.splitContainer.SplitterDistance = 117;
            this.splitContainer.TabIndex = 0;
            // 
            // lstbxModules
            // 
            this.lstbxModules.Dock = System.Windows.Forms.DockStyle.Fill;
            this.lstbxModules.FormattingEnabled = true;
            this.lstbxModules.Location = new System.Drawing.Point(0, 0);
            this.lstbxModules.Name = "lstbxModules";
            this.lstbxModules.Size = new System.Drawing.Size(414, 117);
            this.lstbxModules.TabIndex = 0;
            this.toolTip1.SetToolTip(this.lstbxModules, "module dependent commands");
            // 
            // lstbxErrors
            // 
            this.lstbxErrors.Cursor = System.Windows.Forms.Cursors.Default;
            this.lstbxErrors.Dock = System.Windows.Forms.DockStyle.Fill;
            this.lstbxErrors.FormattingEnabled = true;
            this.lstbxErrors.Location = new System.Drawing.Point(0, 0);
            this.lstbxErrors.Name = "lstbxErrors";
            this.lstbxErrors.Size = new System.Drawing.Size(414, 189);
            this.lstbxErrors.TabIndex = 0;
            this.toolTip1.SetToolTip(this.lstbxErrors, "Errors list.");
            // 
            // btnExecute
            // 
            this.btnExecute.Location = new System.Drawing.Point(25, 15);
            this.btnExecute.Name = "btnExecute";
            this.btnExecute.Size = new System.Drawing.Size(75, 23);
            this.btnExecute.TabIndex = 0;
            this.btnExecute.Text = "Execute";
            this.toolTip1.SetToolTip(this.btnExecute, "Search the dependenies modules");
            this.btnExecute.UseVisualStyleBackColor = true;
            this.btnExecute.Click += new System.EventHandler(this.btnExecute_Click);
            // 
            // btnInsert
            // 
            this.btnInsert.DialogResult = System.Windows.Forms.DialogResult.OK;
            this.btnInsert.Enabled = false;
            this.btnInsert.Location = new System.Drawing.Point(157, 15);
            this.btnInsert.Name = "btnInsert";
            this.btnInsert.Size = new System.Drawing.Size(75, 23);
            this.btnInsert.TabIndex = 1;
            this.btnInsert.Text = "Insert";
            this.toolTip1.SetToolTip(this.btnInsert, "Insert dependencies in the current  tab");
            this.btnInsert.UseVisualStyleBackColor = true;
            this.btnInsert.Click += new System.EventHandler(this.btnInsert_Click);
            // 
            // pnlBottom
            // 
            this.pnlBottom.Controls.Add(this.btnCancel);
            this.pnlBottom.Controls.Add(this.btnInsert);
            this.pnlBottom.Controls.Add(this.btnExecute);
            this.pnlBottom.Dock = System.Windows.Forms.DockStyle.Bottom;
            this.pnlBottom.Location = new System.Drawing.Point(0, 254);
            this.pnlBottom.Name = "pnlBottom";
            this.pnlBottom.Size = new System.Drawing.Size(414, 56);
            this.pnlBottom.TabIndex = 1;
            // 
            // btnCancel
            // 
            this.btnCancel.DialogResult = System.Windows.Forms.DialogResult.Cancel;
            this.btnCancel.Location = new System.Drawing.Point(303, 15);
            this.btnCancel.Name = "btnCancel";
            this.btnCancel.Size = new System.Drawing.Size(75, 23);
            this.btnCancel.TabIndex = 2;
            this.btnCancel.Text = "Cancel";
            this.btnCancel.UseVisualStyleBackColor = true;
            this.btnCancel.Click += new System.EventHandler(this.btnCancel_Click);
            // 
            // AddonFrm
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(414, 310);
            this.Controls.Add(this.pnlBottom);
            this.Controls.Add(this.pnlBackground);
            this.MinimumSize = new System.Drawing.Size(430, 348);
            this.Name = "AddonFrm";
            this.Text = "Addon dependencies";
            this.toolTip1.SetToolTip(this, "Retrieve dependencies of a script");
            this.FormClosed += new System.Windows.Forms.FormClosedEventHandler(this.AddonFrm_FormClosed);
            this.Load += new System.EventHandler(this.AddonFrm_Load);
            this.Shown += new System.EventHandler(this.AddonFrm_Shown);
            this.pnlBackground.ResumeLayout(false);
            this.splitContainer.Panel1.ResumeLayout(false);
            this.splitContainer.Panel2.ResumeLayout(false);
            this.splitContainer.ResumeLayout(false);
            this.pnlBottom.ResumeLayout(false);
            this.ResumeLayout(false);

        }

        #endregion

        private System.Windows.Forms.Panel pnlBackground;
        private System.Windows.Forms.SplitContainer splitContainer;
        private System.Windows.Forms.ListBox lstbxModules;
        private System.Windows.Forms.ListBox lstbxErrors;
        private System.Windows.Forms.ToolTip toolTip1;
        private System.Windows.Forms.Panel pnlBottom;
        private System.Windows.Forms.Button btnCancel;
        private System.Windows.Forms.Button btnInsert;
        private System.Windows.Forms.Button btnExecute;

    }
}


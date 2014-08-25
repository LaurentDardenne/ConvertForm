namespace Test5Panel
{
    partial class FrmTest5Panel
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
            this.PanelMainFill = new System.Windows.Forms.Panel();
            this.panelTop = new System.Windows.Forms.Panel();
            this.panelBottom = new System.Windows.Forms.Panel();
            this.panelCenterFill = new System.Windows.Forms.Panel();
            this.PanelMainFill.SuspendLayout();
            this.SuspendLayout();
            // 
            // PanelMainFill
            // 
            this.PanelMainFill.Controls.Add(this.panelCenterFill);
            this.PanelMainFill.Controls.Add(this.panelBottom);
            this.PanelMainFill.Controls.Add(this.panelTop);
            this.PanelMainFill.Dock = System.Windows.Forms.DockStyle.Fill;
            this.PanelMainFill.Location = new System.Drawing.Point(0, 0);
            this.PanelMainFill.Name = "PanelMainFill";
            this.PanelMainFill.Size = new System.Drawing.Size(485, 296);
            this.PanelMainFill.TabIndex = 0;
            // 
            // panelTop
            // 
            this.panelTop.BackColor = System.Drawing.SystemColors.ControlDarkDark;
            this.panelTop.Dock = System.Windows.Forms.DockStyle.Top;
            this.panelTop.Location = new System.Drawing.Point(0, 0);
            this.panelTop.Name = "panelTop";
            this.panelTop.Size = new System.Drawing.Size(485, 123);
            this.panelTop.TabIndex = 0;
            // 
            // panelBottom
            // 
            this.panelBottom.BackColor = System.Drawing.SystemColors.Info;
            this.panelBottom.Dock = System.Windows.Forms.DockStyle.Bottom;
            this.panelBottom.Location = new System.Drawing.Point(0, 166);
            this.panelBottom.Name = "panelBottom";
            this.panelBottom.Size = new System.Drawing.Size(485, 130);
            this.panelBottom.TabIndex = 1;
            // 
            // panelCenterFill
            // 
            this.panelCenterFill.BackColor = System.Drawing.SystemColors.ActiveCaption;
            this.panelCenterFill.Dock = System.Windows.Forms.DockStyle.Fill;
            this.panelCenterFill.Location = new System.Drawing.Point(0, 123);
            this.panelCenterFill.Name = "panelCenterFill";
            this.panelCenterFill.Size = new System.Drawing.Size(485, 43);
            this.panelCenterFill.TabIndex = 2;
            // 
            // Form1
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(485, 296);
            this.Controls.Add(this.PanelMainFill);
            this.Name = "Form1";
            this.Text = "Form1";
            this.PanelMainFill.ResumeLayout(false);
            this.ResumeLayout(false);

        }

        #endregion

        private System.Windows.Forms.Panel PanelMainFill;
        private System.Windows.Forms.Panel panelCenterFill;
        private System.Windows.Forms.Panel panelBottom;
        private System.Windows.Forms.Panel panelTop;
    }
}


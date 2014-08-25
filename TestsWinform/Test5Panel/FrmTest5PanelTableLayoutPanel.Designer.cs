namespace Test5Panel
{
    partial class FrmTest5PanelTableLayoutPanel
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
            this.tableLayoutPanelFill = new System.Windows.Forms.TableLayoutPanel();
            this.panelBottom = new System.Windows.Forms.Panel();
            this.PanelMainFill.SuspendLayout();
            this.SuspendLayout();
            // 
            // PanelMainFill
            // 
            this.PanelMainFill.Controls.Add(this.tableLayoutPanelFill);
            this.PanelMainFill.Controls.Add(this.panelBottom);
            this.PanelMainFill.Dock = System.Windows.Forms.DockStyle.Fill;
            this.PanelMainFill.Location = new System.Drawing.Point(0, 0);
            this.PanelMainFill.Name = "PanelMainFill";
            this.PanelMainFill.Size = new System.Drawing.Size(292, 266);
            this.PanelMainFill.TabIndex = 1;
            // 
            // tableLayoutPanelFill
            // 
            this.tableLayoutPanelFill.ColumnCount = 2;
            this.tableLayoutPanelFill.ColumnStyles.Add(new System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType.Percent, 50F));
            this.tableLayoutPanelFill.ColumnStyles.Add(new System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType.Percent, 50F));
            this.tableLayoutPanelFill.Dock = System.Windows.Forms.DockStyle.Fill;
            this.tableLayoutPanelFill.Location = new System.Drawing.Point(0, 0);
            this.tableLayoutPanelFill.Name = "tableLayoutPanelFill";
            this.tableLayoutPanelFill.RowCount = 2;
            this.tableLayoutPanelFill.RowStyles.Add(new System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType.Percent, 50F));
            this.tableLayoutPanelFill.RowStyles.Add(new System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType.Percent, 50F));
            this.tableLayoutPanelFill.Size = new System.Drawing.Size(292, 136);
            this.tableLayoutPanelFill.TabIndex = 2;
            // 
            // panelBottom
            // 
            this.panelBottom.BackColor = System.Drawing.SystemColors.Info;
            this.panelBottom.Dock = System.Windows.Forms.DockStyle.Bottom;
            this.panelBottom.Location = new System.Drawing.Point(0, 136);
            this.panelBottom.Name = "panelBottom";
            this.panelBottom.Size = new System.Drawing.Size(292, 130);
            this.panelBottom.TabIndex = 1;
            // 
            // FrmTableLayoutPanel
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(292, 266);
            this.Controls.Add(this.PanelMainFill);
            this.Name = "FrmTableLayoutPanel";
            this.Text = "FrmTableLayoutPanel";
            this.PanelMainFill.ResumeLayout(false);
            this.ResumeLayout(false);

        }

        #endregion

        private System.Windows.Forms.Panel PanelMainFill;
        private System.Windows.Forms.TableLayoutPanel tableLayoutPanelFill;
        private System.Windows.Forms.Panel panelBottom;
    }
}
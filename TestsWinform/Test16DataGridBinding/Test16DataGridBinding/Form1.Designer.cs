namespace Test16DataGridBinding
{
    partial class Form1
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
            this.pnlHaut = new System.Windows.Forms.Panel();
            this.dtGrdVw = new System.Windows.Forms.DataGridView();
            this.pnlBas = new System.Windows.Forms.Panel();
            this.btnQuitter = new System.Windows.Forms.Button();
            this.pnlHaut.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.dtGrdVw)).BeginInit();
            this.pnlBas.SuspendLayout();
            this.SuspendLayout();
            // 
            // pnlHaut
            // 
            this.pnlHaut.Controls.Add(this.dtGrdVw);
            this.pnlHaut.Dock = System.Windows.Forms.DockStyle.Fill;
            this.pnlHaut.Location = new System.Drawing.Point(0, 0);
            this.pnlHaut.Name = "pnlHaut";
            this.pnlHaut.Size = new System.Drawing.Size(559, 266);
            this.pnlHaut.TabIndex = 0;
            // 
            // dtGrdVw
            // 
            this.dtGrdVw.ColumnHeadersHeightSizeMode = System.Windows.Forms.DataGridViewColumnHeadersHeightSizeMode.AutoSize;
            this.dtGrdVw.Dock = System.Windows.Forms.DockStyle.Fill;
            this.dtGrdVw.Location = new System.Drawing.Point(0, 0);
            this.dtGrdVw.MultiSelect = false;
            this.dtGrdVw.Name = "dtGrdVw";
            this.dtGrdVw.ReadOnly = true;
            this.dtGrdVw.RowHeadersVisible = false;
            this.dtGrdVw.RowTemplate.ReadOnly = true;
            this.dtGrdVw.RowTemplate.Resizable = System.Windows.Forms.DataGridViewTriState.True;
            this.dtGrdVw.Size = new System.Drawing.Size(559, 266);
            this.dtGrdVw.TabIndex = 0;
            this.dtGrdVw.BindingContextChanged += new System.EventHandler(this.dtGrdVw_BindingContextChanged);
            this.dtGrdVw.CellDoubleClick += new System.Windows.Forms.DataGridViewCellEventHandler(this.dtGrdVw_CellDoubleClick);
            this.dtGrdVw.DataMemberChanged += new System.EventHandler(this.dtGrdVw_DataMemberChanged);
            this.dtGrdVw.DataBindingComplete += new System.Windows.Forms.DataGridViewBindingCompleteEventHandler(this.dtGrdVw_DataBindingComplete);
            this.dtGrdVw.DataSourceChanged += new System.EventHandler(this.dtGrdVw_DataSourceChanged);
            // 
            // pnlBas
            // 
            this.pnlBas.Controls.Add(this.btnQuitter);
            this.pnlBas.Dock = System.Windows.Forms.DockStyle.Bottom;
            this.pnlBas.Location = new System.Drawing.Point(0, 221);
            this.pnlBas.Name = "pnlBas";
            this.pnlBas.Size = new System.Drawing.Size(559, 45);
            this.pnlBas.TabIndex = 1;
            // 
            // btnQuitter
            // 
            this.btnQuitter.Location = new System.Drawing.Point(445, 10);
            this.btnQuitter.Name = "btnQuitter";
            this.btnQuitter.Size = new System.Drawing.Size(75, 23);
            this.btnQuitter.TabIndex = 0;
            this.btnQuitter.Text = "Quitter";
            this.btnQuitter.UseVisualStyleBackColor = true;
            this.btnQuitter.Click += new System.EventHandler(this.btnQuitter_Click);
            // 
            // Form1
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(559, 266);
            this.Controls.Add(this.pnlBas);
            this.Controls.Add(this.pnlHaut);
            this.Name = "Form1";
            this.Text = "Test Binding";
            this.pnlHaut.ResumeLayout(false);
            ((System.ComponentModel.ISupportInitialize)(this.dtGrdVw)).EndInit();
            this.pnlBas.ResumeLayout(false);
            this.ResumeLayout(false);

        }

        #endregion

        private System.Windows.Forms.Panel pnlHaut;
        private System.Windows.Forms.DataGridView dtGrdVw;
        private System.Windows.Forms.Panel pnlBas;
        private System.Windows.Forms.Button btnQuitter;
    }
}


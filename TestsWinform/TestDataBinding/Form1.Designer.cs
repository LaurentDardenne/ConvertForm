namespace TestDataBinding
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
            this.pnlBas = new System.Windows.Forms.Panel();
            this.BtnClose = new System.Windows.Forms.Button();
            this.BtnAddItem = new System.Windows.Forms.Button();
            this.lstBoxObjects = new System.Windows.Forms.ListBox();
            this.pnlHaut.SuspendLayout();
            this.pnlBas.SuspendLayout();
            this.SuspendLayout();
            // 
            // pnlHaut
            // 
            this.pnlHaut.Controls.Add(this.lstBoxObjects);
            this.pnlHaut.Dock = System.Windows.Forms.DockStyle.Fill;
            this.pnlHaut.Location = new System.Drawing.Point(0, 0);
            this.pnlHaut.Name = "pnlHaut";
            this.pnlHaut.Size = new System.Drawing.Size(566, 329);
            this.pnlHaut.TabIndex = 0;
            // 
            // pnlBas
            // 
            this.pnlBas.Controls.Add(this.BtnAddItem);
            this.pnlBas.Controls.Add(this.BtnClose);
            this.pnlBas.Dock = System.Windows.Forms.DockStyle.Bottom;
            this.pnlBas.Location = new System.Drawing.Point(0, 265);
            this.pnlBas.Name = "pnlBas";
            this.pnlBas.Size = new System.Drawing.Size(566, 64);
            this.pnlBas.TabIndex = 1;
            // 
            // BtnClose
            // 
            this.BtnClose.Location = new System.Drawing.Point(464, 29);
            this.BtnClose.Name = "BtnClose";
            this.BtnClose.Size = new System.Drawing.Size(75, 23);
            this.BtnClose.TabIndex = 0;
            this.BtnClose.Text = "Close";
            this.BtnClose.UseVisualStyleBackColor = true;
            this.BtnClose.Click += new System.EventHandler(this.BtnClose_Click);
            // 
            // BtnAddItem
            // 
            this.BtnAddItem.Location = new System.Drawing.Point(334, 29);
            this.BtnAddItem.Name = "BtnAddItem";
            this.BtnAddItem.Size = new System.Drawing.Size(83, 23);
            this.BtnAddItem.TabIndex = 1;
            this.BtnAddItem.Text = "Add item";
            this.BtnAddItem.UseVisualStyleBackColor = true;
            this.BtnAddItem.Click += new System.EventHandler(this.BtnAddItem_Click);
            // 
            // lstBoxObjects
            // 
            this.lstBoxObjects.Dock = System.Windows.Forms.DockStyle.Fill;
            this.lstBoxObjects.FormattingEnabled = true;
            this.lstBoxObjects.Location = new System.Drawing.Point(0, 0);
            this.lstBoxObjects.Name = "lstBoxObjects";
            this.lstBoxObjects.Size = new System.Drawing.Size(566, 329);
            this.lstBoxObjects.TabIndex = 0;
            // 
            // Form1
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(566, 329);
            this.Controls.Add(this.pnlBas);
            this.Controls.Add(this.pnlHaut);
            this.Name = "Form1";
            this.Text = "Test DataBinding";
            this.pnlHaut.ResumeLayout(false);
            this.pnlBas.ResumeLayout(false);
            this.ResumeLayout(false);

        }

        #endregion

        private System.Windows.Forms.Panel pnlHaut;
        private System.Windows.Forms.Panel pnlBas;
        private System.Windows.Forms.Button BtnAddItem;
        private System.Windows.Forms.Button BtnClose;
        private System.Windows.Forms.ListBox lstBoxObjects;
    }
}


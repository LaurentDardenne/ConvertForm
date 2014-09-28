namespace AddonISE
{
    partial class SelectModuleFrm
    {
        /// <summary>
        /// Required designer variable.
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        /// <summary>
        /// Clean up any resources being used.
        /// </summary>
        /// <param name="disposing">true if managed resources should be disposed; otherwise, false.</param>
        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null))
            {
                components.Dispose();
            }
            base.Dispose(disposing);
        }

        #region Windows Form Designer generated code

        /// <summary>
        /// Required method for Designer support - do not modify
        /// the contents of this method with the code editor.
        /// </summary>
        private void InitializeComponent()
        {
            this.lstbxModulesName = new System.Windows.Forms.ListBox();
            this.SuspendLayout();
            // 
            // lstbxModulesName
            // 
            this.lstbxModulesName.Dock = System.Windows.Forms.DockStyle.Fill;
            this.lstbxModulesName.FormattingEnabled = true;
            this.lstbxModulesName.Location = new System.Drawing.Point(0, 0);
            this.lstbxModulesName.Name = "lstbxModulesName";
            this.lstbxModulesName.Size = new System.Drawing.Size(345, 130);
            this.lstbxModulesName.TabIndex = 0;
            this.lstbxModulesName.DoubleClick += new System.EventHandler(this.lstbxModulesName_DoubleClick);
            // 
            // SelectModuleFrm
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(345, 130);
            this.Controls.Add(this.lstbxModulesName);
            this.Name = "SelectModuleFrm";
            this.Text = "SelectModuleFrm";
            this.ResumeLayout(false);

        }

        #endregion

        private System.Windows.Forms.ListBox lstbxModulesName;
    }
}
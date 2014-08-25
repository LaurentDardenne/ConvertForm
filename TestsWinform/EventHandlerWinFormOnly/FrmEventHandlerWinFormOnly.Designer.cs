namespace EventHandlerWinFormOnly
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
            this.label1 = new System.Windows.Forms.Label();
            this.SuspendLayout();
            // 
            // label1
            // 
            this.label1.AutoSize = true;
            this.label1.Location = new System.Drawing.Point(46, 56);
            this.label1.Name = "label1";
            this.label1.Size = new System.Drawing.Size(379, 13);
            this.label1.TabIndex = 0;
            this.label1.Text = "Ne pas exécuter cette fenêtre. Sinon les events vide sont supprimés par le lieur";
            this.label1.AutoSizeChanged += new System.EventHandler(this.Form1_Activated);
            this.label1.BackColorChanged += new System.EventHandler(this.Form1_BackColorChanged);
            // 
            // Form1
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(549, 266);
            this.Controls.Add(this.label1);
            this.Name = "Form1";
            this.Text = "Form1";
            this.CursorChanged += new System.EventHandler(this.Form1_CursorChanged);
            this.StyleChanged += new System.EventHandler(this.Form1_StyleChanged);
            this.RightToLeftLayoutChanged += new System.EventHandler(this.Form1_RightToLeftLayoutChanged);
            this.MinimumSizeChanged += new System.EventHandler(this.Form1_MinimumSizeChanged);
            this.Deactivate += new System.EventHandler(this.Form1_Deactivate);
            this.Load += new System.EventHandler(this.Form1_Load);
            this.BackgroundImageLayoutChanged += new System.EventHandler(this.Form1_BackgroundImageLayoutChanged);
            this.RightToLeftChanged += new System.EventHandler(this.Form1_RightToLeftChanged);
            this.RegionChanged += new System.EventHandler(this.Form1_RegionChanged);
            this.InputLanguageChanged += new System.Windows.Forms.InputLanguageChangedEventHandler(this.Form1_InputLanguageChanged);
            this.ResizeBegin += new System.EventHandler(this.Form1_ResizeBegin);
            this.MouseUp += new System.Windows.Forms.MouseEventHandler(this.Form1_MouseUp);
            this.MouseDoubleClick += new System.Windows.Forms.MouseEventHandler(this.Form1_MouseDoubleClick);
            this.ControlAdded += new System.Windows.Forms.ControlEventHandler(this.Form1_ControlAdded);
            this.ClientSizeChanged += new System.EventHandler(this.Form1_ClientSizeChanged);
            this.MaximizedBoundsChanged += new System.EventHandler(this.Form1_MaximizedBoundsChanged);
            this.AutoSizeChanged += new System.EventHandler(this.Form1_AutoSizeChanged);
            this.HelpButtonClicked += new System.ComponentModel.CancelEventHandler(this.Form1_HelpButtonClicked);
            this.BindingContextChanged += new System.EventHandler(this.Form1_BindingContextChanged);
            this.Paint += new System.Windows.Forms.PaintEventHandler(this.Form1_Paint);
            this.EnabledChanged += new System.EventHandler(this.Form1_EnabledChanged);
            this.ContextMenuStripChanged += new System.EventHandler(this.Form1_ContextMenuStripChanged);
            this.Scroll += new System.Windows.Forms.ScrollEventHandler(this.Form1_Scroll);
            this.MouseClick += new System.Windows.Forms.MouseEventHandler(this.Form1_MouseClick);
            this.SizeChanged += new System.EventHandler(this.Form1_SizeChanged);
            this.DragLeave += new System.EventHandler(this.Form1_DragLeave);
            this.ParentChanged += new System.EventHandler(this.Form1_ParentChanged);
            this.MouseCaptureChanged += new System.EventHandler(this.Form1_MouseCaptureChanged);
            this.ControlRemoved += new System.Windows.Forms.ControlEventHandler(this.Form1_ControlRemoved);
            this.Shown += new System.EventHandler(this.Form1_Shown);
            this.MouseEnter += new System.EventHandler(this.Form1_MouseEnter);
            this.AutoValidateChanged += new System.EventHandler(this.Form1_AutoValidateChanged);
            this.ChangeUICues += new System.Windows.Forms.UICuesEventHandler(this.Form1_ChangeUICues);
            this.DoubleClick += new System.EventHandler(this.Form1_DoubleClick);
            this.Activated += new System.EventHandler(this.Form1_Activated);
            this.Enter += new System.EventHandler(this.Form1_Enter);
            this.Layout += new System.Windows.Forms.LayoutEventHandler(this.Form1_Layout);
            this.VisibleChanged += new System.EventHandler(this.Form1_VisibleChanged);
            this.ForeColorChanged += new System.EventHandler(this.Form1_ForeColorChanged);
            this.DragDrop += new System.Windows.Forms.DragEventHandler(this.Form1_DragDrop);
            this.FormClosed += new System.Windows.Forms.FormClosedEventHandler(this.Form1_FormClosed);
            this.MdiChildActivate += new System.EventHandler(this.Form1_MdiChildActivate);
            this.Leave += new System.EventHandler(this.Form1_Leave);
            this.Click += new System.EventHandler(this.Form1_Click);
            this.MouseDown += new System.Windows.Forms.MouseEventHandler(this.Form1_MouseDown);
            this.DragEnter += new System.Windows.Forms.DragEventHandler(this.Form1_DragEnter);
            this.PaddingChanged += new System.EventHandler(this.Form1_PaddingChanged);
            this.KeyPress += new System.Windows.Forms.KeyPressEventHandler(this.Form1_KeyPress);
            this.MouseLeave += new System.EventHandler(this.Form1_MouseLeave);
            this.Validating += new System.ComponentModel.CancelEventHandler(this.Form1_Validating);
            this.DockChanged += new System.EventHandler(this.Form1_DockChanged);
            this.KeyUp += new System.Windows.Forms.KeyEventHandler(this.Form1_KeyUp);
            this.Move += new System.EventHandler(this.Form1_Move);
            this.GiveFeedback += new System.Windows.Forms.GiveFeedbackEventHandler(this.Form1_GiveFeedback);
            this.ImeModeChanged += new System.EventHandler(this.Form1_ImeModeChanged);
            this.QueryContinueDrag += new System.Windows.Forms.QueryContinueDragEventHandler(this.Form1_QueryContinueDrag);
            this.SystemColorsChanged += new System.EventHandler(this.Form1_SystemColorsChanged);
            this.QueryAccessibilityHelp += new System.Windows.Forms.QueryAccessibilityHelpEventHandler(this.Form1_QueryAccessibilityHelp);
            this.FormClosing += new System.Windows.Forms.FormClosingEventHandler(this.Form1_FormClosing);
            this.Resize += new System.EventHandler(this.Form1_Resize);
            this.Validated += new System.EventHandler(this.Form1_Validated);
            this.BackgroundImageChanged += new System.EventHandler(this.Form1_BackgroundImageChanged);
            this.MouseMove += new System.Windows.Forms.MouseEventHandler(this.Form1_MouseMove);
            this.HelpRequested += new System.Windows.Forms.HelpEventHandler(this.Form1_HelpRequested);
            this.LocationChanged += new System.EventHandler(this.Form1_LocationChanged);
            this.PreviewKeyDown += new System.Windows.Forms.PreviewKeyDownEventHandler(this.Form1_PreviewKeyDown);
            this.KeyDown += new System.Windows.Forms.KeyEventHandler(this.Form1_KeyDown);
            this.BackColorChanged += new System.EventHandler(this.Form1_BackColorChanged);
            this.InputLanguageChanging += new System.Windows.Forms.InputLanguageChangingEventHandler(this.Form1_InputLanguageChanging);
            this.MouseHover += new System.EventHandler(this.Form1_MouseHover);
            this.ResizeEnd += new System.EventHandler(this.Form1_ResizeEnd);
            this.FontChanged += new System.EventHandler(this.Form1_FontChanged);
            this.DragOver += new System.Windows.Forms.DragEventHandler(this.Form1_DragOver);
            this.TextChanged += new System.EventHandler(this.Form1_TextChanged);
            this.CausesValidationChanged += new System.EventHandler(this.Form1_CausesValidationChanged);
            this.MaximumSizeChanged += new System.EventHandler(this.Form1_MaximumSizeChanged);
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.Label label1;
    }
}


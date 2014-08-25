using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Text;
using System.Windows.Forms;

namespace TestErrorProvider
{
    public partial class Form1 : Form
    {
        public Form1()
        {
            InitializeComponent();
        }

        private void TxtBox1_Validating(object sender, CancelEventArgs e)
        {
            try
            {
                int x = Int32.Parse(TxtBoxSaisirNombre.Text);
            }
            catch(FormatException ex) 

            {
                errorProvider1.SetError(TxtBoxSaisirNombre, "N'est pas une valeur entière.");
            }

        }

        private void button1_Click(object sender, EventArgs e)
        {
            Close();
        }

        private void TxtBoxSaisirNombre_Enter(object sender, EventArgs e)
        {
            errorProvider1.SetError(TxtBoxSaisirNombre, "");
        }
    }
}
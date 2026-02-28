namespace ProbMenu;

public partial class Form1 : Form
{
    private int _counter = 0;
    private Label _counterLabel;
    private Random _random = new Random();

    public Form1()
    {
        // Настройка окна
        Text = "Меню";
        Size = new Size(640, 480);
        StartPosition = FormStartPosition.CenterScreen;
        FormBorderStyle = FormBorderStyle.FixedSingle;
        MaximizeBox = false;

        // Метки для кнопок
        var button1 = new Button
        {
            Text = "Сменить цвет",
            Size = new Size(150, 40),
            Location = new Point(245, 180)
        };
        button1.Click += Button1_Click;

        var button2 = new Button
        {
            Text = "Накрутить счётчик",
            Size = new Size(150, 40),
            Location = new Point(245, 240)
        };
        button2.Click += Button2_Click;

        var button3 = new Button
        {
            Text = "Выход",
            Size = new Size(150, 40),
            Location = new Point(245, 300)
        };
        button3.Click += Button3_Click;

        // Метка счётчика
        _counterLabel = new Label
        {
            Text = "0",
            Size = new Size(50, 40),
            Location = new Point(520, 245),
            Font = new Font("Arial", 16, FontStyle.Bold),
            TextAlign = ContentAlignment.MiddleCenter
        };

        Controls.Add(button1);
        Controls.Add(button2);
        Controls.Add(button3);
        Controls.Add(_counterLabel);
    }

    private void Button1_Click(object? sender, EventArgs e)
    {
        BackColor = Color.FromArgb(
            _random.Next(256),
            _random.Next(256),
            _random.Next(256)
        );
    }

    private void Button2_Click(object? sender, EventArgs e)
    {
        _counter++;
        _counterLabel.Text = _counter.ToString();
    }

    private void Button3_Click(object? sender, EventArgs e)
    {
        Close();
    }

    protected override void OnPaint(PaintEventArgs e)
    {
        base.OnPaint(e);
        e.Graphics.DrawString(
            "Счётчик:",
            Font,
            Brushes.Black,
            new PointF(420, 250)
        );
    }
}

using System.Drawing;
using ProbMenu.Interfaces;

namespace ProbMenu;

/// <summary>
/// Главная форма приложения.
/// </summary>
public partial class Form1 : Form
{
    private readonly ICounterService _counterService;
    private readonly IColorService _colorService;
    private readonly Label _counterLabel;

    /// <summary>
    /// Инициализирует новый экземпляр <see cref="Form1"/>.
    /// </summary>
    /// <param name="counterService">Сервис управления счётчиком.</param>
    /// <param name="colorService">Сервис генерации цветов.</param>
    public Form1(ICounterService counterService, IColorService colorService)
    {
        _counterService = counterService;
        _colorService = colorService;

        // Настройка окна
        Text = "Меню";
        Size = new Size(640, 480);
        StartPosition = FormStartPosition.CenterScreen;
        FormBorderStyle = FormBorderStyle.FixedSingle;
        MaximizeBox = false;

        // Кнопка смены цвета
        var button1 = new Button
        {
            Text = "Сменить цвет",
            Size = new Size(150, 40),
            Location = new Point(245, 180)
        };
        button1.Click += Button1_Click;

        // Кнопка инкремента счётчика
        var button2 = new Button
        {
            Text = "Накрутить счётчик",
            Size = new Size(150, 40),
            Location = new Point(245, 240)
        };
        button2.Click += Button2_Click;

        // Кнопка выхода
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

    /// <summary>
    /// Обработчик нажатия кнопки смены цвета.
    /// </summary>
    private void Button1_Click(object? sender, EventArgs e)
    {
        BackColor = _colorService.GenerateRandomColor();
    }

    /// <summary>
    /// Обработчик нажатия кнопки инкремента счётчика.
    /// </summary>
    private void Button2_Click(object? sender, EventArgs e)
    {
        var newValue = _counterService.Increment();
        _counterLabel.Text = newValue.ToString();
    }

    /// <summary>
    /// Обработчик нажатия кнопки выхода.
    /// </summary>
    private void Button3_Click(object? sender, EventArgs e)
    {
        Close();
    }

    /// <inheritdoc />
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

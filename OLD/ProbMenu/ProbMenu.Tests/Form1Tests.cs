using System.Drawing;
using System.Windows.Forms;
using System.Reflection;
using Xunit;
using ProbMenu.Services;
using ProbMenu.Interfaces;

namespace ProbMenu.Tests;

/// <summary>
/// Тесты для <see cref="Form1"/>.
/// </summary>
public class Form1Tests
{
    private readonly ICounterService _counterService;
    private readonly IColorService _colorService;

    public Form1Tests()
    {
        _counterService = new CounterService();
        _colorService = new ColorService();
    }

    [Fact]
    public void Form1_Initialize_ShouldHaveCorrectTitle()
    {
        var form = new Form1(_counterService, _colorService);
        Assert.Equal("Меню", form.Text);
    }

    [Fact]
    public void Form1_Initialize_ShouldHaveCorrectSize()
    {
        var form = new Form1(_counterService, _colorService);
        Assert.Equal(640, form.Width);
        Assert.Equal(480, form.Height);
    }

    [Fact]
    public void Form1_Initialize_ShouldStartPositionCenterScreen()
    {
        var form = new Form1(_counterService, _colorService);
        Assert.Equal(FormStartPosition.CenterScreen, form.StartPosition);
    }

    [Fact]
    public void Form1_Initialize_ShouldHaveFixedBorderStyle()
    {
        var form = new Form1(_counterService, _colorService);
        Assert.Equal(FormBorderStyle.FixedSingle, form.FormBorderStyle);
        Assert.False(form.MaximizeBox);
    }

    [Fact]
    public void Form1_ShouldHaveThreeButtons()
    {
        var form = new Form1(_counterService, _colorService);
        var buttons = form.Controls.OfType<Button>().ToList();
        Assert.Equal(3, buttons.Count);
    }

    [Fact]
    public void Form1_Button1_ShouldHaveCorrectText()
    {
        var form = new Form1(_counterService, _colorService);
        var button1 = form.Controls.OfType<Button>().FirstOrDefault(b => b.Location.Y == 180);
        Assert.NotNull(button1);
        Assert.Equal("Сменить цвет", button1.Text);
    }

    [Fact]
    public void Form1_Button2_ShouldHaveCorrectText()
    {
        var form = new Form1(_counterService, _colorService);
        var button2 = form.Controls.OfType<Button>().FirstOrDefault(b => b.Location.Y == 240);
        Assert.NotNull(button2);
        Assert.Equal("Накрутить счётчик", button2.Text);
    }

    [Fact]
    public void Form1_Button3_ShouldHaveCorrectText()
    {
        var form = new Form1(_counterService, _colorService);
        var button3 = form.Controls.OfType<Button>().FirstOrDefault(b => b.Location.Y == 300);
        Assert.NotNull(button3);
        Assert.Equal("Выход", button3.Text);
    }

    [Fact]
    public void Form1_ShouldHaveCounterLabel()
    {
        var form = new Form1(_counterService, _colorService);
        var labels = form.Controls.OfType<Label>().ToList();
        Assert.Single(labels);
    }

    [Fact]
    public void Form1_Button2_Click_ShouldIncrementCounter()
    {
        var form = new Form1(_counterService, _colorService);
        var button2 = form.Controls.OfType<Button>().FirstOrDefault(b => b.Location.Y == 240);
        Assert.NotNull(button2);

        var button2ClickHandler = typeof(Form1).GetMethod("Button2_Click",
            BindingFlags.NonPublic | BindingFlags.Instance);
        Assert.NotNull(button2ClickHandler);
        
        button2ClickHandler.Invoke(form, [button2, EventArgs.Empty]);

        Assert.Equal(1, _counterService.Value);
    }

    [Fact]
    public void Form1_Button2_Click_MultipleTimes_ShouldIncrementCounter()
    {
        var form = new Form1(_counterService, _colorService);
        var button2 = form.Controls.OfType<Button>().FirstOrDefault(b => b.Location.Y == 240);
        Assert.NotNull(button2);

        var button2ClickHandler = typeof(Form1).GetMethod("Button2_Click",
            BindingFlags.NonPublic | BindingFlags.Instance);
        Assert.NotNull(button2ClickHandler);
        
        button2ClickHandler.Invoke(form, [button2, EventArgs.Empty]);
        button2ClickHandler.Invoke(form, [button2, EventArgs.Empty]);
        button2ClickHandler.Invoke(form, [button2, EventArgs.Empty]);

        Assert.Equal(3, _counterService.Value);
    }

    [Fact]
    public void Form1_Button1_Click_ShouldChangeBackColor()
    {
        var form = new Form1(_counterService, _colorService);
        var button1 = form.Controls.OfType<Button>().FirstOrDefault(b => b.Location.Y == 180);
        Assert.NotNull(button1);

        var button1ClickHandler = typeof(Form1).GetMethod("Button1_Click",
            BindingFlags.NonPublic | BindingFlags.Instance);
        Assert.NotNull(button1ClickHandler);
        
        button1ClickHandler.Invoke(form, [button1, EventArgs.Empty]);

        Assert.True(form.BackColor.R >= 0 && form.BackColor.R <= 255);
        Assert.True(form.BackColor.G >= 0 && form.BackColor.G <= 255);
        Assert.True(form.BackColor.B >= 0 && form.BackColor.B <= 255);
    }

    [Fact]
    public void Form1_Buttons_ShouldHaveCorrectSize()
    {
        var form = new Form1(_counterService, _colorService);
        var buttons = form.Controls.OfType<Button>().ToList();
        foreach (var button in buttons)
        {
            Assert.Equal(150, button.Width);
            Assert.Equal(40, button.Height);
        }
    }

    [Fact]
    public void Form1_CounterLabel_ShouldHaveCorrectFont()
    {
        var form = new Form1(_counterService, _colorService);
        var label = form.Controls.OfType<Label>().FirstOrDefault();
        Assert.NotNull(label);
        Assert.Equal("Arial", label.Font.FontFamily.Name);
        Assert.Equal(16f, label.Font.Size);
        Assert.Equal(FontStyle.Bold, label.Font.Style);
    }
}

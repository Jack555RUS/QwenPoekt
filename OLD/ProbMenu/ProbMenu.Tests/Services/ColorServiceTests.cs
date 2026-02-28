using System.Drawing;
using Xunit;
using ProbMenu.Services;

namespace ProbMenu.Tests.Services;

/// <summary>
/// Тесты для <see cref="ColorService"/>.
/// </summary>
public class ColorServiceTests
{
    [Fact]
    public void ColorService_GenerateRandomColor_ShouldReturnValidColor()
    {
        // Arrange
        var service = new ColorService();

        // Act
        var color = service.GenerateRandomColor();

        // Assert
        Assert.True(color.R >= 0 && color.R <= 255);
        Assert.True(color.G >= 0 && color.G <= 255);
        Assert.True(color.B >= 0 && color.B <= 255);
        Assert.Equal(255, color.A); // Alpha всегда 255
    }

    [Fact]
    public void ColorService_GenerateRandomColor_WithSameSeed_ShouldReturnSameColor()
    {
        // Arrange
        var service1 = new ColorService(42);
        var service2 = new ColorService(42);

        // Act
        var color1 = service1.GenerateRandomColor();
        var color2 = service2.GenerateRandomColor();

        // Assert
        Assert.Equal(color1, color2);
    }

    [Fact]
    public void ColorService_GenerateRandomColor_MultipleCalls_ShouldReturnDifferentColors()
    {
        // Arrange
        var service = new ColorService();
        var colors = new List<Color>();

        // Act - генерируем 10 цветов
        for (int i = 0; i < 10; i++)
        {
            colors.Add(service.GenerateRandomColor());
        }

        // Assert - проверяем, что есть разные цвета
        var distinctColors = colors.Distinct().ToList();
        Assert.True(distinctColors.Count > 1, "Ожидается хотя бы 2 разных цвета");
    }

    [Fact]
    public void ColorService_GenerateRandomColor_ReturnsOpaqueColor()
    {
        // Arrange
        var service = new ColorService();

        // Act
        var color = service.GenerateRandomColor();

        // Assert - Alpha = 255 означает непрозрачный цвет
        Assert.Equal(255, color.A);
    }
}

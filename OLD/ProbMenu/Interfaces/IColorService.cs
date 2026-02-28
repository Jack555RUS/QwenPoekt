using System.Drawing;

namespace ProbMenu.Interfaces;

/// <summary>
/// Сервис для генерации случайных цветов.
/// </summary>
public interface IColorService
{
    /// <summary>
    /// Генерирует случайный цвет RGB.
    /// </summary>
    /// <returns>Случайный цвет.</returns>
    Color GenerateRandomColor();
}

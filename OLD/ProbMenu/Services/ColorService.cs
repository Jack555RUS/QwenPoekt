using System.Drawing;
using ProbMenu.Interfaces;

namespace ProbMenu.Services;

/// <summary>
/// Реализация сервиса генерации случайных цветов.
/// </summary>
public class ColorService : IColorService
{
    private readonly Random _random;

    /// <summary>
    /// Инициализирует новый экземпляр <see cref="ColorService"/>.
    /// </summary>
    public ColorService()
    {
        _random = new Random();
    }

    /// <summary>
    /// Инициализирует новый экземпляр <see cref="ColorService"/> с заданным seed.
    /// </summary>
    /// <param name="seed">Seed для генератора случайных чисел.</param>
    public ColorService(int seed)
    {
        _random = new Random(seed);
    }

    /// <inheritdoc />
    public Color GenerateRandomColor()
    {
        return Color.FromArgb(
            _random.Next(256),
            _random.Next(256),
            _random.Next(256)
        );
    }
}

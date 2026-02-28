namespace ProbMenu.Interfaces;

/// <summary>
/// Сервис для управления счётчиком.
/// </summary>
public interface ICounterService
{
    /// <summary>
    /// Текущее значение счётчика.
    /// </summary>
    int Value { get; }

    /// <summary>
    /// Инкрементирует счётчик на единицу.
    /// </summary>
    /// <returns>Новое значение счётчика.</returns>
    int Increment();

    /// <summary>
    /// Сбрасывает счётчик в ноль.
    /// </summary>
    void Reset();
}

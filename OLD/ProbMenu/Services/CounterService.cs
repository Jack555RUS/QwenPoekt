using ProbMenu.Interfaces;

namespace ProbMenu.Services;

/// <summary>
/// Реализация сервиса управления счётчиком.
/// </summary>
public class CounterService : ICounterService
{
    private int _counter;

    /// <inheritdoc />
    public int Value => _counter;

    /// <inheritdoc />
    public int Increment()
    {
        _counter++;
        return _counter;
    }

    /// <inheritdoc />
    public void Reset()
    {
        _counter = 0;
    }
}

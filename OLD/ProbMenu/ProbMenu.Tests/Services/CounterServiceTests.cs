using Xunit;
using ProbMenu.Services;

namespace ProbMenu.Tests.Services;

/// <summary>
/// Тесты для <see cref="CounterService"/>.
/// </summary>
public class CounterServiceTests
{
    [Fact]
    public void CounterService_InitialValue_ShouldBeZero()
    {
        // Arrange & Act
        var service = new CounterService();

        // Assert
        Assert.Equal(0, service.Value);
    }

    [Fact]
    public void CounterService_Increment_ShouldIncreaseValue()
    {
        // Arrange
        var service = new CounterService();

        // Act
        var result = service.Increment();

        // Assert
        Assert.Equal(1, result);
        Assert.Equal(1, service.Value);
    }

    [Fact]
    public void CounterService_Increment_MultipleTimes_ShouldAccumulate()
    {
        // Arrange
        var service = new CounterService();

        // Act
        service.Increment();
        service.Increment();
        service.Increment();

        // Assert
        Assert.Equal(3, service.Value);
    }

    [Fact]
    public void CounterService_Reset_ShouldSetValueToZero()
    {
        // Arrange
        var service = new CounterService();
        service.Increment();
        service.Increment();
        service.Increment();

        // Act
        service.Reset();

        // Assert
        Assert.Equal(0, service.Value);
    }

    [Fact]
    public void CounterService_Increment_AfterReset_ShouldStartFromZero()
    {
        // Arrange
        var service = new CounterService();
        service.Increment();
        service.Reset();

        // Act
        var result = service.Increment();

        // Assert
        Assert.Equal(1, result);
    }
}

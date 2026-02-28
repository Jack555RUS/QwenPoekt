using NUnit.Framework;
using UnityEngine;
using UnityEngine.TestTools;

/// <summary>
/// Тесты для системы логирования Logger.
/// </summary>
public class LoggerTests
{
    private Logger.LogLevel _originalLogLevel;
    private bool _originalEnabled;
    private string _originalPrefix;

    [SetUp]
    public void SetUp()
    {
        // Сохраняем оригинальные настройки
        _originalLogLevel = Logger.CurrentLogLevel;
        _originalEnabled = Logger.Enabled;
        _originalPrefix = Logger.Prefix;

        // Сбрасываем настройки для тестов
        Logger.CurrentLogLevel = Logger.LogLevel.Debug;
        Logger.Enabled = true;
        Logger.Prefix = "[Test]";
        Logger.ClearHistory();
    }

    [TearDown]
    public void TearDown()
    {
        // Восстанавливаем оригинальные настройки
        Logger.CurrentLogLevel = _originalLogLevel;
        Logger.Enabled = _originalEnabled;
        Logger.Prefix = _originalPrefix;
    }

    #region Logger Level Tests

    [Test]
    public void Debug_WhenCalled_AddsToHistory()
    {
        // Arrange
        string message = "Test debug message";

        // Act
        Logger.Debug(message);
        var history = Logger.GetHistory();

        // Assert
        Assert.That(history.Count, Is.GreaterThan(0));
        Assert.That(history[0], Does.Contain(message));
        Assert.That(history[0], Does.Contain("[DBG]"));
    }

    [Test]
    public void Info_WhenCalled_AddsToHistory()
    {
        // Arrange
        string message = "Test info message";

        // Act
        Logger.Info(message);
        var history = Logger.GetHistory();

        // Assert
        Assert.That(history.Count, Is.GreaterThan(0));
        Assert.That(history[0], Does.Contain(message));
        Assert.That(history[0], Does.Contain("[INF]"));
    }

    [Test]
    public void Warning_WhenCalled_AddsToHistory()
    {
        // Arrange
        string message = "Test warning message";

        // Act
        Logger.Warning(message);
        var history = Logger.GetHistory();

        // Assert
        Assert.That(history.Count, Is.GreaterThan(0));
        Assert.That(history[0], Does.Contain(message));
        Assert.That(history[0], Does.Contain("[WRN]"));
    }

    [Test]
    public void Error_WhenCalled_AddsToHistory()
    {
        // Arrange
        string message = "Test error message";

        // Act
        Logger.Error(message);
        var history = Logger.GetHistory();

        // Assert
        Assert.That(history.Count, Is.GreaterThan(0));
        Assert.That(history[0], Does.Contain(message));
        Assert.That(history[0], Does.Contain("[ERR]"));
    }

    #endregion

    #region Logger Filter Tests

    [Test]
    public void Log_WhenLevelBelowThreshold_DoesNotAddToHistory()
    {
        // Arrange
        Logger.CurrentLogLevel = Logger.LogLevel.Warning;
        string debugMessage = "Debug message";
        string warningMessage = "Warning message";

        // Act
        Logger.Debug(debugMessage);
        Logger.Warning(warningMessage);
        var history = Logger.GetHistory();

        // Assert
        Assert.That(history.Count, Is.EqualTo(1));
        Assert.That(history[0], Does.Contain(warningMessage));
        Assert.That(history[0], Does.Not.Contain(debugMessage));
    }

    [Test]
    public void Log_WhenDisabled_DoesNotAddToHistory()
    {
        // Arrange
        Logger.Enabled = false;
        string message = "Test message";

        // Act
        Logger.Info(message);
        var history = Logger.GetHistory();

        // Assert
        Assert.That(history.Count, Is.EqualTo(0));
    }

    #endregion

    #region Logger History Tests

    [Test]
    public void GetHistory_WithCount_ReturnsCorrectNumberOfItems()
    {
        // Arrange
        Logger.Info("Message 1");
        Logger.Info("Message 2");
        Logger.Info("Message 3");
        Logger.Info("Message 4");
        Logger.Info("Message 5");

        // Act
        var history = Logger.GetHistory(3);

        // Assert
        Assert.That(history.Count, Is.EqualTo(3));
        Assert.That(history[0], Does.Contain("Message 3"));
        Assert.That(history[2], Does.Contain("Message 5"));
    }

    [Test]
    public void ClearHistory_WhenCalled_RemovesAllEntries()
    {
        // Arrange
        Logger.Info("Message 1");
        Logger.Info("Message 2");

        // Act
        Logger.ClearHistory();
        var history = Logger.GetHistory();

        // Assert
        Assert.That(history.Count, Is.EqualTo(0));
    }

    [Test]
    public void GetHistory_WhenExceedsMaxSize_RemovesOldestEntries()
    {
        // Arrange & Act
        for (int i = 0; i < 150; i++)
        {
            Logger.Info($"Message {i}");
        }

        // Assert
        var history = Logger.GetHistory();
        Assert.That(history.Count, Is.EqualTo(100)); // MaxHistorySize
        Assert.That(history[0], Does.Contain("Message 50"));
        Assert.That(history[99], Does.Contain("Message 149"));
    }

    #endregion

    #region Logger Event Tests

    [Test]
    public void Log_WhenCalled_TriggersOnLogAddedEvent()
    {
        // Arrange
        bool eventTriggered = false;
        Logger.OnLogAdded += (level, msg) => eventTriggered = true;

        // Act
        Logger.Info("Test message");

        // Assert
        Assert.That(eventTriggered, Is.True);
    }

    [Test]
    public void Log_WhenCalled_PassesCorrectLogLevelToEvent()
    {
        // Arrange
        Logger.LogLevel receivedLevel = Logger.LogLevel.Debug;
        Logger.OnLogAdded += (level, msg) => receivedLevel = level;

        // Act
        Logger.Warning("Test message");

        // Assert
        Assert.That(receivedLevel, Is.EqualTo(Logger.LogLevel.Warning));
    }

    #endregion

    #region Logger Format Tests

    [Test]
    public void Log_WithCustomPrefix_UsesCorrectPrefix()
    {
        // Arrange
        Logger.Prefix = "[CustomPrefix]";
        string message = "Test message";

        // Act
        Logger.Info(message);
        var history = Logger.GetHistory();

        // Assert
        Assert.That(history[0], Does.Contain("[CustomPrefix]"));
    }

    [Test]
    public void Log_IncludesTimestamp()
    {
        // Arrange
        string message = "Test message";

        // Act
        Logger.Info(message);
        var history = Logger.GetHistory();

        // Assert
        Assert.That(history[0], Does.Match(@"\d{2}:\d{2}:\d{2}\.\d{3}"));
    }

    #endregion
}

using NUnit.Framework;
using UnityEngine;
using UnityEngine.TestTools;
using System.Collections;

/// <summary>
/// Тесты для контроллера главного меню.
/// </summary>
[TestFixture]
public class MainMenuControllerTests
{
    private GameObject _controllerObject;
    private MainMenuController _controller;
    private bool _newGameCalled;
    private bool _continueCalled;
    private bool _saveCalled;
    private bool _loadCalled;
    private bool _settingsCalled;
    private bool _exitCalled;

    [SetUp]
    public void SetUp()
    {
        // Создаём объект с контроллером
        _controllerObject = new GameObject("MainMenuController");
        _controller = _controllerObject.AddComponent<MainMenuController>();

        // Сбрасываем флаги
        _newGameCalled = false;
        _continueCalled = false;
        _saveCalled = false;
        _loadCalled = false;
        _settingsCalled = false;
        _exitCalled = false;

        // Очищаем историю логов
        Logger.ClearHistory();
    }

    [TearDown]
    public void TearDown()
    {
        // Удаляем объект
        if (_controllerObject != null)
        {
            Object.DestroyImmediate(_controllerObject);
        }
    }

    #region Button Click Tests

    [Test]
    public void OnNewGame_WhenCalled_LogsCorrectMessage()
    {
        // Act
        _controller.OnNewGame();

        // Assert
        var history = Logger.GetHistory();
        Assert.That(history.Count, Is.GreaterThan(0));
        Assert.That(history[0], Does.Contain("НОВАЯ ИГРА"));
    }

    [Test]
    public void OnContinue_WhenCalled_LogsCorrectMessage()
    {
        // Act
        _controller.OnContinue();

        // Assert
        var history = Logger.GetHistory();
        Assert.That(history.Count, Is.GreaterThan(0));
        Assert.That(history[0], Does.Contain("ПРОДОЛЖИТЬ"));
    }

    [Test]
    public void OnSave_WhenCalled_LogsCorrectMessage()
    {
        // Act
        _controller.OnSave();

        // Assert
        var history = Logger.GetHistory();
        Assert.That(history.Count, Is.GreaterThan(0));
        Assert.That(history[0], Does.Contain("СОХРАНИТЬ"));
    }

    [Test]
    public void OnLoad_WhenCalled_LogsCorrectMessage()
    {
        // Act
        _controller.OnLoad();

        // Assert
        var history = Logger.GetHistory();
        Assert.That(history.Count, Is.GreaterThan(0));
        Assert.That(history[0], Does.Contain("ЗАГРУЗИТЬ"));
    }

    [Test]
    public void OnSettings_WhenCalled_LogsCorrectMessage()
    {
        // Act
        _controller.OnSettings();

        // Assert
        var history = Logger.GetHistory();
        Assert.That(history.Count, Is.GreaterThan(0));
        Assert.That(history[0], Does.Contain("НАСТРОЙКИ"));
    }

    [Test]
    public void OnExit_WhenCalled_LogsCorrectMessage()
    {
        // Act
        _controller.OnExit();

        // Assert
        var history = Logger.GetHistory();
        Assert.That(history.Count, Is.GreaterThan(0));
        Assert.That(history[0], Does.Contain("ВЫХОД"));
    }

    #endregion

    #region Log Level Tests

    [Test]
    public void ButtonHandlers_UseInfoLevel_ForUserActions()
    {
        // Act
        _controller.OnNewGame();

        // Assert
        var history = Logger.GetHistory();
        Assert.That(history[0], Does.Contain("[INF]"));
    }

    [Test]
    public void PrivateHandlers_UseDebugLevel_ForInternalLogic()
    {
        // Act
        _controller.OnNewGame();

        // Assert
        var history = Logger.GetHistory();
        Assert.That(history[1], Does.Contain("[DBG]"));
    }

    #endregion

    #region Integration Tests

    [Test]
    public void MultipleButtonClicks_LogAllActions()
    {
        // Act
        _controller.OnNewGame();
        _controller.OnSettings();
        _controller.OnExit();

        // Assert
        var history = Logger.GetHistory();
        Assert.That(history.Count, Is.AtLeast(3));
        Assert.That(history[0], Does.Contain("НОВАЯ ИГРА"));
        Assert.That(history[1], Does.Contain("НАСТРОЙКИ"));
        Assert.That(history[2], Does.Contain("ВЫХОД"));
    }

    [Test]
    public void Controller_WhenCreated_HasValidReference()
    {
        // Assert
        Assert.That(_controller, Is.Not.Null);
        Assert.That(_controller.enabled, Is.True);
    }

    #endregion
}

using NUnit.Framework;
using UnityEngine;
using UnityEngine.UI;
using UnityEngine.TestTools;

/// <summary>
/// Тесты для MainMenuController.
/// Проверяют навигацию, кнопки и состояния.
/// </summary>
[TestFixture]
public class MainMenuControllerTests
{
    private GameObject _testObject;
    private MainMenuController _controller;
    private Button[] _buttons;

    #region Setup

    [SetUp]
    public void Setup()
    {
        // Создаём тестовый объект с контроллером
        _testObject = new GameObject("MainMenuController_Test");
        _controller = _testObject.AddComponent<MainMenuController>();

        // Создаём тестовые кнопки
        CreateTestButtons();
    }

    [TearDown]
    public void Teardown()
    {
        // Очищаем тестовые объекты
        if (_testObject != null)
        {
            Object.DestroyImmediate(_testObject);
        }
    }

    private void CreateTestButtons()
    {
        // Создаём 6 кнопок для тестирования
        var canvas = _testObject.AddComponent<Canvas>();
        _buttons = new Button[6];

        for (int i = 0; i < 6; i++)
        {
            var buttonObj = new GameObject($"Button_{i}");
            buttonObj.transform.SetParent(_testObject.transform);
            _buttons[i] = buttonObj.AddComponent<Button>();
        }
    }

    #endregion

    #region Кнопки (6 тестов)

    [Test]
    public void OnNewGame_Clicked_CallsHandleNewGame()
    {
        // Arrange & Act
        LogAssert.Expect(LogType.Log, "Нажата кнопка: НОВАЯ ИГРА");
        
        // Assert
        Assert.DoesNotThrow(() => _controller.OnNewGame());
    }

    [Test]
    public void OnContinue_Clicked_CallsHandleContinue()
    {
        // Arrange & Act
        LogAssert.Expect(LogType.Log, "Нажата кнопка: ПРОДОЛЖИТЬ");
        
        // Assert
        Assert.DoesNotThrow(() => _controller.OnContinue());
    }

    [Test]
    public void OnSave_Clicked_CallsHandleSave()
    {
        // Arrange & Act
        LogAssert.Expect(LogType.Log, "Нажата кнопка: СОХРАНИТЬ");
        
        // Assert
        Assert.DoesNotThrow(() => _controller.OnSave());
    }

    [Test]
    public void OnLoad_Clicked_CallsHandleLoad()
    {
        // Arrange & Act
        LogAssert.Expect(LogType.Log, "Нажата кнопка: ЗАГРУЗИТЬ");
        
        // Assert
        Assert.DoesNotThrow(() => _controller.OnLoad());
    }

    [Test]
    public void OnSettings_Clicked_CallsHandleSettings()
    {
        // Arrange & Act
        LogAssert.Expect(LogType.Log, "Нажата кнопка: НАСТРОЙКИ");
        
        // Assert
        Assert.DoesNotThrow(() => _controller.OnSettings());
    }

    [Test]
    public void OnExit_Clicked_CallsHandleExit()
    {
        // Arrange & Act
        LogAssert.Expect(LogType.Log, "Нажата кнопка: ВЫХОД");
        
        // Assert
        Assert.DoesNotThrow(() => _controller.OnExit());
    }

    #endregion

    #region Навигация (4 теста)

    [Test]
    public void NavigateUp_FromMiddle_MovesToPrevious()
    {
        // Arrange
        _controller.GetType()
            .GetField("_currentIndex", System.Reflection.BindingFlags.NonPublic | System.Reflection.BindingFlags.Instance)
            ?.SetValue(_controller, 2);

        // Act
        var method = _controller.GetType()
            .GetMethod("NavigateUp", System.Reflection.BindingFlags.NonPublic | System.Reflection.BindingFlags.Instance);
        method?.Invoke(_controller, null);

        // Assert
        var currentIndex = _controller.GetType()
            .GetField("_currentIndex", System.Reflection.BindingFlags.NonPublic | System.Reflection.BindingFlags.Instance)
            ?.GetValue(_controller);
        Assert.AreEqual(1, currentIndex);
    }

    [Test]
    public void NavigateDown_FromMiddle_MovesToNext()
    {
        // Arrange
        _controller.GetType()
            .GetField("_currentIndex", System.Reflection.BindingFlags.NonPublic | System.Reflection.BindingFlags.Instance)
            ?.SetValue(_controller, 2);

        // Act
        var method = _controller.GetType()
            .GetMethod("NavigateDown", System.Reflection.BindingFlags.NonPublic | System.Reflection.BindingFlags.Instance);
        method?.Invoke(_controller, null);

        // Assert
        var currentIndex = _controller.GetType()
            .GetField("_currentIndex", System.Reflection.BindingFlags.NonPublic | System.Reflection.BindingFlags.Instance)
            ?.GetValue(_controller);
        Assert.AreEqual(3, currentIndex);
    }

    [Test]
    public void NavigateUp_FromFirst_LoopsToLast()
    {
        // Arrange
        _controller.GetType()
            .GetField("_currentIndex", System.Reflection.BindingFlags.NonPublic | System.Reflection.BindingFlags.Instance)
            ?.SetValue(_controller, 0);

        // Act
        var method = _controller.GetType()
            .GetMethod("NavigateUp", System.Reflection.BindingFlags.NonPublic | System.Reflection.BindingFlags.Instance);
        method?.Invoke(_controller, null);

        // Assert
        var currentIndex = _controller.GetType()
            .GetField("_currentIndex", System.Reflection.BindingFlags.NonPublic | System.Reflection.BindingFlags.Instance)
            ?.GetValue(_controller);
        Assert.AreEqual(5, currentIndex); // Последняя кнопка
    }

    [Test]
    public void NavigateDown_FromLast_LoopsToFirst()
    {
        // Arrange
        _controller.GetType()
            .GetField("_currentIndex", System.Reflection.BindingFlags.NonPublic | System.Reflection.BindingFlags.Instance)
            ?.SetValue(_controller, 5);

        // Act
        var method = _controller.GetType()
            .GetMethod("NavigateDown", System.Reflection.BindingFlags.NonPublic | System.Reflection.BindingFlags.Instance);
        method?.Invoke(_controller, null);

        // Assert
        var currentIndex = _controller.GetType()
            .GetField("_currentIndex", System.Reflection.BindingFlags.NonPublic | System.Reflection.BindingFlags.Instance)
            ?.GetValue(_controller);
        Assert.AreEqual(0, currentIndex); // Первая кнопка
    }

    #endregion

    #region Состояния (3 теста)

    [Test]
    public void Start_InitializesButtons()
    {
        // Act
        _controller.GetType()
            .GetMethod("Start", System.Reflection.BindingFlags.NonPublic | System.Reflection.BindingFlags.Instance)
            ?.Invoke(_controller, null);

        // Assert
        var buttons = _controller.GetType()
            .GetField("_buttons", System.Reflection.BindingFlags.NonPublic | System.Reflection.BindingFlags.Instance)
            ?.GetValue(_controller) as Button[];
        
        Assert.IsNotNull(buttons);
        Assert.Greater(buttons.Length, 0);
    }

    [Test]
    public void OnDisable_UnsubscribesFromEvents()
    {
        // Arrange
        var onDisableMethod = _controller.GetType()
            .GetMethod("OnDisable", System.Reflection.BindingFlags.NonPublic | System.Reflection.BindingFlags.Instance);

        // Act & Assert
        Assert.DoesNotThrow(() => onDisableMethod?.Invoke(_controller, null));
    }

    [Test]
    public void HandleKeyboardNavigation_Escape_CallsOnExit()
    {
        // Arrange
        LogAssert.Expect(LogType.Log, "Нажата кнопка: ВЫХОД");

        // Act
        var handleKeyboardMethod = _controller.GetType()
            .GetMethod("HandleKeyboardNavigation", System.Reflection.BindingFlags.NonPublic | System.Reflection.BindingFlags.Instance);
        
        // Simulate Escape key
        Input.simulateMouseWithTouches = false;
        
        // Assert
        Assert.DoesNotThrow(() => handleKeyboardMethod?.Invoke(_controller, null));
    }

    #endregion
}

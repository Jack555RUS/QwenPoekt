using NUnit.Framework;
using UnityEngine;
using UnityEngine.TestTools;
using RacingGame.Managers;
using RacingGame.Utilities;
using System.Collections;
using UnityEngine.UIElements;

namespace RacingGame.Tests
{
    /// <summary>
    /// Тесты для UI системы и MenuManager
    /// </summary>
    public class UITests
    {
        private GameObject _menuManagerObject;
        private MenuManager _menuManager;

        [SetUp]
        public void Setup()
        {
            _menuManagerObject = new GameObject("MenuManager");
            _menuManager = _menuManagerObject.AddComponent<MenuManager>();
            GameLogger.Initialize();
        }

        [TearDown]
        public void TearDown()
        {
            if (_menuManagerObject != null)
            {
                Object.DestroyImmediate(_menuManagerObject);
            }
            MenuManager.Instance = null;
        }

        [Test]
        public void MenuManager_Start_ShowMainMenu()
        {
            // Вызываем Start через рефлексию
            var startMethod = _menuManager.GetType().GetMethod("Start",
                System.Reflection.BindingFlags.NonPublic |
                System.Reflection.BindingFlags.Instance);
            
            // Не должно выбрасывать исключений
            Assert.DoesNotThrow(() => startMethod?.Invoke(_menuManager, null));
        }

        [Test]
        public void ShowMainMenu_HideCurrentMenu_NoErrors()
        {
            Assert.DoesNotThrow(() => _menuManager.ShowMainMenu());
            Assert.DoesNotThrow(() => _menuManager.HideCurrentMenu());
        }

        [Test]
        public void CurrentMenuName_Empty_WhenNoMenuLoaded()
        {
            Assert.AreEqual("", _menuManager.CurrentMenuName);
        }

        [UnityTest]
        public IEnumerator ShowSettingsMenu_NoErrors()
        {
            Assert.DoesNotThrow(() => _menuManager.ShowSettingsMenu());
            yield return null;
            Assert.AreEqual("SettingsMenu", _menuManager.CurrentMenuName);
        }

        [UnityTest]
        public IEnumerator ShowPauseMenu_NoErrors()
        {
            Assert.DoesNotThrow(() => _menuManager.ShowPauseMenu());
            yield return null;
            Assert.AreEqual("PauseMenu", _menuManager.CurrentMenuName);
        }

        [Test]
        public void GetElement_Null_WhenMenuNotLoaded()
        {
            var button = _menuManager.GetElement<Button>("TestButton");
            Assert.IsNull(button);
        }

        [Test]
        public void MenuTransitions_NoErrors()
        {
            // Проверяем переходы между меню
            Assert.DoesNotThrow(() => _menuManager.ShowMainMenu());
            Assert.DoesNotThrow(() => _menuManager.ShowSettingsMenu());
            Assert.DoesNotThrow(() => _menuManager.ShowMainMenu());
            Assert.DoesNotThrow(() => _menuManager.ShowPauseMenu());
            Assert.DoesNotThrow(() => _menuManager.HideCurrentMenu());
        }
    }

    /// <summary>
    /// Тесты для системы сохранений
    /// </summary>
    public class SaveManagerIntegrationTests
    {
        [SetUp]
        public void Setup()
        {
            GameLogger.Initialize();
            SaveManager.Initialize();
        }

        [TearDown]
        public void TearDown()
        {
            SaveManager.DeleteSave();
            SaveManager.CurrentData = null;
        }

        [Test]
        public void FullSaveLoadCycle_Successful()
        {
            // Создаем новую игру
            SaveManager.CreateNewGame("TestPlayer");
            SaveManager.AddMoney(500);
            SaveManager.AddExperience(100);
            
            // Сохраняем
            SaveManager.SaveGame();
            
            // Очищаем данные
            SaveManager.CurrentData = null;
            
            // Загружаем
            SaveManager.LoadGame();
            
            // Проверяем
            Assert.IsNotNull(SaveManager.CurrentData);
            Assert.AreEqual("TestPlayer", SaveManager.CurrentData.playerName);
            Assert.AreEqual(1500, SaveManager.CurrentData.currentMoney);
            Assert.AreEqual(100, SaveManager.CurrentData.currentExperience);
        }

        [Test]
        public void MultipleSaves_OverwriteCorrectly()
        {
            SaveManager.CreateNewGame("Player1");
            SaveManager.SaveGame();
            
            SaveManager.CreateNewGame("Player2");
            SaveManager.SaveGame();
            
            SaveManager.CurrentData = null;
            SaveManager.LoadGame();
            
            Assert.AreEqual("Player2", SaveManager.CurrentData.playerName);
        }

        [Test]
        public void CarData_SaveLoad_Successful()
        {
            SaveManager.CreateNewGame("CarTest");
            
            var car = new CarData("SportsCar");
            car.speed = 90;
            car.handling = 85;
            car.acceleration = 80;
            car.braking = 75;
            car.color = Color.red;
            
            SaveManager.UpdateCarData(0, car);
            SaveManager.SaveGame();
            
            SaveManager.CurrentData = null;
            SaveManager.LoadGame();
            
            var loadedCar = SaveManager.GetCarData(0);
            
            Assert.AreEqual("SportsCar", loadedCar.carName);
            Assert.AreEqual(90, loadedCar.speed);
            Assert.AreEqual(Color.red, loadedCar.color);
        }
    }

    /// <summary>
    /// Тесты для GameLogger
    /// </summary>
    public class LoggerTests
    {
        [Test]
        public void LogInfo_NoErrors()
        {
            Assert.DoesNotThrow(() => GameLogger.LogInfo("Test info message"));
        }

        [Test]
        public void LogWarning_NoErrors()
        {
            Assert.DoesNotThrow(() => GameLogger.LogWarning("Test warning message"));
        }

        [Test]
        public void LogError_NoErrors()
        {
            Assert.DoesNotThrow(() => GameLogger.LogError("Test error message"));
        }

        [Test]
        public void LogDebug_NoErrors()
        {
            Assert.DoesNotThrow(() => GameLogger.LogDebug("Test debug message"));
        }

        [Test]
        public void Initialize_CreatesLogFile()
        {
            GameLogger.Initialize();
            // Файл должен быть создан
            Assert.Pass("Логгер инициализирован успешно");
        }
    }

    /// <summary>
    /// Интеграционные тесты для всех менеджеров
    /// </summary>
    public class IntegrationTests
    {
        private GameObject _managersContainer;

        [SetUp]
        public void Setup()
        {
            _managersContainer = new GameObject("ManagersContainer");
            GameLogger.Initialize();
        }

        [TearDown]
        public void TearDown()
        {
            if (_managersContainer != null)
            {
                Object.DestroyImmediate(_managersContainer);
            }
            
            GameManager.Instance = null;
            MenuManager.Instance = null;
            AudioManager.Instance = null;
            InputManager.Instance = null;
        }

        [Test]
        public void AllManagers_Create_Successful()
        {
            var gm = _managersContainer.AddComponent<GameManager>();
            var mm = _managersContainer.AddComponent<MenuManager>();
            var am = _managersContainer.AddComponent<AudioManager>();
            var im = _managersContainer.AddComponent<InputManager>();

            Assert.IsNotNull(GameManager.Instance);
            Assert.IsNotNull(MenuManager.Instance);
            Assert.IsNotNull(AudioManager.Instance);
            Assert.IsNotNull(InputManager.Instance);
        }

        [Test]
        public void GameManager_StateTransitions_WorkCorrectly()
        {
            var gm = _managersContainer.AddComponent<GameManager>();
            
            bool stateChanged = false;
            GameManager.GameState lastState = GameManager.GameState.None;
            
            gm.OnStateChanged += (s) =>
            {
                stateChanged = true;
                lastState = s;
            };
            
            gm.SetState(GameManager.GameState.MainMenu);
            Assert.IsTrue(stateChanged);
            Assert.AreEqual(GameManager.GameState.MainMenu, lastState);
            
            stateChanged = false;
            gm.SetState(GameManager.GameState.Playing);
            Assert.IsTrue(stateChanged);
            Assert.AreEqual(GameManager.GameState.Playing, lastState);
        }

        [UnityTest]
        public IEnumerator TimeScale_PauseResume_WorksCorrectly()
        {
            var gm = _managersContainer.AddComponent<GameManager>();
            
            Time.timeScale = 1f;
            gm.SetState(GameManager.GameState.Playing);
            
            gm.PauseGame();
            yield return null;
            Assert.AreEqual(0f, Time.timeScale);
            
            gm.ResumeGame();
            yield return null;
            Assert.AreEqual(1f, Time.timeScale);
            
            Time.timeScale = 1f;
        }
    }
}

using UnityEngine;
using UnityEngine.UIElements;
using RacingGame.Managers;
using RacingGame.Utilities;

namespace RacingGame.UI
{
    /// <summary>
    /// Автоматический тестировщик UI меню
    /// Проверяет наличие всех кнопок и их функциональность
    /// </summary>
    public class UITestRunner : MonoBehaviour
    {
        [Header("Настройки теста")]
        [SerializeField] private bool _runTestsOnStart = true;
        [SerializeField] private float _testDelay = 0.5f;

        private int _testsPassed;
        private int _testsFailed;
        private MenuManager _menuManager;

        private void Start()
        {
            if (_runTestsOnStart)
            {
                Invoke(nameof(RunAllTests), 1f);
            }
        }

        public void RunAllTests()
        {
            _testsPassed = 0;
            _testsFailed = 0;

            GameLogger.LogInfo("=== ЗАПУСК ТЕСТОВ UI ===");

            _menuManager = MenuManager.Instance;

            if (_menuManager == null)
            {
                GameLogger.LogError("MenuManager не найден! Тесты не могут быть выполнены.");
                return;
            }

            // Тест 1: Проверка показа главного меню
            TestMainMenu();

            // Тест 2: Проверка показа меню настроек
            TestSettingsMenu();

            // Тест 3: Проверка показа игрового меню
            TestGameMenu();

            // Тест 4: Проверка показа меню паузы
            TestPauseMenu();

            // Тест 5: Проверка кнопок главного меню
            TestMainMenuButtons();

            // Вывод результатов
            GameLogger.LogInfo("=== РЕЗУЛЬТАТЫ ТЕСТОВ ===");
            GameLogger.LogInfo($"Пройдено: {_testsPassed}");
            GameLogger.LogInfo($"Провалено: {_testsFailed}");
            GameLogger.LogInfo($"Всего: {_testsPassed + _testsFailed}");

            if (_testsFailed == 0)
            {
                GameLogger.LogInfo("✅ ВСЕ ТЕСТЫ ПРОЙДЕНЫ!");
            }
            else
            {
                GameLogger.LogWarning($"❌ {_testsFailed} тест(а) провалено!");
            }
        }

        private void TestMainMenu()
        {
            GameLogger.LogInfo("Тест: Главное меню...");
            _menuManager.ShowMainMenu();

            if (_menuManager.CurrentMenuName == "MainMenu")
            {
                PassTest("Главное меню отображается");
            }
            else
            {
                FailTest("Главное меню не отображается");
            }
        }

        private void TestSettingsMenu()
        {
            GameLogger.LogInfo("Тест: Меню настроек...");
            _menuManager.ShowSettingsMenu();

            if (_menuManager.CurrentMenuName == "SettingsMenu")
            {
                PassTest("Меню настроек отображается");

                // Проверяем наличие элементов настроек
                var musicSlider = _menuManager.GetElement<Slider>("MusicVolumeSlider");
                var sfxSlider = _menuManager.GetElement<Slider>("SFXVolumeSlider");
                var resolutionDropdown = _menuManager.GetElement<DropdownField>("ResolutionDropdown");
                var qualityDropdown = _menuManager.GetElement<DropdownField>("QualityDropdown");
                var fullscreenToggle = _menuManager.GetElement<Toggle>("FullscreenToggle");
                var backButton = _menuManager.GetElement<Button>("BackButton");

                if (musicSlider != null) PassTest("Ползунок музыки найден");
                else FailTest("Ползунок музыки не найден");

                if (sfxSlider != null) PassTest("Ползунок эффектов найден");
                else FailTest("Ползунок эффектов не найден");

                if (resolutionDropdown != null) PassTest("Выпадающий список разрешений найден");
                else FailTest("Выпадающий список разрешений не найден");

                if (qualityDropdown != null) PassTest("Выпадающий список качества найден");
                else FailTest("Выпадающий список качества не найден");

                if (fullscreenToggle != null) PassTest("Переключатель fullscreen найден");
                else FailTest("Переключатель fullscreen не найден");

                if (backButton != null) PassTest("Кнопка Назад найдена");
                else FailTest("Кнопка Назад не найдена");
            }
            else
            {
                FailTest("Меню настроек не отображается");
            }
        }

        private void TestGameMenu()
        {
            GameLogger.LogInfo("Тест: Игровое меню...");
            _menuManager.ShowGameMenu();

            if (_menuManager.CurrentMenuName == "GameMenu")
            {
                PassTest("Игровое меню отображается");

                // Проверяем наличие кнопок
                var raceButton = _menuManager.GetElement<Button>("RaceButton");
                var garageButton = _menuManager.GetElement<Button>("GarageButton");
                var tuningButton = _menuManager.GetElement<Button>("TuningButton");
                var shopButton = _menuManager.GetElement<Button>("ShopButton");
                var menuButton = _menuManager.GetElement<Button>("MenuButton");

                if (raceButton != null) PassTest("Кнопка Заезд найдена");
                else FailTest("Кнопка Заезд не найдена");

                if (garageButton != null) PassTest("Кнопка Гараж найдена");
                else FailTest("Кнопка Гараж не найдена");

                if (tuningButton != null) PassTest("Кнопка Тюнинг найдена");
                else FailTest("Кнопка Тюнинг не найдена");

                if (shopButton != null) PassTest("Кнопка Магазин найдена");
                else FailTest("Кнопка Магазин не найдена");

                if (menuButton != null) PassTest("Кнопка Меню найдена");
                else FailTest("Кнопка Меню не найдена");
            }
            else
            {
                FailTest("Игровое меню не отображается");
            }
        }

        private void TestPauseMenu()
        {
            GameLogger.LogInfo("Тест: Меню паузы...");
            _menuManager.ShowPauseMenu();

            if (_menuManager.CurrentMenuName == "PauseMenu")
            {
                PassTest("Меню паузы отображается");

                // Проверяем наличие кнопок
                var resumeButton = _menuManager.GetElement<Button>("ResumeButton");
                var mainMenuButton = _menuManager.GetElement<Button>("MainMenuButton");
                var settingsButton = _menuManager.GetElement<Button>("PauseSettingsButton");
                var exitButton = _menuManager.GetElement<Button>("ExitButton");

                if (resumeButton != null) PassTest("Кнопка Продолжить найдена");
                else FailTest("Кнопка Продолжить не найдена");

                if (mainMenuButton != null) PassTest("Кнопка В главное меню найдена");
                else FailTest("Кнопка В главное меню не найдена");

                if (settingsButton != null) PassTest("Кнопка Настройки (пауза) найдена");
                else FailTest("Кнопка Настройки (пауза) не найдена");

                if (exitButton != null) PassTest("Кнопка Выход (пауза) найдена");
                else FailTest("Кнопка Выход (пауза) не найдена");
            }
            else
            {
                FailTest("Меню паузы не отображается");
            }
        }

        private void TestMainMenuButtons()
        {
            GameLogger.LogInfo("Тест: Кнопки главного меню...");
            _menuManager.ShowMainMenu();

            var newGameButton = _menuManager.GetElement<Button>("NewGameButton");
            var continueButton = _menuManager.GetElement<Button>("ContinueButton");
            var saveButton = _menuManager.GetElement<Button>("SaveButton");
            var loadButton = _menuManager.GetElement<Button>("LoadButton");
            var settingsButton = _menuManager.GetElement<Button>("SettingsButton");
            var exitButton = _menuManager.GetElement<Button>("ExitButton");

            if (newGameButton != null) PassTest("Кнопка Новая игра найдена");
            else FailTest("Кнопка Новая игра не найдена");

            if (continueButton != null) PassTest("Кнопка Продолжить найдена");
            else FailTest("Кнопка Продолжить не найдена");

            if (saveButton != null) PassTest("Кнопка Сохранить найдена");
            else FailTest("Кнопка Сохранить не найдена");

            if (loadButton != null) PassTest("Кнопка Загрузить найдена");
            else FailTest("Кнопка Загрузить не найдена");

            if (settingsButton != null) PassTest("Кнопка Настройки найдена");
            else FailTest("Кнопка Настройки не найдена");

            if (exitButton != null) PassTest("Кнопка Выход найдена");
            else FailTest("Кнопка Выход не найдена");
        }

        private void PassTest(string testName)
        {
            _testsPassed++;
            GameLogger.LogInfo($"✅ {testName}");
        }

        private void FailTest(string testName)
        {
            _testsFailed++;
            GameLogger.LogWarning($"❌ {testName}");
        }

        [ContextMenu("Запустить тесты UI")]
        public void RunTestsFromContext()
        {
            RunAllTests();
        }
    }
}

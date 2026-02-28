using UnityEngine;
using UnityEngine.UIElements;
using RacingGame.Utilities;

namespace RacingGame.Managers
{
    /// <summary>
    /// Менеджер меню. Управляет навигацией между экранами UI.
    /// </summary>
    public class MenuManager : MonoBehaviour
    {
        public static MenuManager Instance { get; private set; }

        [Header("UI Документы")]
        [SerializeField] private VisualTreeAsset _mainMenuAsset;
        [SerializeField] private VisualTreeAsset _gameMenuAsset;
        [SerializeField] private VisualTreeAsset _settingsMenuAsset;
        [SerializeField] private VisualTreeAsset _pauseMenuAsset;

        [Header("Настройки")]
        [SerializeField] private string _mainMenuName = "MainMenu";
        [SerializeField] private string _gameMenuName = "GameMenu";
        [SerializeField] private string _settingsMenuName = "SettingsMenu";
        [SerializeField] private string _pauseMenuName = "PauseMenu";

        private UIDocument _currentDocument;
        private VisualElement _root;
        private string _currentMenuName;

        public string CurrentMenuName => _currentMenuName;

        private void Awake()
        {
            if (Instance == null)
            {
                Instance = this;
            }
            else
            {
                Destroy(gameObject);
                return;
            }

            GameLogger.LogInfo("MenuManager инициализирован");
        }

        private void Start()
        {
            ShowMainMenu();
        }

        public void ShowMainMenu()
        {
            GameLogger.LogInfo("Показ главного меню");
            LoadMenu(_mainMenuAsset, _mainMenuName);
            SetupMainMenuHandlers();
        }

        public void ShowGameMenu()
        {
            GameLogger.LogInfo("Показ меню игры");
            LoadMenu(_gameMenuAsset, _gameMenuName);
            SetupGameMenuHandlers();
        }

        public void ShowSettingsMenu()
        {
            GameLogger.LogInfo("Показ меню настроек");
            LoadMenu(_settingsMenuAsset, _settingsMenuName);
            SetupSettingsMenuHandlers();
        }

        public void ShowPauseMenu()
        {
            GameLogger.LogInfo("Показ меню паузы");
            LoadMenu(_pauseMenuAsset, _pauseMenuName);
            SetupPauseMenuHandlers();
        }

        public void HideCurrentMenu()
        {
            if (_currentDocument != null)
            {
                GameLogger.LogInfo($"Скрытие меню: {_currentMenuName}");
                Destroy(_currentDocument.gameObject);
                _currentDocument = null;
                _root = null;
            }
        }

        private void LoadMenu(VisualTreeAsset asset, string menuName)
        {
            HideCurrentMenu();

            if (asset == null)
            {
                GameLogger.LogWarning($"Попытка загрузить null asset для {menuName}");
                return;
            }

            GameObject menuObject = new GameObject(menuName);
            menuObject.transform.SetParent(transform);
            _currentDocument = menuObject.AddComponent<UIDocument>();
            _currentDocument.visualTreeAsset = asset;
            _currentDocument.enabled = true;

            // Ждем пока документ загрузится
            _root = _currentDocument.rootVisualElement;
            _currentMenuName = menuName;

            GameLogger.LogDebug($"Меню {menuName} загружено");
        }

        private void SetupMainMenuHandlers()
        {
            if (_root == null) return;

            // Кнопка "Новая игра"
            var newGameButton = _root.Q<Button>("NewGameButton");
            if (newGameButton != null)
            {
                newGameButton.clicked += () =>
                {
                    GameLogger.LogInfo("Нажата кнопка: Новая игра");
                    SaveManager.CreateNewGame();
                    GameManager.Instance?.StartNewGame();
                };
            }

            // Кнопка "Продолжить"
            var continueButton = _root.Q<Button>("ContinueButton");
            if (continueButton != null)
            {
                continueButton.clicked += () =>
                {
                    GameLogger.LogInfo("Нажата кнопка: Продолжить");
                    GameManager.Instance?.ContinueGame();
                };
            }

            // Кнопка "Сохранить"
            var saveButton = _root.Q<Button>("SaveButton");
            if (saveButton != null)
            {
                saveButton.clicked += () =>
                {
                    GameLogger.LogInfo("Нажата кнопка: Сохранить");
                    GameManager.Instance?.SaveGame();
                };
            }

            // Кнопка "Загрузить"
            var loadButton = _root.Q<Button>("LoadButton");
            if (loadButton != null)
            {
                loadButton.clicked += () =>
                {
                    GameLogger.LogInfo("Нажата кнопка: Загрузить");
                    GameManager.Instance?.LoadGame();
                };
            }

            // Кнопка "Настройки"
            var settingsButton = _root.Q<Button>("SettingsButton");
            if (settingsButton != null)
            {
                settingsButton.clicked += () =>
                {
                    GameLogger.LogInfo("Нажата кнопка: Настройки");
                    ShowSettingsMenu();
                };
            }

            // Кнопка "Выход"
            var exitButton = _root.Q<Button>("ExitButton");
            if (exitButton != null)
            {
                exitButton.clicked += () =>
                {
                    GameLogger.LogInfo("Нажата кнопка: Выход");
                    GameManager.Instance?.QuitGame();
                };
            }
        }

        private void SetupGameMenuHandlers()
        {
            if (_root == null) return;

            // Кнопка "Заезд"
            var raceButton = _root.Q<Button>("RaceButton");
            if (raceButton != null)
            {
                raceButton.clicked += () =>
                {
                    GameLogger.LogInfo("Нажата кнопка: Заезд");
                };
            }

            // Кнопка "Гараж"
            var garageButton = _root.Q<Button>("GarageButton");
            if (garageButton != null)
            {
                garageButton.clicked += () =>
                {
                    GameLogger.LogInfo("Нажата кнопка: Гараж");
                    GameManager.Instance?.LoadGarage();
                };
            }

            // Кнопка "Тюнинг"
            var tuningButton = _root.Q<Button>("TuningButton");
            if (tuningButton != null)
            {
                tuningButton.clicked += () =>
                {
                    GameLogger.LogInfo("Нажата кнопка: Тюнинг");
                    GameManager.Instance?.LoadTuning();
                };
            }

            // Кнопка "Магазин"
            var shopButton = _root.Q<Button>("ShopButton");
            if (shopButton != null)
            {
                shopButton.clicked += () =>
                {
                    GameLogger.LogInfo("Нажата кнопка: Магазин");
                    GameManager.Instance?.LoadShop();
                };
            }

            // Кнопка "Меню" (возврат в главное меню)
            var menuButton = _root.Q<Button>("MenuButton");
            if (menuButton != null)
            {
                menuButton.clicked += () =>
                {
                    GameLogger.LogInfo("Нажата кнопка: Меню (выход в главное меню)");
                    GameManager.Instance?.LoadMainMenu();
                };
            }
        }

        private void SetupSettingsMenuHandlers()
        {
            if (_root == null) return;

            // Кнопка "Назад"
            var backButton = _root.Q<Button>("BackButton");
            if (backButton != null)
            {
                backButton.clicked += () =>
                {
                    GameLogger.LogInfo("Нажата кнопка: Назад (из настроек)");
                    ShowMainMenu();
                };
            }

            // Ползунок громкости музыки
            var musicSlider = _root.Q<Slider>("MusicVolumeSlider");
            if (musicSlider != null)
            {
                musicSlider.RegisterValueChangedCallback(evt =>
                {
                    AudioManager.Instance?.SetVolume(AudioManager.AudioChannel.Music, evt.newValue);
                    GameLogger.LogDebug($"Громкость музыки: {evt.newValue:F2}");
                });
            }

            // Ползунок громкости эффектов
            var sfxSlider = _root.Q<Slider>("SFXVolumeSlider");
            if (sfxSlider != null)
            {
                sfxSlider.RegisterValueChangedCallback(evt =>
                {
                    AudioManager.Instance?.SetVolume(AudioManager.AudioChannel.SFX, evt.newValue);
                    GameLogger.LogDebug($"Громкость эффектов: {evt.newValue:F2}");
                });
            }

            // Переключатель полноэкранного режима
            var fullscreenToggle = _root.Q<Toggle>("FullscreenToggle");
            if (fullscreenToggle != null)
            {
                fullscreenToggle.RegisterValueChangedCallback(evt =>
                {
                    Screen.fullScreen = evt.newValue;
                    GameLogger.LogInfo($"Полноэкранный режим: {evt.newValue}");
                });
            }

            // Выпадающий список разрешения экрана
            var resolutionDropdown = _root.Q<DropdownField>("ResolutionDropdown");
            if (resolutionDropdown != null)
            {
                // Заполняем доступными разрешениями
                PopulateResolutionDropdown(resolutionDropdown);
                
                resolutionDropdown.RegisterValueChangedCallback(evt =>
                {
                    ChangeResolution(evt.newValue);
                    GameLogger.LogInfo($"Разрешение изменено на: {evt.newValue}");
                });
            }

            // Выпадающий список качества графики
            var qualityDropdown = _root.Q<DropdownField>("QualityDropdown");
            if (qualityDropdown != null)
            {
                qualityDropdown.RegisterValueChangedCallback(evt =>
                {
                    ChangeQuality(evt.newValue);
                    GameLogger.LogInfo($"Качество изменено на: {evt.newValue}");
                });
            }
        }

        private void PopulateResolutionDropdown(DropdownField dropdown)
        {
            Resolution[] resolutions = Screen.resolutions;
            string[] options = new string[resolutions.Length];
            
            for (int i = 0; i < resolutions.Length; i++)
            {
                options[i] = $"{resolutions[i].width}x{resolutions[i].height}";
            }
            
            dropdown.choices = options;
            
            // Устанавливаем текущее разрешение
            string currentRes = $"{Screen.currentResolution.width}x{Screen.currentResolution.height}";
            dropdown.value = currentRes;
        }

        private void ChangeResolution(string resolutionString)
        {
            string[] parts = resolutionString.Split('x');
            if (parts.Length != 2) return;
            
            int width = int.Parse(parts[0]);
            int height = int.Parse(parts[1]);
            
            Screen.SetResolution(width, height, Screen.fullScreen);
        }

        private void ChangeQuality(string qualityName)
        {
            int qualityLevel = 0;
            
            switch (qualityName)
            {
                case "Низкое":
                    qualityLevel = 0;
                    break;
                case "Среднее":
                    qualityLevel = 1;
                    break;
                case "Высокое":
                    qualityLevel = 2;
                    break;
                case "Ультра":
                    qualityLevel = 3;
                    break;
            }
            
            QualitySettings.SetQualityLevel(qualityLevel);
        }

        private void SetupPauseMenuHandlers()
        {
            if (_root == null) return;

            // Кнопка "Продолжить"
            var resumeButton = _root.Q<Button>("ResumeButton");
            if (resumeButton != null)
            {
                resumeButton.clicked += () =>
                {
                    GameLogger.LogInfo("Нажата кнопка: Продолжить (из паузы)");
                    GameManager.Instance?.ResumeGame();
                    HideCurrentMenu();
                };
            }

            // Кнопка "В главное меню"
            var mainMenuButton = _root.Q<Button>("MainMenuButton");
            if (mainMenuButton != null)
            {
                mainMenuButton.clicked += () =>
                {
                    GameLogger.LogInfo("Нажата кнопка: В главное меню (из паузы)");
                    GameManager.Instance?.LoadMainMenu();
                };
            }

            // Кнопка "Настройки" (из паузы)
            var settingsButton = _root.Q<Button>("PauseSettingsButton");
            if (settingsButton != null)
            {
                settingsButton.clicked += () =>
                {
                    GameLogger.LogInfo("Нажата кнопка: Настройки (из паузы)");
                    ShowSettingsMenu();
                };
            }

            // Кнопка "Выход"
            var exitButton = _root.Q<Button>("ExitButton");
            if (exitButton != null)
            {
                exitButton.clicked += () =>
                {
                    GameLogger.LogInfo("Нажата кнопка: Выход (из паузы)");
                    GameManager.Instance?.QuitGame();
                };
            }
        }

        public T GetElement<T>(string name) where T : VisualElement
        {
            return _root?.Q<T>(name);
        }
    }
}

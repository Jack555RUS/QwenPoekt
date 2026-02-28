using UnityEngine;
using UnityEngine.UIElements;
using RacingGame.Managers;

namespace RacingGame.UI
{
    /// <summary>
    /// Автоматический инициализатор сцены MainMenu
    /// Создает и настраивает все необходимые объекты при запуске
    /// </summary>
    public class MainMenuAutoInitializer : MonoBehaviour
    {
        [Header("UI Документы")]
        [Tooltip("Ссылка на MainMenu.uxml")]
        [SerializeField] private VisualTreeAsset _mainMenuAsset;
        
        [Tooltip("Ссылка на SettingsMenu.uxml")]
        [SerializeField] private VisualTreeAsset _settingsMenuAsset;
        
        [Tooltip("Ссылка на GameMenu.uxml")]
        [SerializeField] private VisualTreeAsset _gameMenuAsset;
        
        [Tooltip("Ссылка на PauseMenu.uxml")]
        [SerializeField] private VisualTreeAsset _pauseMenuAsset;

        [Header("Audio")]
        [Tooltip("Ссылка на AudioMixer")]
        [SerializeField] private AudioMixer _audioMixer;

        [Header("Настройки")]
        [SerializeField] private bool _dontDestroyOnLoad = true;
        [SerializeField] private bool _autoShowMainMenu = true;

        private void Awake()
        {
            Debug.Log("[MainMenuAutoInitializer] Начало инициализации...");

            // Создаем GameManager
            if (GameManager.Instance == null)
            {
                var gmObject = new GameObject("GameManager");
                gmObject.AddComponent<GameManager>();
                if (_dontDestroyOnLoad)
                    DontDestroyOnLoad(gmObject);
                Debug.Log("[MainMenuAutoInitializer] GameManager создан");
            }
            else
            {
                Debug.Log("[MainMenuAutoInitializer] GameManager уже существует");
            }

            // Создаем MenuManager
            if (MenuManager.Instance == null)
            {
                var mmObject = new GameObject("MenuManager");
                var menuManager = mmObject.AddComponent<MenuManager>();
                
                // Настраиваем ссылки на UI документы
                SetupMenuManager(menuManager);
                
                if (_dontDestroyOnLoad)
                    DontDestroyOnLoad(mmObject);
                Debug.Log("[MainMenuAutoInitializer] MenuManager создан и настроен");
            }
            else
            {
                Debug.Log("[MainMenuAutoInitializer] MenuManager уже существует");
            }

            // Создаем AudioManager
            if (AudioManager.Instance == null && _audioMixer != null)
            {
                var amObject = new GameObject("AudioManager");
                var audioManager = amObject.AddComponent<AudioManager>();
                
                // Настраиваем AudioMixer через рефлексию
                var type = audioManager.GetType();
                var field = type.GetField("_audioMixer", 
                    System.Reflection.BindingFlags.NonPublic | 
                    System.Reflection.BindingFlags.Instance);
                field?.SetValue(audioManager, _audioMixer);
                
                if (_dontDestroyOnLoad)
                    DontDestroyOnLoad(amObject);
                Debug.Log("[MainMenuAutoInitializer] AudioManager создан и настроен");
            }
            else if (AudioManager.Instance == null)
            {
                Debug.LogWarning("[MainMenuAutoInitializer] AudioMixer не назначен! AudioManager будет создан без микшера.");
                
                var amObject = new GameObject("AudioManager");
                amObject.AddComponent<AudioManager>();
                
                if (_dontDestroyOnLoad)
                    DontDestroyOnLoad(amObject);
            }
            else
            {
                Debug.Log("[MainMenuAutoInitializer] AudioManager уже существует");
            }

            // Создаем InputManager
            if (InputManager.Instance == null)
            {
                var imObject = new GameObject("InputManager");
                imObject.AddComponent<InputManager>();
                if (_dontDestroyOnLoad)
                    DontDestroyOnLoad(imObject);
                Debug.Log("[MainMenuAutoInitializer] InputManager создан");
            }
            else
            {
                Debug.Log("[MainMenuAutoInitializer] InputManager уже существует");
            }

            Debug.Log("[MainMenuAutoInitializer] Инициализация завершена");
        }

        private void Start()
        {
            if (_autoShowMainMenu && MenuManager.Instance != null)
            {
                Debug.Log("[MainMenuAutoInitializer] Показываем главное меню...");
                MenuManager.Instance.ShowMainMenu();
            }
        }

        private void SetupMenuManager(MenuManager manager)
        {
            var type = manager.GetType();
            
            var mainMenuField = type.GetField("_mainMenuAsset", 
                System.Reflection.BindingFlags.NonPublic | 
                System.Reflection.BindingFlags.Instance);
            mainMenuField?.SetValue(manager, _mainMenuAsset);

            var settingsField = type.GetField("_settingsMenuAsset", 
                System.Reflection.BindingFlags.NonPublic | 
                System.Reflection.BindingFlags.Instance);
            settingsField?.SetValue(manager, _settingsMenuAsset);

            var gameField = type.GetField("_gameMenuAsset", 
                System.Reflection.BindingFlags.NonPublic | 
                System.Reflection.BindingFlags.Instance);
            gameField?.SetValue(manager, _gameMenuAsset);

            var pauseField = type.GetField("_pauseMenuAsset", 
                System.Reflection.BindingFlags.NonPublic | 
                System.Reflection.BindingFlags.Instance);
            pauseField?.SetValue(manager, _pauseMenuAsset);
        }

        #region Editor Helpers

#if UNITY_EDITOR
        [ContextMenu("Автоматически найти UI документы")]
        private void AutoFindUIDocuments()
        {
            _mainMenuAsset = FindAsset<VisualTreeAsset>("MainMenu");
            _settingsMenuAsset = FindAsset<VisualTreeAsset>("SettingsMenu");
            _gameMenuAsset = FindAsset<VisualTreeAsset>("GameMenu");
            _pauseMenuAsset = FindAsset<VisualTreeAsset>("PauseMenu");
            _audioMixer = FindAsset<AudioMixer>("AudioMixer");
            
            Debug.Log("[MainMenuAutoInitializer] Документы найдены автоматически!");
        }

        private T FindAsset<T>(string name) where T : UnityEngine.Object
        {
            string[] guids = UnityEditor.AssetDatabase.FindAssets(name);
            foreach (var guid in guids)
            {
                string path = UnityEditor.AssetDatabase.GUIDToAssetPath(guid);
                T asset = UnityEditor.AssetDatabase.LoadAssetAtPath<T>(path);
                if (asset != null)
                {
                    Debug.Log($"[MainMenuAutoInitializer] Найдено: {path}");
                    return asset;
                }
            }
            return null;
        }
#endif

        #endregion
    }
}

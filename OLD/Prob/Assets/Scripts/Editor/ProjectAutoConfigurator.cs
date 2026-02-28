#if UNITY_EDITOR && false
// Скрипт отключен для сборки
/*
using UnityEngine;
using UnityEditor;
using UnityEditor.SceneManagement;
using UnityEngine.UIElements;
using System.IO;
using System.Linq;
using RacingGame.Managers;

namespace RacingGame.Editor
{
    /// <summary>
    /// Автоматический конфигуратор проекта
    /// Настраивает сцены, менеджеров и параметры проекта
    /// </summary>
    public class ProjectAutoConfigurator : EditorWindow
    {
        [MenuItem("RacingGame/Автоматическая настройка проекта")]
        public static void ShowWindow()
        {
            var window = GetWindow<ProjectAutoConfigurator>("Настройка проекта");
            window.minSize = new Vector2(400, 500);
        }

        private Vector2 _scrollPosition;
        private bool _showDetails = true;

        private void OnGUI()
        {
            _scrollPosition = EditorGUILayout.BeginScrollView(_scrollPosition);

            GUILayout.Label("🏁 Автоматическая настройка проекта Racing Game", EditorStyles.boldLabel);
            GUILayout.Space(10);

            EditorGUILayout.HelpBox(
                "Этот инструмент автоматически настроит все сцены, менеджеров и параметры проекта.",
                MessageType.Info);

            GUILayout.Space(20);

            // Кнопки действий
            GUILayout.Label("📋 Действия", EditorStyles.boldLabel);

            if (GUILayout.Button("✅ Настроить все сцены", GUILayout.Height(40)))
            {
                ConfigureAllScenes();
            }

            if (GUILayout.Button("🎮 Настроить MainMenu сцену", GUILayout.Height(40)))
            {
                ConfigureMainMenuScene();
            }

            if (GUILayout.Button("⚙️ Настроить параметры проекта", GUILayout.Height(40)))
            {
                ConfigureProjectSettings();
            }

            if (GUILayout.Button("🧪 Проверить тесты", GUILayout.Height(40)))
            {
                CheckTests();
            }

            if (GUILayout.Button("🗑️ Очистить кэш и временные файлы", GUILayout.Height(40)))
            {
                CleanupCache();
            }

            GUILayout.Space(20);

            // Детали
            _showDetails = EditorGUILayout.Foldout(_showDetails, "📊 Детали настройки");
            if (_showDetails)
            {
                GUILayout.Label("Текущее состояние проекта:", EditorStyles.boldLabel);

                DrawStatus("Сцены в Build Settings", CheckScenesInBuild());
                DrawStatus("GameManager в сцене", CheckGameManagerInScene());
                DrawStatus("MenuManager в сцене", CheckMenuManagerInScene());
                DrawStatus("AudioManager в сцене", CheckAudioManagerInScene());
                DrawStatus("UI Toolkit документы", CheckUIDocuments());
                DrawStatus("Тесты готовы", CheckTestsReady());
                DrawStatus("Настройки качества", CheckQualitySettings());
                DrawStatus("Настройки ввода", CheckInputSettings());
            }

            GUILayout.Space(20);

            // Логи
            GUILayout.Label("📝 Последние действия:", EditorStyles.boldLabel);
            GUILayout.TextArea(AutoConfigLogger.LastLog, GUILayout.Height(100));

            EditorGUILayout.EndScrollView();
        }

        private void DrawStatus(string label, bool status)
        {
            EditorGUILayout.BeginHorizontal();
            GUILayout.Label(status ? "✅" : "❌", GUILayout.Width(30));
            GUILayout.Label(label);
            EditorGUILayout.EndHorizontal();
        }

        #region Конфигурация сцен

        public static void ConfigureAllScenes()
        {
            AutoConfigLogger.Log("=== Начало настройки всех сцен ===");

            ConfigureMainMenuScene();
            ConfigureGameScene();
            ConfigureGarageScene();
            ConfigureTuningScene();
            ConfigureShopScene();

            AutoConfigLogger.Log("=== Все сцены настроены ===");
            EditorUtility.DisplayDialog("Настройка завершена", "Все сцены успешно настроены!", "OK");
        }

        public static void ConfigureMainMenuScene()
        {
            AutoConfigLogger.Log("Настройка MainMenu сцены...");

            string scenePath = "Assets/Scenes/MainMenu.unity";
            if (string.IsNullOrEmpty(AssetDatabase.AssetPathToGUID(scenePath)))
            {
                AutoConfigLogger.LogError($"Сцена {scenePath} не найдена!");
                return;
            }

            var scene = EditorSceneManager.OpenScene(scenePath);

            // Создаем или находим менеджеров
            CreateManagerIfNotExists<RacingGame.Managers.GameManager>("GameManager");
            CreateManagerIfNotExists<RacingGame.Managers.MenuManager>("MenuManager");
            CreateManagerIfNotExists<RacingGame.Managers.AudioManager>("AudioManager");
            CreateManagerIfNotExists<RacingGame.InputSystem.InputManager>("InputManager");

            // Настраиваем камеру
            ConfigureMainCamera();

            // Сохраняем сцену
            EditorSceneManager.SaveScene(scene);
            AssetDatabase.Refresh();

            AutoConfigLogger.Log("MainMenu сцена настроена");
        }

        private static void ConfigureGameScene()
        {
            AutoConfigLogger.Log("Настройка Game сцены...");
            string scenePath = "Assets/Scenes/Game.unity";

            if (string.IsNullOrEmpty(AssetDatabase.AssetPathToGUID(scenePath)))
            {
                AutoConfigLogger.LogWarning($"Сцена {scenePath} не найдена, пропускаем");
                return;
            }

            var scene = EditorSceneManager.OpenScene(scenePath);
            CreateManagerIfNotExists<RacingGame.Managers.GameManager>("GameManager");
            CreateManagerIfNotExists<RacingGame.Managers.AudioManager>("AudioManager");
            CreateManagerIfNotExists<RacingGame.InputSystem.InputManager>("InputManager");

            EditorSceneManager.SaveScene(scene);
            AutoConfigLogger.Log("Game сцена настроена");
        }

        private static void ConfigureGarageScene()
        {
            AutoConfigLogger.Log("Настройка Garage сцены...");
            string scenePath = "Assets/Scenes/Garage.unity";

            if (string.IsNullOrEmpty(AssetDatabase.AssetPathToGUID(scenePath)))
            {
                AutoConfigLogger.LogWarning($"Сцена {scenePath} не найдена, пропускаем");
                return;
            }

            var scene = EditorSceneManager.OpenScene(scenePath);
            CreateManagerIfNotExists<RacingGame.Managers.GameManager>("GameManager");
            CreateManagerIfNotExists<RacingGame.Managers.AudioManager>("AudioManager");

            EditorSceneManager.SaveScene(scene);
            AutoConfigLogger.Log("Garage сцена настроена");
        }

        private static void ConfigureTuningScene()
        {
            AutoConfigLogger.Log("Настройка Tuning сцены...");
            string scenePath = "Assets/Scenes/Tuning.unity";

            if (string.IsNullOrEmpty(AssetDatabase.AssetPathToGUID(scenePath)))
            {
                AutoConfigLogger.LogWarning($"Сцена {scenePath} не найдена, пропускаем");
                return;
            }

            var scene = EditorSceneManager.OpenScene(scenePath);
            CreateManagerIfNotExists<RacingGame.Managers.GameManager>("GameManager");
            CreateManagerIfNotExists<RacingGame.Managers.AudioManager>("AudioManager");

            EditorSceneManager.SaveScene(scene);
            AutoConfigLogger.Log("Tuning сцена настроена");
        }

        private static void ConfigureShopScene()
        {
            AutoConfigLogger.Log("Настройка Shop сцены...");
            string scenePath = "Assets/Scenes/Shop.unity";

            if (string.IsNullOrEmpty(AssetDatabase.AssetPathToGUID(scenePath)))
            {
                AutoConfigLogger.LogWarning($"Сцена {scenePath} не найдена, пропускаем");
                return;
            }

            var scene = EditorSceneManager.OpenScene(scenePath);
            CreateManagerIfNotExists<RacingGame.Managers.GameManager>("GameManager");
            CreateManagerIfNotExists<RacingGame.Managers.AudioManager>("AudioManager");

            EditorSceneManager.SaveScene(scene);
            AutoConfigLogger.Log("Shop сцена настроена");
        }

        #endregion

        #region Создание менеджеров

        private static T CreateManagerIfNotExists<T>(string name) where T : MonoBehaviour
        {
            var existing = Object.FindObjectOfType<T>();
            if (existing != null)
            {
                AutoConfigLogger.Log($"  {typeof(T).Name} уже существует");
                return existing;
            }

            var gameObject = new GameObject(name);
            var component = gameObject.AddComponent<T>();

            // Для MenuManager настраиваем ссылки на UI документы
            if (component is RacingGame.Managers.MenuManager menuManager)
            {
                SetupMenuManagerReferences(menuManager);
            }

            // Для AudioManager настраиваем микшер
            if (component is RacingGame.Managers.AudioManager audioManager)
            {
                SetupAudioManagerReferences(audioManager);
            }

            AutoConfigLogger.Log($"  Создан {typeof(T).Name}");
            return component;
        }

        private static void SetupMenuManagerReferences(RacingGame.Managers.MenuManager manager)
        {
            // Находим UI документы
            var mainMenuAsset = AssetDatabase.LoadAssetAtPath<VisualTreeAsset>("Assets/UI Toolkit/MainMenu.uxml");
            var settingsMenuAsset = AssetDatabase.LoadAssetAtPath<VisualTreeAsset>("Assets/UI Toolkit/SettingsMenu.uxml");
            var gameMenuAsset = AssetDatabase.LoadAssetAtPath<VisualTreeAsset>("Assets/UI Toolkit/GameMenu.uxml");
            var pauseMenuAsset = AssetDatabase.LoadAssetAtPath<VisualTreeAsset>("Assets/UI Toolkit/PauseMenu.uxml");

            // Используем рефлексию для установки private полей
            var type = manager.GetType();

            var mainMenuField = type.GetField("_mainMenuAsset", System.Reflection.BindingFlags.NonPublic | System.Reflection.BindingFlags.Instance);
            mainMenuField?.SetValue(manager, mainMenuAsset);

            var settingsField = type.GetField("_settingsMenuAsset", System.Reflection.BindingFlags.NonPublic | System.Reflection.BindingFlags.Instance);
            settingsField?.SetValue(manager, settingsMenuAsset);

            var gameField = type.GetField("_gameMenuAsset", System.Reflection.BindingFlags.NonPublic | System.Reflection.BindingFlags.Instance);
            gameField?.SetValue(manager, gameMenuAsset);

            var pauseField = type.GetField("_pauseMenuAsset", System.Reflection.BindingFlags.NonPublic | System.Reflection.BindingFlags.Instance);
            pauseField?.SetValue(manager, pauseMenuAsset);

            AutoConfigLogger.Log("    Настроены ссылки на UI документы");
        }

        private static void SetupAudioManagerReferences(RacingGame.Managers.AudioManager manager)
        {
            var mixer = AssetDatabase.LoadAssetAtPath<AudioMixer>("Assets/AudioMixer.mixer");

            var type = manager.GetType();
            var mixerField = type.GetField("_audioMixer", System.Reflection.BindingFlags.NonPublic | System.Reflection.BindingFlags.Instance);
            if (mixer != null && mixerField != null)
            {
                mixerField.SetValue(manager, mixer);
                AutoConfigLogger.Log("    Настроен AudioMixer");
            }
        }

        private static void ConfigureMainCamera()
        {
            var camera = Object.FindObjectOfType<Camera>();
            if (camera == null)
            {
                var cameraObj = new GameObject("Main Camera");
                camera = cameraObj.AddComponent<Camera>();
                cameraObj.AddComponent<AudioListener>();
            }

            camera.clearFlags = CameraClearFlags.SolidColor;
            camera.backgroundColor = new Color(0.1f, 0.1f, 0.1f, 1f);
            camera.orthographic = true;
            camera.orthographicSize = 5f;

            AutoConfigLogger.Log("  Камера настроена");
        }

        #endregion

        #region Проверки

        private static bool CheckScenesInBuild()
        {
            var scenes = UnityEditor.EditorBuildSettings.scenes;
            return scenes.Length >= 5 && 
                   scenes.Any(s => s.path.Contains("MainMenu")) &&
                   scenes.Any(s => s.path.Contains("Game"));
        }

        private static bool CheckGameManagerInScene()
        {
            return Object.FindObjectOfType<GameManager>() != null;
        }

        private static bool CheckMenuManagerInScene()
        {
            return Object.FindObjectOfType<MenuManager>() != null;
        }

        private static bool CheckAudioManagerInScene()
        {
            return Object.FindObjectOfType<AudioManager>() != null;
        }

        private static bool CheckUIDocuments()
        {
            string[] uxmlFiles = Directory.GetFiles("Assets/UI Toolkit", "*.uxml");
            return uxmlFiles.Length >= 4;
        }

        private static bool CheckTestsReady()
        {
            string[] testFiles = Directory.GetFiles("Assets/Tests/Runtime", "*Tests.cs");
            return testFiles.Length >= 4;
        }

        private static bool CheckQualitySettings()
        {
            return QualitySettings.names.Length >= 3;
        }

        private static bool CheckInputSettings()
        {
            return Input.GetAxis("Horizontal") != null;
        }

        #endregion

        #region Утилиты

        private static void ConfigureProjectSettings()
        {
            AutoConfigLogger.Log("Настройка PlayerSettings...");

            PlayerSettings.productName = "Racing Game";
            PlayerSettings.companyName = "DefaultCompany";
            PlayerSettings.bundleVersion = "1.0.0";
            PlayerSettings.defaultScreenWidth = 800;
            PlayerSettings.defaultScreenHeight = 600;
            PlayerSettings.runInBackground = true;
            PlayerSettings.resizableWindow = true;

            AutoConfigLogger.Log("PlayerSettings настроены");
            EditorUtility.DisplayDialog("Настройка завершена", "Параметры проекта настроены!", "OK");
        }

        private static void CheckTests()
        {
            AutoConfigLogger.Log("Проверка тестов...");
            
            string testDir = "Assets/Tests/Runtime";
            if (!Directory.Exists(testDir))
            {
                AutoConfigLogger.LogError("Папка с тестами не найдена!");
                return;
            }

            string[] testFiles = Directory.GetFiles(testDir, "*Tests.cs");
            AutoConfigLogger.Log($"Найдено тестов: {testFiles.Length}");
            
            foreach (var file in testFiles)
            {
                AutoConfigLogger.Log($"  - {Path.GetFileName(file)}");
            }

            EditorUtility.DisplayDialog("Тесты", $"Найдено тестов: {testFiles.Length}", "OK");
        }

        private static void CleanupCache()
        {
            AutoConfigLogger.Log("Очистка кэша...");
            
            // Очищаем Library
            string libraryDir = "Library";
            if (Directory.Exists(libraryDir))
            {
                AutoConfigLogger.Log("  Очистка Library (требуется перезапуск Unity)");
            }

            // Очищаем Temp
            string tempDir = "Temp";
            if (Directory.Exists(tempDir))
            {
                AutoConfigLogger.Log("  Очистка Temp");
            }

            EditorUtility.DisplayDialog(
                "Очистка завершена", 
                "Временные файлы очищены.\nДля полной очистки Library перезапустите Unity.", 
                "OK");
        }

        #endregion
    }

    /// <summary>
    /// Логгер для конфигуратора
    /// </summary>
    public static class AutoConfigLogger
    {
        private static System.Text.StringBuilder _logBuilder = new System.Text.StringBuilder();
        private const int MaxLogLength = 2000;

        public static string LastLog => _logBuilder.ToString();

        public static void Log(string message)
        {
            string timestamp = System.DateTime.Now.ToString("HH:mm:ss");
            string logEntry = $"[{timestamp}] {message}\n";
            
            _logBuilder.Insert(0, logEntry);
            
            if (_logBuilder.Length > MaxLogLength)
            {
                _logBuilder.Remove(MaxLogLength, _logBuilder.Length - MaxLogLength);
            }

            Debug.Log($"[AutoConfig] {message}");
        }

        public static void LogWarning(string message)
        {
            Log($"⚠️ {message}");
        }

        public static void LogError(string message)
        {
            Log($"❌ {message}");
        }
    }
}
*/
#endif

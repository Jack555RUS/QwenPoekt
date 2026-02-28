using UnityEngine;
using UnityEngine.UI;

namespace DragRace.Core
{
    /// <summary>
    /// Настройки игры при запуске
    /// </summary>
    public class GameSettings : MonoBehaviour
    {
        [Header("Настройки окна")]
        [Tooltip("Запускать в оконном режиме")]
        public bool windowedMode = true;
        
        [Tooltip("Ширина окна")]
        public int screenWidth = 1280;
        
        [Tooltip("Высота окна")]
        public int screenHeight = 720;
        
        [Header("Логирование")]
        [Tooltip("Включить детальное логирование")]
        public bool verboseLogging = true;
        
        [Header("Автотесты")]
        [Tooltip("Запускать автотесты при старте")]
        public bool runAutoTests = true;
        
        private void Awake()
        {
            // Не уничтожать при загрузке сцены
            DontDestroyOnLoad(gameObject);
            
            // СРАЗУ применяем настройки в Awake
            ApplySettings();
            
            Debug.Log("===========================================");
            Debug.Log("🔵 [GameSettings] Awake - настройки применены");
            Debug.Log($"🖥️ Fullscreen: {Screen.fullScreen}");
            Debug.Log($"📊 Resolution: {Screen.width}x{Screen.height}");
            Debug.Log("===========================================");
        }
        
        private void Start()
        {
            // Запускаем логирование
            if (verboseLogging)
            {
                StartLogging();
            }
            
            // Запускаем автотесты
            if (runAutoTests)
            {
                Invoke(nameof(RunAutoTests), 2f);
            }
        }
        
        private void ApplySettings()
        {
            if (windowedMode)
            {
                Screen.fullScreen = false;
                Screen.SetResolution(screenWidth, screenHeight, false);
                
                Debug.Log($"✅ Оконный режим: {screenWidth}x{screenHeight}");
            }
            else
            {
                Screen.fullScreen = true;
                Debug.Log("✅ Полноэкранный режим");
            }
        }
        
        private void StartLogging()
        {
            Debug.Log("===========================================");
            Debug.Log("🔧 GAME SETTINGS INITIALIZED");
            Debug.Log("===========================================");
            Debug.Log($"📊 Resolution: {Screen.width}x{Screen.height}");
            Debug.Log($"🖥️ Fullscreen: {Screen.fullScreen}");
            Debug.Log($"🎮 Target FPS: {Application.targetFrameRate}");
            Debug.Log($"💾 Data Path: {Application.dataPath}");
            Debug.Log($"📁 Persistent Path: {Application.persistentDataPath}");
            Debug.Log("===========================================");
        }
        
        private void RunAutoTests()
        {
            Debug.Log("===========================================");
            Debug.Log("🧪 ЗАПУСК АВТОТЕСТОВ");
            Debug.Log("===========================================");
            
            // Тест 1: Проверка Canvas
            var canvas = FindFirstObjectByType<Canvas>();
            if (canvas != null)
            {
                Debug.Log("✅ ТЕСТ 1: Canvas найден");
            }
            else
            {
                Debug.LogError("❌ ТЕСТ 1: Canvas НЕ найден!");
            }
            
            // Тест 2: Проверка кнопок
            var buttons = FindObjectsByType<Button>(FindObjectsSortMode.None);
            Debug.Log($"✅ ТЕСТ 2: Найдено кнопок: {buttons.Length}");
            
            foreach (var button in buttons)
            {
                Debug.Log($"   - {button.name} (Interactable: {button.interactable})");
            }
            
            // Тест 3: Проверка EventSystem
            var eventSystem = FindFirstObjectByType<UnityEngine.EventSystems.EventSystem>();
            if (eventSystem != null)
            {
                Debug.Log("✅ ТЕСТ 3: EventSystem найден");
            }
            else
            {
                Debug.LogError("❌ ТЕСТ 3: EventSystem НЕ найден!");
            }
            
            // Тест 4: Проверка разрешения
            Debug.Log($"✅ ТЕСТ 4: Разрешение экрана: {Screen.width}x{Screen.height}");
            
            // Тест 5: Проверка FPS
            Debug.Log($"✅ ТЕСТ 5: FPS: {1f / Time.unscaledDeltaTime:F1}");
            
            Debug.Log("===========================================");
            Debug.Log("🏁 АВТОТЕСТЫ ЗАВЕРШЕНЫ");
            Debug.Log("===========================================");
        }
        
        private void OnApplicationQuit()
        {
            Debug.Log("===========================================");
            Debug.Log("👋 GAME QUIT");
            Debug.Log("===========================================");
        }
        
        private void OnApplicationPause(bool pause)
        {
            if (pause)
            {
                Debug.Log("⏸️ GAME PAUSED");
            }
            else
            {
                Debug.Log("▶️ GAME RESUMED");
            }
        }
    }
}

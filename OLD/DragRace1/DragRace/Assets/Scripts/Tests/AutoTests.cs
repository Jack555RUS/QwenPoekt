using UnityEngine;
using UnityEngine.UI;

namespace DragRace.Tests
{
    /// <summary>
    /// Автоматические тесты при запуске игры
    /// </summary>
    public class AutoTests : MonoBehaviour
    {
        [Header("Настройки")]
        public bool runOnStart = true;
        public float delayBeforeTests = 2f;
        
        [Header("Результаты")]
        public int testsPassed = 0;
        public int testsFailed = 0;
        
        private void Start()
        {
            if (runOnStart)
            {
                Invoke(nameof(RunAllTests), delayBeforeTests);
            }
        }
        
        private void RunAllTests()
        {
            Debug.Log("╔══════════════════════════════════════════════════════════╗");
            Debug.Log("║         🧪 АВТОМАТИЧЕСКИЕ ТЕСТЫ ЗАПУЩЕНЫ                 ║");
            Debug.Log("╚══════════════════════════════════════════════════════════╝");
            
            testsPassed = 0;
            testsFailed = 0;
            
            // Тест 1: Canvas
            Test_CanvasExists();
            
            // Тест 2: EventSystem
            Test_EventSystemExists();
            
            // Тест 3: Кнопки
            Test_ButtonsExist();
            
            // Тест 4: StartButton
            Test_StartButton();
            
            // Тест 5: GraphicRaycaster
            Test_GraphicRaycaster();
            
            // Тест 6: Разрешение
            Test_Resolution();
            
            // Тест 7: Кнопка START интерактивна
            Test_StartButtonInteractable();
            
            // Тест 8: Image на кнопке
            Test_ButtonImage();
            
            // Тест 9: Слушатели кнопки
            Test_ButtonListeners();
            
            // Тест 10: Сцены в билде
            Test_ScenesInBuild();
            
            // Финальный отчёт
            Debug.Log("╔══════════════════════════════════════════════════════════╗");
            Debug.Log("║                    🏁 ИТОГОВЫЙ ОТЧЁТ                      ║");
            Debug.Log("╠══════════════════════════════════════════════════════════╣");
            Debug.Log($"║  ✅ Пройдено: {testsPassed,3}                                           ║");
            Debug.Log($"║  ❌ Провалено: {testsFailed,3}                                          ║");
            Debug.Log($"║  📊 Всего: {testsPassed + testsFailed,3}                                              ║");
            Debug.Log($"║  📈 Процент: {(testsPassed + testsFailed > 0 ? (float)testsPassed / (testsPassed + testsFailed) * 100 : 0),5:F1}%                              ║");
            Debug.Log("╚══════════════════════════════════════════════════════════╝");
            
            if (testsFailed == 0)
            {
                Debug.Log("✅✅✅ ВСЕ ТЕСТЫ ПРОЙДЕНЫ! ✅✅✅");
            }
            else
            {
                Debug.LogWarning($"⚠️ {testsFailed} тестов провалено! Требуется исправление!");
            }
        }
        
        private void Test_CanvasExists()
        {
            var canvas = FindFirstObjectByType<Canvas>();
            
            if (canvas != null)
            {
                PassTest($"Canvas найден: {canvas.name}");
            }
            else
            {
                FailTest("Canvas НЕ найден!");
            }
        }
        
        private void Test_EventSystemExists()
        {
            var eventSystem = FindFirstObjectByType<UnityEngine.EventSystems.EventSystem>();
            
            if (eventSystem != null)
            {
                PassTest($"EventSystem найден: {eventSystem.name}");
            }
            else
            {
                FailTest("EventSystem НЕ найден! (клики не будут работать)");
            }
        }
        
        private void Test_ButtonsExist()
        {
            var buttons = FindObjectsByType<Button>(FindObjectsSortMode.None);
            
            if (buttons.Length > 0)
            {
                PassTest($"Найдено кнопок: {buttons.Length}");
                
                foreach (var button in buttons)
                {
                    Debug.Log($"   📍 {button.name} (Layer: {button.gameObject.layer})");
                }
            }
            else
            {
                FailTest("Кнопки НЕ найдены!");
            }
        }
        
        private void Test_StartButton()
        {
            var startButton = FindFirstObjectByType<Button>();
            
            if (startButton != null)
            {
                PassTest($"StartButton найден: {startButton.name}");
            }
            else
            {
                FailTest("StartButton НЕ найден!");
            }
        }
        
        private void Test_GraphicRaycaster()
        {
            var canvas = FindFirstObjectByType<Canvas>();
            
            if (canvas != null)
            {
                var raycaster = canvas.GetComponent<UnityEngine.UI.GraphicRaycaster>();
                
                if (raycaster != null)
                {
                    PassTest("GraphicRaycaster найден на Canvas");
                }
                else
                {
                    FailTest("GraphicRaycaster НЕ найден на Canvas! (клики не будут работать)");
                }
            }
            else
            {
                FailTest("Canvas НЕ найден для проверки GraphicRaycaster");
            }
        }
        
        private void Test_Resolution()
        {
            Debug.Log($"📊 Текущее разрешение: {Screen.width}x{Screen.height}");
            Debug.Log($"🖥️ Полноэкранный: {Screen.fullScreen}");
            
            if (Screen.width > 0 && Screen.height > 0)
            {
                PassTest($"Разрешение корректно: {Screen.width}x{Screen.height}");
            }
            else
            {
                FailTest("Разрешение НЕ корректно!");
            }
        }
        
        private void Test_StartButtonInteractable()
        {
            var startButton = FindFirstObjectByType<Button>();
            
            if (startButton != null)
            {
                if (startButton.interactable)
                {
                    PassTest("StartButton интерактивна (можно кликнуть)");
                }
                else
                {
                    FailTest("StartButton НЕ интерактивна! (нельзя кликнуть)");
                }
            }
        }
        
        private void Test_ButtonImage()
        {
            var startButton = FindFirstObjectByType<Button>();
            
            if (startButton != null)
            {
                var image = startButton.GetComponent<Image>();
                
                if (image != null)
                {
                    PassTest($"Image найден (Color: {image.color})");
                    
                    if (image.raycastTarget)
                    {
                        Debug.Log("   ✅ Raycast Target: ВКЛ (клики работают)");
                    }
                    else
                    {
                        Debug.Log("   ❌ Raycast Target: ВЫКЛ (клики НЕ работают)");
                        FailTest("Image.raycastTarget = false! (клики не будут работать)");
                    }
                }
                else
                {
                    FailTest("Image НЕ найден на кнопке!");
                }
            }
        }
        
        private void Test_ButtonListeners()
        {
            var startButton = FindFirstObjectByType<Button>();
            
            if (startButton != null)
            {
                int listenerCount = startButton.onClick.GetPersistentEventCount();
                
                if (listenerCount > 0)
                {
                    PassTest($"Слушателей кнопки: {listenerCount}");
                    
                    for (int i = 0; i < listenerCount; i++)
                    {
                        string target = startButton.onClick.GetPersistentTarget(i)?.GetType().Name ?? "Unknown";
                        string method = startButton.onClick.GetPersistentMethodName(i);
                        Debug.Log($"   📍 {target}.{method}");
                    }
                }
                else
                {
                    FailTest("Слушатели кнопки НЕ найдены! (клик не сработает)");
                }
            }
        }
        
        private void Test_ScenesInBuild()
        {
            Debug.Log($"📋 Сцен в Build Settings: {UnityEngine.SceneManagement.SceneManager.sceneCountInBuildSettings}");
            
            bool startFound = false;
            bool mainMenuFound = false;
            bool raceFound = false;
            
            for (int i = 0; i < UnityEngine.SceneManagement.SceneManager.sceneCountInBuildSettings; i++)
            {
                string sceneName = System.IO.Path.GetFileNameWithoutExtension(
                    UnityEngine.SceneManagement.SceneUtility.GetScenePathByBuildIndex(i));
                
                Debug.Log($"   [{i}] {sceneName}");
                
                if (sceneName == "Start") startFound = true;
                if (sceneName == "MainMenu") mainMenuFound = true;
                if (sceneName == "Race") raceFound = true;
            }
            
            if (startFound && mainMenuFound)
            {
                PassTest("Сцены Start и MainMenu в Build Settings");
            }
            else
            {
                if (!startFound) FailTest("Сцена Start НЕ в Build Settings!");
                if (!mainMenuFound) FailTest("Сцена MainMenu НЕ в Build Settings!");
            }
        }
        
        private void PassTest(string message)
        {
            testsPassed++;
            Debug.Log($"✅ ТЕСТ {testsPassed + testsFailed}: {message}");
        }
        
        private void FailTest(string message)
        {
            testsFailed++;
            Debug.LogError($"❌ ТЕСТ {testsPassed + testsFailed}: {message}");
        }
    }
}

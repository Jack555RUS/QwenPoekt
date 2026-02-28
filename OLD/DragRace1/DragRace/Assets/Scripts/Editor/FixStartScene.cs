using UnityEngine;
using UnityEditor;
using UnityEditor.SceneManagement;
using UnityEngine.UI;

namespace DragRace.Editor
{
    /// <summary>
    /// Исправление сцены Start.unity для работы кнопок в билде
    /// </summary>
    public class FixStartScene : EditorWindow
    {
        [MenuItem("DragRace/Fix/Fix Start Scene Buttons")]
        public static void FixStartSceneButtons()
        {
            Debug.Log("=== ИСПРАВЛЕНИЕ START.UNITY ===");
            
            // Открываем сцену
            EditorSceneManager.OpenScene("Assets/Scenes/Start.unity");
            
            // Находим Canvas
            Canvas canvas = FindFirstObjectByType<Canvas>();
            if (canvas == null)
            {
                Debug.LogError("❌ Canvas не найден!");
                return;
            }
            
            Debug.Log($"✅ Canvas найден: {canvas.name}");
            
            // Находим кнопку
            Button startButton = FindFirstObjectByType<Button>();
            if (startButton == null)
            {
                Debug.LogError("❌ Кнопка не найдена!");
                return;
            }
            
            Debug.Log($"✅ Кнопка найдена: {startButton.name}");
            
            // Проверяем Image
            Image buttonImage = startButton.GetComponent<Image>();
            if (buttonImage == null)
            {
                buttonImage = startButton.gameObject.AddComponent<Image>();
                Debug.Log("✅ Добавлен Image компонент");
            }
            
            // Проверяем SimpleButtonTest
            SimpleButtonTest testScript = FindFirstObjectByType<SimpleButtonTest>();
            if (testScript == null)
            {
                Debug.LogError("❌ SimpleButtonTest не найден!");
                return;
            }
            
            // Назначаем кнопку в скрипт
            testScript.startButton = startButton;
            EditorUtility.SetDirty(testScript);
            
            Debug.Log("✅ SimpleButtonTest настроен");
            
            // Сохраняем сцену
            EditorSceneManager.SaveOpenScenes();
            
            Debug.Log("✅ Сцена сохранена");
            Debug.Log("=== ИСПРАВЛЕНИЕ ЗАВЕРШЕНО ===");
        }
    }
    
    /// <summary>
    /// Простой тест кнопки для Start.unity
    /// </summary>
    public class SimpleButtonTest : MonoBehaviour
    {
        [Header("Настройки кнопки")]
        public Button startButton;
        
        [Header("Сцены")]
        public string mainMenuSceneName = "MainMenu";
        
        private void Start()
        {
            if (startButton == null)
            {
                startButton = FindFirstObjectByType<Button>();
            }
            
            if (startButton != null)
            {
                // Очищаем и добавляем слушатель
                startButton.onClick.RemoveAllListeners();
                startButton.onClick.AddListener(OnStartClicked);
                
                Debug.Log("✅ Кнопка настроена в Start()");
            }
            else
            {
                Debug.LogError("❌ startButton = null!");
            }
        }
        
        private void OnStartClicked()
        {
            Debug.Log("===========================================");
            Debug.Log("🎮 КНОПКА START НАЖАТА!");
            Debug.Log("🔄 ПЕРЕХОД В ГЛАВНОЕ МЕНЮ...");
            Debug.Log("===========================================");
            
            UnityEngine.SceneManagement.SceneManager.LoadScene(mainMenuSceneName, UnityEngine.SceneManagement.LoadSceneMode.Single);
        }
    }
}

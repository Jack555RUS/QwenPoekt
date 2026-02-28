using UnityEngine;
using UnityEngine.UI;
using UnityEditor;
using UnityEditor.SceneManagement;

namespace DragRace.Editor
{
    /// <summary>
    /// Editor скрипт для автоматического тестирования кнопки START
    /// Запуск: DragRace → Test Button → Run Button Test
    /// </summary>
    public class ButtonTestRunner
    {
        [MenuItem("DragRace/Test Button/Run Button Test")]
        public static void RunButtonTest()
        {
            Debug.Log("=== ЗАПУСК АВТОТЕСТА КНОПКИ START ===");
            
            // Открываем сцену Start
            EditorSceneManager.OpenScene("Assets/Scenes/Start.unity");
            
            // Находим Canvas с тестом
            var canvas = Object.FindFirstObjectByType<Canvas>();
            if (canvas == null)
            {
                Debug.LogError("❌ Canvas не найден!");
                return;
            }
            
            // Находим кнопку
            var button = Object.FindFirstObjectByType<Button>();
            if (button == null)
            {
                Debug.LogError("❌ Кнопка не найдена!");
                return;
            }
            
            Debug.Log("✅ Кнопка найдена: " + button.name);
            
            // Находим тестовый скрипт
            var testScript = Object.FindFirstObjectByType<DragRace.Test.SimpleButtonTest>();
            if (testScript == null)
            {
                Debug.LogError("❌ SimpleButtonTest не найден!");
                return;
            }
            
            Debug.Log("✅ SimpleButtonTest найден");
            Debug.Log("=== Тест завершен - проверьте Console ===");
            
            // Запускаем Play mode
            EditorApplication.isPlaying = true;
            
            // Планируем клик через 2 секунды после старта Play mode
            EditorApplication.update += WaitForPlayMode;
        }
        
        private static void WaitForPlayMode()
        {
            if (EditorApplication.isPlaying)
            {
                // Ждём пока сцена запустится
                System.Threading.Thread.Sleep(2500);
                
                // Находим кнопку и кликаем
                var button = Object.FindFirstObjectByType<Button>();
                if (button != null)
                {
                    Debug.Log("🔴 СИМУЛЯЦИЯ КЛИКА ПО КНОПКЕ!");
                    button.onClick.Invoke();
                }
                
                EditorApplication.update -= WaitForPlayMode;
                
                // Останавливаем Play mode через 1 секунду
                EditorApplication.update += StopPlayMode;
            }
        }
        
        private static void StopPlayMode()
        {
            EditorApplication.isPlaying = false;
            EditorApplication.update -= StopPlayMode;
            Debug.Log("=== АВТОТЕСТ ЗАВЕРШЁН ===");
        }
    }
}

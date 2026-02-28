using UnityEngine;
using UnityEngine.EventSystems;
using UnityEditor;
using UnityEditor.SceneManagement;

namespace ProbMenu.Editor
{
    /// <summary>
    /// Исправление UI - добавляет EventSystem и проверяет кнопки
    /// </summary>
    public class FixUIButtons
    {
        [MenuItem("Tools/Drag Racing/Fix/Setup EventSystem in All Scenes")]
        public static void SetupEventSystemInAllScenes()
        {
            string[] scenePaths = new[]
            {
                "Assets/Scenes/MainMenu.unity",
                "Assets/Scenes/GameMenu.unity",
                "Assets/Scenes/Race.unity",
                "Assets/Scenes/Garage.unity",
                "Assets/Scenes/Tuning.unity",
                "Assets/Scenes/Shop.unity"
            };

            foreach (string path in scenePaths)
            {
                FixScene(path);
            }

            Debug.Log("=== ВСЕ СЦЕНЫ ПРОВЕРЕНЫ! ===");
        }

        private static void FixScene(string scenePath)
        {
            EditorSceneManager.OpenScene(scenePath);
            
            // Проверяем есть ли EventSystem
            var eventSystem = Object.FindObjectOfType<EventSystem>();
            
            if (eventSystem == null)
            {
                Debug.Log($"🔧 Добавляем EventSystem в {scenePath}");
                
                var go = new GameObject("EventSystem");
                var es = go.AddComponent<EventSystem>();
                go.AddComponent<UnityEngine.EventSystems.StandaloneInputModule>();
                
                EditorSceneManager.MarkSceneDirty(EditorSceneManager.GetActiveScene());
                EditorSceneManager.SaveScene(EditorSceneManager.GetActiveScene(), scenePath);
            }
            else
            {
                Debug.Log($"✅ EventSystem уже есть в {scenePath}");
            }
            
            // Проверяем есть ли Canvas
            var canvas = Object.FindObjectOfType<Canvas>();
            
            if (canvas == null)
            {
                Debug.Log($"🔧 Добавляем Canvas в {scenePath}");
                
                var go = new GameObject("Canvas");
                canvas = go.AddComponent<Canvas>();
                canvas.renderMode = RenderMode.ScreenSpaceOverlay;
                go.AddComponent<UnityEngine.UI.GraphicRaycaster>();
                
                EditorSceneManager.MarkSceneDirty(EditorSceneManager.GetActiveScene());
                EditorSceneManager.SaveScene(EditorSceneManager.GetActiveScene(), scenePath);
            }
            else
            {
                Debug.Log($"✅ Canvas уже есть в {scenePath}");
            }
        }
    }
}

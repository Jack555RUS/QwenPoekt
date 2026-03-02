using UnityEngine;
using UnityEngine.EventSystems;
using UnityEngine.UI;
using UnityEditor;
using UnityEditor.SceneManagement;

namespace ProbMenu.Editor
{
    /// <summary>
    /// КРИТИЧЕСКОЕ ИСПРАВЛЕНИЕ - Добавляет StandaloneInputModule в EventSystem
    /// </summary>
    public class FixEventSystemInputModule
    {
        [MenuItem("Tools/Drag Racing/Fix/CRITICAL - Add InputModule to EventSystem")]
        public static void FixAllEventSystems()
        {
            Debug.Log("=== КРИТИЧЕСКОЕ ИСПРАВЛЕНИЕ EVENTSYSTEM ===");
            
            string[] scenePaths = new[]
            {
                "Assets/Scenes/MainMenu.unity",
                "Assets/Scenes/GameMenu.unity",
                "Assets/Scenes/Race.unity",
                "Assets/Scenes/Garage.unity",
                "Assets/Scenes/Tuning.unity",
                "Assets/Scenes/Shop.unity"
            };

            int fixedCount = 0;
            
            foreach (string path in scenePaths)
            {
                if (FixScene(path))
                {
                    fixedCount++;
                }
            }
            
            Debug.Log($"=== ИСПРАВЛЕНО {fixedCount} из {scenePaths.Length} сцен ===");
        }

        private static bool FixScene(string scenePath)
        {
            Debug.Log($"🔧 Проверка: {scenePath}");
            
            EditorSceneManager.OpenScene(scenePath);
            
            bool sceneModified = false;
            
            // Находим EventSystem
            var eventSystems = Object.FindObjectsOfType<EventSystem>();
            
            if (eventSystems.Length == 0)
            {
                Debug.Log($"  ❌ Нет EventSystem! Создаём...");
                var go = new GameObject("EventSystem");
                go.AddComponent<EventSystem>();
                go.AddComponent<StandaloneInputModule>();
                EditorSceneManager.MarkSceneDirty(EditorSceneManager.GetActiveScene());
                sceneModified = true;
            }
            else
            {
                foreach (var es in eventSystems)
                {
                    // Проверяем есть ли StandaloneInputModule
                    var standalones = es.GetComponents<StandaloneInputModule>();
                    
                    if (standalones.Length == 0)
                    {
                        Debug.Log($"  ⚠️ EventSystem без StandaloneInputModule! Добавляем...");
                        es.gameObject.AddComponent<StandaloneInputModule>();
                        EditorSceneManager.MarkSceneDirty(EditorSceneManager.GetActiveScene());
                        sceneModified = true;
                    }
                    else if (standalones.Length > 1)
                    {
                        Debug.Log($"  ⚠️ Найдено {standalones.Length} StandaloneInputModule! Удаляем лишние...");
                        for (int i = 1; i < standalones.Length; i++)
                        {
                            Object.DestroyImmediate(standalones[i]);
                        }
                        EditorSceneManager.MarkSceneDirty(EditorSceneManager.GetActiveScene());
                        sceneModified = true;
                    }
                    else
                    {
                        Debug.Log($"  ✅ EventSystem OK (есть StandaloneInputModule)");
                    }
                }
            }
            
            // Проверяем Canvas и GraphicRaycaster
            var canvases = Object.FindObjectsOfType<Canvas>();
            
            if (canvases.Length == 0)
            {
                Debug.Log($"  ❌ Нет Canvas! Создаём...");
                var go = new GameObject("Canvas");
                var canvas = go.AddComponent<Canvas>();
                canvas.renderMode = RenderMode.ScreenSpaceOverlay;
                go.AddComponent<GraphicRaycaster>();
                EditorSceneManager.MarkSceneDirty(EditorSceneManager.GetActiveScene());
                sceneModified = true;
            }
            else
            {
                foreach (var canvas in canvases)
                {
                    var raycaster = canvas.GetComponent<GraphicRaycaster>();
                    if (raycaster == null)
                    {
                        Debug.Log($"  ⚠️ Canvas без GraphicRaycaster! Добавляем...");
                        canvas.gameObject.AddComponent<GraphicRaycaster>();
                        EditorSceneManager.MarkSceneDirty(EditorSceneManager.GetActiveScene());
                        sceneModified = true;
                    }
                }
            }
            
            // Сохраняем сцену
            if (sceneModified)
            {
                EditorSceneManager.SaveScene(EditorSceneManager.GetActiveScene(), scenePath);
                Debug.Log($"  💾 Сцена сохранена");
            }
            else
            {
                Debug.Log($"  ✅ Сцена OK");
            }
            
            return sceneModified;
        }
    }
}

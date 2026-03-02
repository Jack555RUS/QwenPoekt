using UnityEngine;
using UnityEngine.UI;
using UnityEngine.EventSystems;
using UnityEditor;
using UnityEditor.SceneManagement;

namespace ProbMenu.Editor
{
    /// <summary>
    /// Полное исправление UI - кнопки, EventSystem, Canvas
    /// </summary>
    public class FixAllUI
    {
        [MenuItem("Tools/Drag Racing/Fix/Fix All UI Issues")]
        public static void FixAllUIIssues()
        {
            Debug.Log("=== НАЧАЛО ИСПРАВЛЕНИЯ UI ===");
            
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
                FixSceneUI(path);
            }
            
            Debug.Log("=== ВСЕ СЦЕНЫ ИСПРАВЛЕНЫ! ===");
        }

        private static void FixSceneUI(string scenePath)
        {
            Debug.Log($"🔧 Проверка сцены: {scenePath}");
            
            EditorSceneManager.OpenScene(scenePath);
            
            // 1. Проверяем EventSystem
            var eventSystems = Object.FindObjectsOfType<EventSystem>();
            if (eventSystems.Length == 0)
            {
                Debug.Log($"  ➕ Добавляем EventSystem");
                var go = new GameObject("EventSystem");
                go.AddComponent<EventSystem>();
                go.AddComponent<StandaloneInputModule>();
                EditorSceneManager.MarkSceneDirty(EditorSceneManager.GetActiveScene());
            }
            else if (eventSystems.Length > 1)
            {
                Debug.Log($"  ⚠️ Найдено {eventSystems.Length} EventSystem! Удаляем лишние...");
                for (int i = 1; i < eventSystems.Length; i++)
                {
                    Object.DestroyImmediate(eventSystems[i].gameObject);
                }
                EditorSceneManager.MarkSceneDirty(EditorSceneManager.GetActiveScene());
            }
            else
            {
                Debug.Log($"  ✅ EventSystem OK");
            }
            
            // 2. Проверяем Canvas
            var canvases = Object.FindObjectsOfType<Canvas>();
            if (canvases.Length == 0)
            {
                Debug.Log($"  ➕ Добавляем Canvas");
                var go = new GameObject("Canvas");
                var canvas = go.AddComponent<Canvas>();
                canvas.renderMode = RenderMode.ScreenSpaceOverlay;
                go.AddComponent<GraphicRaycaster>();
                EditorSceneManager.MarkSceneDirty(EditorSceneManager.GetActiveScene());
            }
            else
            {
                Debug.Log($"  ✅ Canvas OK ({canvases.Length})");
            }
            
            // 3. Проверяем кнопки
            var buttons = Object.FindObjectsOfType<Button>();
            Debug.Log($"  📍 Найдено кнопок: {buttons.Length}");
            
            foreach (var button in buttons)
            {
                // Проверяем Raycast Target
                var image = button.GetComponent<Image>();
                if (image != null && !image.raycastTarget)
                {
                    Debug.Log($"    🔧 Кнопка '{button.name}': Включаем Raycast Target");
                    image.raycastTarget = true;
                    EditorSceneManager.MarkSceneDirty(EditorSceneManager.GetActiveScene());
                }
                
                // Проверяем OnClick
                if (button.onClick.GetPersistentEventCount() == 0)
                {
                    Debug.Log($"    ⚠️ Кнопка '{button.name}': Нет OnClick событий!");
                }
                else
                {
                    Debug.Log($"    ✅ Кнопка '{button.name}': OnClick OK ({button.onClick.GetPersistentEventCount()} событий)");
                }
            }
            
            // Сохраняем сцену
            EditorSceneManager.SaveScene(EditorSceneManager.GetActiveScene(), scenePath);
            Debug.Log($"  💾 Сцена сохранена");
        }
    }
}

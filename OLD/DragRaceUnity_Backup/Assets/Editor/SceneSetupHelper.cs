using UnityEngine;
using UnityEditor;
using UnityEditor.SceneManagement;
using UnityEngine.SceneManagement;
using UnityEngine.UI;

namespace ProbMenu.Editor
{
    /// <summary>
    /// Быстрая настройка сцены с необходимым оборудованием
    /// </summary>
    public class SceneSetupHelper
    {
        [MenuItem("Tools/Drag Racing/Setup Current Scene")]
        public static void SetupCurrentScene()
        {
            var scene = SceneManager.GetActiveScene();
            Debug.Log($"=== Настройка сцены: {scene.name} ===");

            // Создаём EventSystem если нет
            if (Object.FindObjectOfType<UnityEngine.EventSystems.EventSystem>() == null)
            {
                var go = new GameObject("EventSystem");
                go.AddComponent<UnityEngine.EventSystems.EventSystem>();
                go.AddComponent<UnityEngine.EventSystems.StandaloneInputModule>();
                Debug.Log("✅ Создан EventSystem");
            }

            // Создаём Main Camera если нет
            if (Camera.main == null)
            {
                var go = new GameObject("Main Camera");
                go.AddComponent<Camera>();
                go.tag = "MainCamera";
                go.transform.position = new Vector3(0, 1, -10);
                Debug.Log("✅ Создана Main Camera");
            }

            // Создаём Directional Light если нет
            if (Object.FindObjectOfType<Light>() == null)
            {
                var go = new GameObject("Directional Light");
                var light = go.AddComponent<Light>();
                light.type = LightType.Directional;
                light.intensity = 1;
                light.shadows = LightShadows.Soft;
                go.transform.rotation = Quaternion.Euler(50, -30, 0);
                Debug.Log("✅ Создан Directional Light");
            }

            EditorSceneManager.MarkSceneDirty(scene);
            Debug.Log("=== Настройка завершена! ===");
        }

        [MenuItem("Tools/Drag Racing/Create UI Canvas")]
        public static void CreateUICanvas()
        {
            var canvas = new GameObject("Canvas").AddComponent<Canvas>();
            canvas.renderMode = RenderMode.ScreenSpaceOverlay;
            
            var scaler = canvas.gameObject.AddComponent<CanvasScaler>();
            scaler.uiScaleMode = CanvasScaler.ScaleMode.ScaleWithScreenSize;
            scaler.referenceResolution = new Vector2(1920, 1080);
            
            canvas.gameObject.AddComponent<UnityEngine.UI.GraphicRaycaster>();
            
            Debug.Log("✅ Создан UI Canvas");
        }
    }
}

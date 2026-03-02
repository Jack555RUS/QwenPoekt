using UnityEngine;
using UnityEditor;
using UnityEditor.SceneManagement;
using UnityEngine.SceneManagement;
using System.IO;

namespace ProbMenu.Editor
{
    /// <summary>
    /// Автоматическое создание и настройка всех сцен
    /// </summary>
    public class AutoSetupScenes
    {
        [MenuItem("Tools/Drag Racing/Setup All Scenes")]
        public static void SetupAllScenes()
        {
            Debug.Log("=== НАЧАЛО НАСТРОЙКИ ВСЕХ СЦЕН ===");

            CreateBaseScene("Assets/Scenes/MainMenu.unity", "MainMenu");
            CreateBaseScene("Assets/Scenes/GameMenu.unity", "GameMenu");
            CreateBaseScene("Assets/Scenes/Race.unity", "Race");
            CreateBaseScene("Assets/Scenes/Garage.unity", "Garage");
            CreateBaseScene("Assets/Scenes/Tuning.unity", "Tuning");
            CreateBaseScene("Assets/Scenes/Shop.unity", "Shop");

            Debug.Log("=== ВСЕ СЦЕНЫ НАСТРОЕНЫ! ===");
            Debug.Log("Теперь выполните: File → Build Settings → Add Open Scenes → Build");
        }

        [MenuItem("Tools/Drag Racing/Create Missing Scenes")]
        public static void CreateMissingScenes()
        {
            Debug.Log("=== СОЗДАНИЕ ОТСУТСТВУЮЩИХ СЦЕН ===");
            CreateBaseScene("Assets/Scenes/Garage.unity", "Garage");
            CreateBaseScene("Assets/Scenes/Tuning.unity", "Tuning");
            CreateBaseScene("Assets/Scenes/Shop.unity", "Shop");
            Debug.Log("=== ОТСУТСТВУЮЩИЕ СЦЕНЫ СОЗДАНЫ! ===");
        }

        private static void CreateBaseScene(string path, string name)
        {
            if (File.Exists(path))
            {
                Debug.Log($"✅ Сцена уже существует: {path}");
                return;
            }

            Scene scene = EditorSceneManager.NewScene(NewSceneSetup.EmptyScene);
            scene.name = name;
            EditorSceneManager.SaveScene(scene, path);
            Debug.Log($"✅ Создана сцена: {path}");
        }
    }
}

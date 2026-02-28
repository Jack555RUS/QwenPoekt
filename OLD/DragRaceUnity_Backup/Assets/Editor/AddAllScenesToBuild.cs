using UnityEngine;
using UnityEditor;
using System.Collections.Generic;

namespace ProbMenu.Editor
{
    /// <summary>
    /// Добавление всех сцен в Build Settings
    /// </summary>
    public class AddAllScenesToBuild
    {
        [MenuItem("Tools/Drag Racing/Build/Add All Scenes To Build Settings")]
        public static void AddAllScenes()
        {
            Debug.Log("=== ДОБАВЛЕНИЕ СЦЕН В BUILD SETTINGS ===");
            
            string[] scenePaths = new[]
            {
                "Assets/Scenes/MainMenu.unity",
                "Assets/Scenes/GameMenu.unity",
                "Assets/Scenes/Race.unity",
                "Assets/Scenes/Garage.unity",
                "Assets/Scenes/Tuning.unity",
                "Assets/Scenes/Shop.unity"
            };
            
            var buildScenes = new List<EditorBuildSettingsScene>();
            
            foreach (string path in scenePaths)
            {
                if (System.IO.File.Exists(path))
                {
                    buildScenes.Add(new EditorBuildSettingsScene(path, true));
                    Debug.Log($"✅ Добавлена: {path}");
                }
                else
                {
                    Debug.LogWarning($"⚠️ Не найдена: {path}");
                }
            }
            
            EditorBuildSettings.scenes = buildScenes.ToArray();
            Debug.Log("=== СЦЕНЫ ДОБАВЛЕНЫ! ===");
            Debug.Log($"Всего сцен: {buildScenes.Count}");
        }
    }
}

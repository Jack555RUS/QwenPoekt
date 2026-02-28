using UnityEngine;
using UnityEditor;
using UnityEditor.SceneManagement;

namespace DragRace.Editor
{
    /// <summary>
    /// Инструменты для настройки проекта
    /// </summary>
    public class ProjectTools
    {
        /// <summary>
        /// Добавить сцены в Build Settings
        /// </summary>
        [MenuItem("DragRace/Setup/Add Scenes to Build")]
        public static void AddScenesToBuild()
        {
            Debug.Log("=== ДОБАВЛЕНИЕ СЦЕН В BUILD SETTINGS ===");
            
            string[] scenePaths = new string[]
            {
                "Assets/Scenes/Start.unity",
                "Assets/Scenes/MainMenu.unity",
                "Assets/Scenes/Race.unity"
            };
            
            // Очищаем текущий список сцен
            EditorBuildSettings.scenes = new EditorBuildSettingsScene[0];
            
            // Добавляем сцены
            var buildScenes = new System.Collections.Generic.List<EditorBuildSettingsScene>();
            
            foreach (var scenePath in scenePaths)
            {
                if (System.IO.File.Exists(scenePath))
                {
                    buildScenes.Add(new EditorBuildSettingsScene(scenePath, true));
                    Debug.Log($"✅ Добавлена сцена: {scenePath}");
                }
                else
                {
                    Debug.LogWarning($"⚠️ Сцена не найдена: {scenePath}");
                }
            }
            
            EditorBuildSettings.scenes = buildScenes.ToArray();
            Debug.Log($"=== ВСЕГО СЦЕН: {buildScenes.Count} ===");
        }
        
        /// <summary>
        /// Открыть сцену Start
        /// </summary>
        [MenuItem("DragRace/Open Scene/Start")]
        public static void OpenStartScene()
        {
            EditorSceneManager.OpenScene("Assets/Scenes/Start.unity");
        }
        
        /// <summary>
        /// Открыть сцену MainMenu
        /// </summary>
        [MenuItem("DragRace/Open Scene/MainMenu")]
        public static void OpenMainMenuScene()
        {
            EditorSceneManager.OpenScene("Assets/Scenes/MainMenu.unity");
        }
    }
}

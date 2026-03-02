using UnityEngine;
using UnityEngine.SceneManagement;
using UnityEditor;
using System;
using System.IO;

namespace DragRaceUnity.EditorTools
{
    /// <summary>
    /// Скрипт автоматической сборки для Unity
    /// Использование из командной строки:
    /// Unity.exe -batchmode -quit -projectPath "путь" -executeMethod BuildScript.PerformBuild
    /// </summary>
    public static class BuildScript
    {
        private static readonly string BUILD_FOLDER = "Builds";
        private static readonly string BUILD_NAME = "DragRace";

        /// <summary>
        /// Выполнить сборку проекта (из меню Unity)
        /// </summary>
        #if UNITY_EDITOR
        [MenuItem("Tools/DragRace/Build Project %b")]
        #endif
        public static void BuildFromMenu()
        {
            Debug.Log("Сборка запущена из меню Unity");
            PerformBuild();
        }

        /// <summary>
        /// Выполнить сборку (из командной строки)
        /// </summary>
        public static void PerformBuild()
        {
            Debug.Log("===========================================");
            Debug.Log("🔨 НАЧАЛО СБОРКИ ПРОЕКТА");
            Debug.Log("===========================================");

            try
            {
                // Настройка сцен
                string[] scenes = GetScenes();
                Debug.Log($"Добавлено сцен: {scenes.Length}");

                foreach (string scene in scenes)
                {
                    Debug.Log($"  - {scene}");
                }

                // Путь к сборке
                string buildPath = GetBuildPath();
                Debug.Log($"Путь к сборке: {buildPath}");

                // Настройки Player Settings
                PlayerSettings.companyName = "DragRace Studio";
                PlayerSettings.productName = "DragRace";
                PlayerSettings.bundleVersion = "1.0.0";
                PlayerSettings.defaultScreenWidth = 800;
                PlayerSettings.defaultScreenHeight = 600;
                PlayerSettings.fullScreenMode = FullScreenMode.Windowed;

                Debug.Log("Настройки применены");

                // Запуск сборки
                Debug.Log("Запуск сборки...");
                
                // Используем упрощённый API для Unity 6000.x
                BuildPlayerOptions buildPlayerOptions = new BuildPlayerOptions();
                buildPlayerOptions.scenes = scenes;
                buildPlayerOptions.locationPathName = buildPath;
                buildPlayerOptions.target = BuildTarget.StandaloneWindows64;
                buildPlayerOptions.options = BuildOptions.None;
                
                BuildPipeline.BuildPlayer(buildPlayerOptions);
                
                Debug.Log("===========================================");
                Debug.Log("✅ СБОРКА ЗАВЕРШЕНА УСПЕШНО!");
                Debug.Log("===========================================");
                Debug.Log($"Путь: {buildPath}");
            }
            catch (Exception e)
            {
                Debug.LogError($"❌ ОШИБКА СБОРКИ: {e.Message}");
                Debug.LogError($"Stack trace: {e.StackTrace}");
                throw;
            }
        }

        /// <summary>
        /// Сборка для CI/CD (GitHub Actions)
        /// </summary>
        public static void PerformCIBuild()
        {
            Debug.Log("=== CI/CD Build Started ===");
            
            // Получаем сцены из Build Settings
            var scenes = UnityEngine.SceneManagement.SceneManager.sceneCountInBuildSettings;
            Debug.Log($"Scenes in build: {scenes}");
            
            // Путь к сборке
            string buildPath = System.IO.Path.Combine(
                System.IO.Directory.GetCurrentDirectory(), 
                "..", 
                "Builds", 
                "CI", 
                "DragRace.exe"
            );
            
            System.IO.Directory.CreateDirectory(System.IO.Path.GetDirectoryName(buildPath));
            
            // Настройки
            PlayerSettings.companyName = "DragRace Studio";
            PlayerSettings.productName = "DragRace";
            PlayerSettings.bundleVersion = "1.0." + System.DateTime.Now.ToString("yyMMdd");
            
            // Сборка
            BuildPlayerOptions options = new BuildPlayerOptions();
            options.locationPathName = buildPath;
            options.target = BuildTarget.StandaloneWindows64;
            options.options = BuildOptions.None;
            
            BuildPipeline.BuildPlayer(options);
            
            Debug.Log("=== CI/CD Build Complete ===");
        }

        /// <summary>
        /// Получить список сцен для сборки
        /// </summary>
        private static string[] GetScenes()
        {
            return new string[]
            {
                "Assets/Scenes/MainMenu.unity",
                "Assets/Scenes/GameMenu.unity",
                "Assets/Scenes/Race.unity"
            };
        }

        /// <summary>
        /// Получить путь к файлу сборки
        /// </summary>
        private static string GetBuildPath()
        {
            string projectPath = System.IO.Directory.GetParent(Application.dataPath).FullName;
            return System.IO.Path.Combine(projectPath, BUILD_FOLDER, BUILD_NAME, $"{BUILD_NAME}.exe");
        }
    }
}

using UnityEngine;
using UnityEditor;
using UnityEditor.Build.Reporting;
using System;
using System.IO;

namespace ProbMenu.Editor
{
    /// <summary>
    /// Автоматическая сборка билда для Windows
    /// </summary>
    public class AutoBuildScript
    {
        private static string buildFolder = "Builds";
        private static string buildName = "DragRacing";

        [MenuItem("Tools/Drag Racing/Build/Windows x64")]
        public static void BuildWindowsX64()
        {
            Debug.Log("=== НАЧАЛО СБОРКИ: WINDOWS X64 ===");
            
            string buildPath = $"{buildFolder}/{buildName}-WinX64.exe";
            
            EnsureBuildFolder();
            
            // Получаем сцены из Build Settings
            string[] scenes = GetEnabledScenes();
            
            if (scenes.Length == 0)
            {
                Debug.LogError("❌ Нет сцен в Build Settings!");
                Debug.LogError("Добавьте сцены: File → Build Settings → Add Open Scenes");
                return;
            }
            
            Debug.Log($"📊 Найдено {scenes.Length} сцен:");
            foreach (string scene in scenes)
            {
                Debug.Log($"  📄 {scene}");
            }
            
            BuildPlayerOptions buildPlayerOptions = new BuildPlayerOptions
            {
                scenes = scenes,
                locationPathName = buildPath,
                target = BuildTarget.StandaloneWindows64,
                options = BuildOptions.None
            };

            BuildReport report = BuildPipeline.BuildPlayer(buildPlayerOptions);
            
            HandleBuildResult(report, "Windows X64");
        }

        [MenuItem("Tools/Drag Racing/Build/Clean Build Folder")]
        public static void CleanBuildFolder()
        {
            if (Directory.Exists(buildFolder))
            {
                Directory.Delete(buildFolder, true);
                Debug.Log("🗑️ Папка билдов очищена");
            }
            else
            {
                Debug.Log("ℹ️ Папка билдов не существует");
            }
        }

        [MenuItem("Tools/Drag Racing/Build/Check Scenes")]
        public static void CheckScenes()
        {
            Debug.Log("=== ПРОВЕРКА СЦЕН ===");
            
            string[] scenes = GetEnabledScenes();
            
            if (scenes.Length == 0)
            {
                Debug.LogWarning("⚠️ Нет сцен в Build Settings!");
                Debug.LogWarning("Добавьте сцены: File → Build Settings → Add Open Scenes");
                return;
            }
            
            Debug.Log($"✅ Найдено {scenes.Length} сцен:");
            foreach (string scene in scenes)
            {
                Debug.Log($"  📄 {scene}");
            }
        }

        #region Helpers

        private static void EnsureBuildFolder()
        {
            if (!Directory.Exists(buildFolder))
            {
                Directory.CreateDirectory(buildFolder);
                Debug.Log($"📁 Создана папка: {buildFolder}");
            }
        }

        private static string[] GetEnabledScenes()
        {
            var scenes = new System.Collections.Generic.List<string>();
            
            for (int i = 0; i < EditorBuildSettings.scenes.Length; i++)
            {
                if (EditorBuildSettings.scenes[i].enabled)
                {
                    scenes.Add(EditorBuildSettings.scenes[i].path);
                }
            }
            
            return scenes.ToArray();
        }

        private static void HandleBuildResult(BuildReport report, string platform)
        {
            if (report.summary.result == BuildResult.Succeeded)
            {
                Debug.Log($"✅ СБОРКА УСПЕШНА: {platform}");
                Debug.Log($"📊 Размер: {GetSize((long)report.summary.totalSize)}");
                Debug.Log($"⏱️ Время: {report.summary.totalTime.ToString(@"hh\:mm\:ss")}");
                Debug.Log($"📁 Путь: {report.summary.outputPath}");
            }
            else if (report.summary.result == BuildResult.Failed)
            {
                Debug.LogError($"❌ СБОРКА ПРОВАЛИЛАСЬ: {platform}");
                Debug.LogError("Проверьте консоль для деталей");
            }
            else if (report.summary.result == BuildResult.Cancelled)
            {
                Debug.LogWarning("⚠️ СБОРКА ОТМЕНЕНА");
            }
        }

        private static string GetSize(long bytes)
        {
            string[] sizes = { "B", "KB", "MB", "GB" };
            int order = 0;
            double size = bytes;
            while (size >= 1024 && order < sizes.Length - 1)
            {
                order++;
                size /= 1024;
            }
            return $"{size:0.##} {sizes[order]}";
        }

        #endregion
    }
}

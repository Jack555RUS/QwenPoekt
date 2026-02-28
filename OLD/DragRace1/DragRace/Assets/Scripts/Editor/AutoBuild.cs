using UnityEngine;
using UnityEditor;
using UnityEditor.Build.Reporting;
using System.IO;

namespace DragRace.Editor
{
    /// <summary>
    /// Автоматическая сборка игры в .exe
    /// Запуск: DragRace → Build → Build Windows EXE
    /// </summary>
    public class AutoBuild
    {
        [MenuItem("DragRace/Build/Build Windows EXE")]
        public static void BuildWindowsEXE()
        {
            Debug.Log("=== НАЧАЛО СБОРКИ ===");
            
            // Путь к сборке
            string buildPath = "D:/QwenPoekt/DragRace/Builds/DragRace_v0.5/DragRace.exe";
            
            // Создаём папку если нет
            string buildDirectory = Path.GetDirectoryName(buildPath);
            if (!Directory.Exists(buildDirectory))
            {
                Directory.CreateDirectory(buildDirectory);
                Debug.Log($"📁 Создана папка: {buildDirectory}");
            }
            
            // Настройки сцен
            string[] scenes = {
                "Assets/Scenes/Start.unity",
                "Assets/Scenes/MainMenu.unity",
                "Assets/Scenes/Race.unity"
            };
            
            // Настройки сборки
            BuildPlayerOptions buildPlayerOptions = new BuildPlayerOptions
            {
                scenes = scenes,
                locationPathName = buildPath,
                target = BuildTarget.StandaloneWindows64,
                options = BuildOptions.None
            };
            
            // Запуск сборки
            Debug.Log("🔨 Начало сборки...");
            Debug.Log($"📍 Путь: {buildPath}");
            Debug.Log($"🎯 Платформа: Windows 64-bit");
            Debug.Log($"📋 Сцены: {scenes.Length}");
            
            BuildReport report = BuildPipeline.BuildPlayer(buildPlayerOptions);
            
            // Результат
            BuildSummary summary = report.summary;
            
            Debug.Log("=== РЕЗУЛЬТАТ СБОРКИ ===");
            Debug.Log($"Статус: {summary.result}");
            Debug.Log($"Время: {summary.totalTime.TotalSeconds:F2} сек");
            Debug.Log($"Размер: {summary.totalSize / 1024 / 1024:F2} MB");
            Debug.Log($"Сцен: {scenes.Length}");
            
            if (summary.result == BuildResult.Succeeded)
            {
                Debug.Log("✅✅✅ СБОРКА УСПЕШНА! ✅✅✅");
                Debug.Log($"🎮 Игра готова: {buildPath}");
                Debug.Log("📁 Папка сборки: " + Path.GetDirectoryName(buildPath));
            }
            else if (summary.result == BuildResult.Failed)
            {
                Debug.LogError("❌ СБОРКА ПРОВАЛИЛАСЬ!");
                
                foreach (var step in report.steps)
                {
                    foreach (var message in step.messages)
                    {
                        if (message.type == LogType.Error)
                        {
                            Debug.LogError($"Ошибка: {message.content}");
                        }
                    }
                }
            }
            else
            {
                Debug.LogWarning("⚠️ СБОРКА ЗАВЕРШЕНА С ПРЕДУПРЕЖДЕНИЯМИ");
            }
        }
        
        [MenuItem("DragRace/Build/Build Windows EXE (Development)")]
        public static void BuildWindowsEXEDevelopment()
        {
            Debug.Log("=== СБОРКА DEV ВЕРСИИ ===");
            
            string buildPath = "D:/QwenPoekt/DragRace/Builds/DragRace_v0.5_DEV/DragRace.exe";
            
            string buildDirectory = Path.GetDirectoryName(buildPath);
            if (!Directory.Exists(buildDirectory))
            {
                Directory.CreateDirectory(buildDirectory);
            }
            
            string[] scenes = {
                "Assets/Scenes/Start.unity",
                "Assets/Scenes/MainMenu.unity",
                "Assets/Scenes/Race.unity"
            };
            
            BuildPlayerOptions buildPlayerOptions = new BuildPlayerOptions
            {
                scenes = scenes,
                locationPathName = buildPath,
                target = BuildTarget.StandaloneWindows64,
                options = BuildOptions.Development | BuildOptions.AllowDebugging
            };
            
            BuildReport report = BuildPipeline.BuildPlayer(buildPlayerOptions);
            
            Debug.Log($"Dev сборка: {report.summary.result}");
        }
    }
}

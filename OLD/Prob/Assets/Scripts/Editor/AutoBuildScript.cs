using UnityEngine;
using UnityEditor;
using UnityEditor.Build.Reporting;
using System;
using System.Linq;

/// <summary>
/// Автоматический скрипт сборки игры
/// Запуск: unity-editor -batchmode -quit -executeMethod AutoBuildScript.PerformBuild
/// </summary>
public static class AutoBuildScript
{
    // Настройки сборки
    private static readonly string BUILD_FOLDER = "Build";
    private static readonly string GAME_NAME = "RacingGame";
    private static readonly string SCENE_PATH = "Assets/Scenes/MainMenu.unity";
    
    [MenuItem("Build/Perform Build")]
    public static void PerformBuild()
    {
        Debug.Log("=== НАЧАЛО СБОРКИ ===");
        
        // Получаем сцены из EditorBuildSettings
        string[] scenes = GetEnabledScenes();
        
        if (scenes.Length == 0)
        {
            Debug.LogError("Нет сцен для сборки! Проверьте EditorBuildSettings.");
            return;
        }
        
        Debug.Log($"Сцены для сборки ({scenes.Length}):");
        foreach (var scene in scenes)
        {
            Debug.Log($"  - {scene}");
        }
        
        // Путь для сборки
        string buildPath = $"{BUILD_FOLDER}/{GAME_NAME}.exe";
        Debug.Log($"Путь сборки: {buildPath}");
        
        // Настройки сборки
        BuildPlayerOptions buildPlayerOptions = new BuildPlayerOptions
        {
            scenes = scenes,
            locationPathName = buildPath,
            target = BuildTarget.StandaloneWindows64,
            options = BuildOptions.None
        };
        
        // Выполняем сборку
        BuildReport report = BuildPipeline.BuildPlayer(buildPlayerOptions);
        BuildSummary summary = report.summary;
        
        // Вывод результатов
        Debug.Log("=== РЕЗУЛЬТАТЫ СБОРКИ ===");
        Debug.Log($"Статус: {summary.result}");
        Debug.Log($"Общее время: {summary.totalTime.ToString("F2")} сек");
        Debug.Log($"Размер: {(summary.totalSize / 1024f / 1024f).ToString("F2")} MB");
        
        if (summary.result == BuildResult.Succeeded)
        {
            Debug.Log("✅ СБОРКА УСПЕШНО ЗАВЕРШЕНА!");
            Debug.Log($"EXE файл создан: {buildPath}");
        }
        else if (summary.result == BuildResult.Failed)
        {
            Debug.LogError("❌ СБОРКА ПРОВАЛИЛАСЬ!");
            
            if (report.steps != null)
            {
                foreach (var step in report.steps)
                {
                    if (step.result == BuildStepResult.Failure)
                    {
                        Debug.LogError($"Ошибка в шаге: {step.name}");
                        foreach (var message in step.messages)
                        {
                            Debug.LogError($"  {message.content}");
                        }
                    }
                }
            }
        }
        else if (summary.result == BuildResult.Cancelled)
        {
            Debug.LogWarning("⚠️ СБОРКА ОТМЕНЕНА!");
        }
        else if (summary.result == BuildResult.Unknown)
        {
            Debug.LogWarning("⚠️ НЕИЗВЕСТНЫЙ РЕЗУЛЬТАТ!");
        }
    }
    
    private static string[] GetEnabledScenes()
    {
        return EditorBuildSettings.scenes
            .Where(scene => scene.enabled)
            .Select(scene => scene.path)
            .ToArray();
    }
    
    [MenuItem("Build/Test Menu Systems")]
    public static void TestMenuSystems()
    {
        Debug.Log("=== ТЕСТИРОВАНИЕ СИСТЕМЫ МЕНЮ ===");
        
        // Проверяем наличие UI документов
        string[] uxmlFiles = {
            "Assets/UI Toolkit/MainMenu.uxml",
            "Assets/UI Toolkit/SettingsMenu.uxml",
            "Assets/UI Toolkit/GameMenu.uxml",
            "Assets/UI Toolkit/PauseMenu.uxml"
        };
        
        foreach (var file in uxmlFiles)
        {
            if (AssetDatabase.LoadAssetAtPath<UnityEngine.Object>(file) != null)
            {
                Debug.Log($"✅ Найден: {file}");
            }
            else
            {
                Debug.LogError($"❌ Не найден: {file}");
            }
        }
        
        // Проверяем скрипты
        string[] scripts = {
            "Assets/Scripts/Managers/MenuManager.cs",
            "Assets/Scripts/Managers/GameManager.cs",
            "Assets/Scripts/Managers/AudioManager.cs",
            "Assets/Scripts/UI/UITestRunner.cs"
        };
        
        foreach (var script in scripts)
        {
            if (AssetDatabase.LoadAssetAtPath<UnityEngine.Object>(script) != null)
            {
                Debug.Log($"✅ Скрипт доступен: {script}");
            }
            else
            {
                Debug.LogError($"❌ Скрипт не доступен: {script}");
            }
        }
        
        Debug.Log("=== ТЕСТИРОВАНИЕ ЗАВЕРШЕНО ===");
    }
}

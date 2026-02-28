using UnityEditor;
using UnityEditor.Build.Reporting;
using UnityEngine;
using System.IO;
using System.Collections.Generic;

/// <summary>
/// Скрипт автоматической сборки билда.
/// Вызывается из командной строки: -executeMethod "BuildScript.PerformBuild"
/// </summary>
public static class BuildScript
{
    private static string BuildFolder => Path.Combine(Application.dataPath, "..", "Build");
    private const string BuildName = "DragRace.exe";
    private static string BuildPath => Path.Combine(BuildFolder, BuildName);

    /// <summary>
    /// Выполняет сборку Windows билда.
    /// Вызывается из командной строки Unity.
    /// </summary>
    [MenuItem("File/Build Windows X64")]
    public static void PerformBuild()
    {
        Debug.Log("[Build] Начало сборки...");

        if (!Directory.Exists(BuildFolder))
        {
            Directory.CreateDirectory(BuildFolder);
            Debug.Log($"[Build] Создана папка: {BuildFolder}");
        }

        var scenes = GetEnabledScenes();

        if (scenes.Length == 0)
        {
            Debug.LogError("[Build] Нет сцен в Build Settings!");
            return;
        }

        Debug.Log($"[Build] Сцены для сборки: {scenes.Length}");

        foreach (var scene in scenes)
        {
            Debug.Log($"  - {scene}");
        }

        BuildPlayerOptions buildPlayerOptions = new BuildPlayerOptions
        {
            scenes = scenes,
            locationPathName = BuildPath,
            target = BuildTarget.StandaloneWindows64,
            options = BuildOptions.None
        };

        Debug.Log($"[Build] Сборка: {BuildPath}");
        BuildReport report = BuildPipeline.BuildPlayer(buildPlayerOptions);

        if (report.summary.result == BuildResult.Succeeded)
        {
            Debug.Log($"[Build] Сборка завершена успешно!");
            Debug.Log($"[Build] Размер: {GetFileSize(BuildPath)} MB");
        }
        else if (report.summary.result == BuildResult.Failed)
        {
            Debug.LogError("[Build] Сборка НЕУДАЧНА!");
        }
        else
        {
            Debug.LogWarning($"[Build] Сборка завершена с результатом: {report.summary.result}");
        }
    }

    private static string[] GetEnabledScenes()
    {
        var scenes = new List<string>();

        for (int i = 0; i < EditorBuildSettings.scenes.Length; i++)
        {
            if (EditorBuildSettings.scenes[i].enabled)
            {
                scenes.Add(EditorBuildSettings.scenes[i].path);
            }
        }

        return scenes.ToArray();
    }

    private static double GetFileSize(string path) => File.Exists(path) ? new FileInfo(path).Length / (1024.0 * 1024.0) : 0;
}

using UnityEngine;
using UnityEditor;
using DragRace.Data;
using DragRace.Core;

namespace DragRace.Editor
{
    /// <summary>
    /// Редактор для создания ScriptableObject ассетов
    /// </summary>
    public class ScriptableObjectCreator : EditorWindow
    {
        [MenuItem("DragRace/Создать конфигурации")]
        public static void CreateAllConfigs()
        {
            CreateGameConfig();
            CreateCarDatabase();
            CreatePartsDatabase();
            Debug.Log("Все конфигурации созданы в Assets/Resources/");
        }
        
        [MenuItem("DragRace/Создать GameConfig")]
        public static void CreateGameConfig()
        {
            string path = "Assets/Resources/GameConfig.asset";
            
            var config = DatabaseInitializer.CreateDefaultGameConfig();
            
            AssetDatabase.CreateAsset(config, path);
            AssetDatabase.SaveAssets();
            
            Debug.Log($"GameConfig создан: {path}");
        }
        
        [MenuItem("DragRace/Создать CarDatabase")]
        public static void CreateCarDatabase()
        {
            string path = "Assets/Resources/CarDatabase.asset";
            
            var db = DatabaseInitializer.CreateDefaultCarDatabase();
            
            AssetDatabase.CreateAsset(db, path);
            AssetDatabase.SaveAssets();
            
            Debug.Log($"CarDatabase создан: {path}");
        }
        
        [MenuItem("DragRace/Создать PartsDatabase")]
        public static void CreatePartsDatabase()
        {
            string path = "Assets/Resources/PartsDatabase.asset";
            
            var db = DatabaseInitializer.CreateDefaultPartsDatabase();
            
            AssetDatabase.CreateAsset(db, path);
            AssetDatabase.SaveAssets();
            
            Debug.Log($"PartsDatabase создан: {path}");
        }
    }
    
    /// <summary>
    /// Построитель игры
    /// </summary>
    public class GameBuilder
    {
        [MenuItem("DragRace/Построить игру")]
        public static void BuildGame()
        {
            string[] scenes = {
                "Assets/Scenes/Boot.unity",
                "Assets/Scenes/MainMenu.unity",
                "Assets/Scenes/Race.unity"
            };
            
            string buildPath = "Builds/DragRace.exe";
            
            BuildPlayerOptions buildPlayerOptions = new BuildPlayerOptions
            {
                scenes = scenes,
                locationPathName = buildPath,
                target = BuildTarget.StandaloneWindows64,
                options = BuildOptions.None
            };
            
            BuildPipeline.BuildPlayer(buildPlayerOptions);
            
            Debug.Log($"Игра построена: {buildPath}");
        }
        
        [MenuItem("DragRace/Построить и запустить")]
        public static void BuildAndRun()
        {
            string[] scenes = {
                "Assets/Scenes/Boot.unity",
                "Assets/Scenes/MainMenu.unity",
                "Assets/Scenes/Race.unity"
            };
            
            string buildPath = "Builds/DragRace.exe";
            
            BuildPlayerOptions buildPlayerOptions = new BuildPlayerOptions
            {
                scenes = scenes,
                locationPathName = buildPath,
                target = BuildTarget.StandaloneWindows64,
                options = BuildOptions.AutoRunPlayer
            };
            
            BuildPipeline.BuildPlayer(buildPlayerOptions);
            
            Debug.Log($"Игра построена и запущена: {buildPath}");
        }
    }
}

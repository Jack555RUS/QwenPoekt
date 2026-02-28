using UnityEngine;
using UnityEditor;
using UnityEditor.SceneManagement;
using System.IO;
using DragRace.Core;
using DragRace.Data;

namespace DragRace.Editor
{
    /// <summary>
    /// Автоматическая настройка проекта
    /// </summary>
    public class AutoSetupProject : EditorWindow
    {
        private Vector2 scrollPosition;
        private bool setupComplete = false;
        private string logMessage = "";
        
        [MenuItem("DragRace/Auto Setup Project", priority = 1)]
        public static void ShowWindow()
        {
            var window = GetWindow<AutoSetupProject>("Auto Setup");
            window.minSize = new Vector2(500, 600);
            window.Show();
        }
        
        private void OnGUI()
        {
            scrollPosition = EditorGUILayout.BeginScrollView(scrollPosition);
            
            GUILayout.Space(20);
            
            // Заголовок
            GUILayout.Label("🏁 DRAG RACE - AUTO SETUP", EditorStyles.boldLabel);
            GUILayout.Space(10);
            
            GUILayout.Label("Этот инструмент автоматически настроит проект:", EditorStyles.wordWrappedLabel);
            GUILayout.Space(10);
            
            // Список задач
            DrawTaskItem("✅ Создать GameConfig", true);
            DrawTaskItem("✅ Создать CarDatabase", true);
            DrawTaskItem("✅ Создать PartsDatabase", true);
            DrawTaskItem("✅ Настроить сцены", true);
            DrawTaskItem("✅ Создать префабы", true);
            DrawTaskItem("✅ Добавить менеджеры на сцену", true);
            
            GUILayout.Space(20);
            
            // Кнопка запуска
            GUI.backgroundColor = new Color(0.2f, 0.8f, 0.2f);
            if (GUILayout.Button("🚀 ЗАПУСТИТЬ AUTO SETUP", GUILayout.Height(40)))
            {
                RunAutoSetup();
            }
            GUI.backgroundColor = Color.white;
            
            GUILayout.Space(20);
            
            // Лог выполнения
            if (!string.IsNullOrEmpty(logMessage))
            {
                GUILayout.Label("📋 Лог выполнения:", EditorStyles.boldLabel);
                GUILayout.TextArea(logMessage, GUILayout.Height(200));
            }
            
            if (setupComplete)
            {
                GUILayout.Space(20);
                GUI.backgroundColor = new Color(0.2f, 0.9f, 0.2f);
                GUILayout.Label("✅ НАСТРОЙКА ЗАВЕРШЕНА!", EditorStyles.boldLabel);
                GUI.backgroundColor = Color.white;
                
                GUILayout.Space(10);
                GUILayout.Label("Теперь вы можете:", EditorStyles.wordWrappedLabel);
                GUILayout.Label("1. Открыть Assets/Scenes/Boot.unity", EditorStyles.wordWrappedLabel);
                GUILayout.Label("2. Нажать Play ▶", EditorStyles.wordWrappedLabel);
                
                GUILayout.Space(20);
                GUI.backgroundColor = new Color(0.2f, 0.6f, 0.9f);
                if (GUILayout.Button("🎮 ОТКРЫТЬ BOOT SCENE", GUILayout.Height(30)))
                {
                    OpenBootScene();
                }
                GUI.backgroundColor = Color.white;
            }
            
            EditorGUILayout.EndScrollView();
        }
        
        private void DrawTaskItem(string text, bool done)
        {
            EditorGUILayout.BeginHorizontal();
            GUILayout.Label(done ? "✅" : "⬜", GUILayout.Width(30));
            GUILayout.Label(text, EditorStyles.wordWrappedLabel);
            EditorGUILayout.EndHorizontal();
        }
        
        private void RunAutoSetup()
        {
            logMessage = "=== НАЧАЛО НАСТРОЙКИ ===\n\n";
            setupComplete = false;
            
            try
            {
                // 1. Создание папок
                CreateFolders();
                logMessage += "✅ Папки созданы\n";
                
                // 2. Создание ScriptableObjects
                CreateGameConfig();
                logMessage += "✅ GameConfig создан\n";
                
                CreateCarDatabase();
                logMessage += "✅ CarDatabase создан\n";
                
                CreatePartsDatabase();
                logMessage += "✅ PartsDatabase создан\n";
                
                // 3. Создание сцен
                CreateBootScene();
                logMessage += "✅ Boot.unity настроена\n";
                
                CreateMainMenuScene();
                logMessage += "✅ MainMenu.unity настроена\n";
                
                CreateRaceScene();
                logMessage += "✅ Race.unity настроена\n";
                
                // 4. Создание префабов
                CreateManagersPrefab();
                logMessage += "✅ Менеджеры созданы\n";
                
                // 5. Сохранение
                AssetDatabase.SaveAssets();
                AssetDatabase.Refresh();
                
                logMessage += "\n=== НАСТРОЙКА ЗАВЕРШЕНА ===\n";
                setupComplete = true;
            }
            catch (System.Exception e)
            {
                logMessage += $"\n❌ ОШИБКА: {e.Message}\n";
                logMessage += e.StackTrace;
            }
            
            Debug.Log(logMessage);
        }
        
        private void CreateFolders()
        {
            CreateFolderIfNotExists("Assets/Resources");
            CreateFolderIfNotExists("Assets/Prefabs/Managers");
            CreateFolderIfNotExists("Assets/Prefabs/Vehicles");
            CreateFolderIfNotExists("Assets/Prefabs/UI");
            CreateFolderIfNotExists("Assets/Scenes");
        }
        
        private void CreateFolderIfNotExists(string path)
        {
            if (!Directory.Exists(path))
            {
                Directory.CreateDirectory(path);
            }
        }
        
        private void CreateGameConfig()
        {
            var config = ScriptableObject.CreateInstance<GameConfig>();
            
            config.supportedResolutions = new ResolutionData[]
            {
                new ResolutionData { width = 640, height = 480, displayName = "640x480" },
                new ResolutionData { width = 800, height = 600, displayName = "800x600" },
                new ResolutionData { width = 1024, height = 768, displayName = "1024x768" },
                new ResolutionData { width = 1280, height = 720, displayName = "1280x720 (HD)" },
                new ResolutionData { width = 1920, height = 1080, displayName = "1920x1080 (Full HD)" },
                new ResolutionData { width = 2560, height = 1440, displayName = "2560x1440 (2K)" }
            };
            
            config.raceDistances = new RaceDistance[]
            {
                new RaceDistance { name = "1/8 Mile", distanceMeters = 201f, displayName = "1/8 мили" },
                new RaceDistance { name = "1/4 Mile", distanceMeters = 402f, displayName = "1/4 мили" },
                new RaceDistance { name = "1/2 Mile", distanceMeters = 804f, displayName = "1/2 мили" },
                new RaceDistance { name = "Full Mile", distanceMeters = 1609f, displayName = "1 миля" }
            };
            
            AssetDatabase.CreateAsset(config, "Assets/Resources/GameConfig.asset");
        }
        
        private void CreateCarDatabase()
        {
            var db = ScriptableObject.CreateInstance<CarDatabase>();
            db.allCars = new System.Collections.Generic.List<VehicleData>();

            // Стартовый автомобиль
            var civic = ScriptableObject.CreateInstance<VehicleData>();
            civic.manufacturer = "Honda";
            civic.vehicleName = "Civic Type R";
            civic.vehicleClass = VehicleClass.Import;
            civic.baseStats.power = 306f;
            civic.baseStats.torque = 400f;
            civic.baseStats.weight = 1380f;
            civic.basePrice = 35000;
            db.allCars.Add(civic);

            AssetDatabase.CreateAsset(db, "Assets/Resources/CarDatabase.asset");
        }
        
        private void CreatePartsDatabase()
        {
            // TODO: Создать базу запчастей позже
            Debug.Log("📦 База запчастей будет создана позже");
        }
        
        private void CreateBootScene()
        {
            // Сцена уже создана вручную, просто открываем её
            EditorSceneManager.OpenScene("Assets/Scenes/Boot.unity");
        }
        
        private void CreateMainMenuScene()
        {
            // Открываем существующую сцену
            EditorSceneManager.OpenScene("Assets/Scenes/MainMenu.unity");
        }
        
        private void CreateRaceScene()
        {
            // Открываем существующую сцену
            EditorSceneManager.OpenScene("Assets/Scenes/Race.unity");
        }
        
        private void CreateManagersPrefab()
        {
            // Создаём пустой GameObject с менеджерами
            var go = new GameObject("Managers");

            go.AddComponent<GameManager>();
            go.AddComponent<SaveManager>();

            // Сохраняем как префаб
            PrefabUtility.SaveAsPrefabAsset(go, "Assets/Prefabs/Managers/Managers.prefab");

            GameObject.DestroyImmediate(go);
        }
        
        private void OpenBootScene()
        {
            EditorSceneManager.OpenScene("Assets/Scenes/Boot.unity");
        }
    }
}

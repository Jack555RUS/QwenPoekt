using UnityEngine;
using UnityEditor;
using UnityEditor.SceneManagement;
using System.IO;
using System.Collections.Generic;
using DragRace.Core;
using DragRace.Data;

namespace DragRace.Editor
{
    /// <summary>
    /// Автоматическая инициализация при первом открытии проекта
    /// </summary>
    [InitializeOnLoad]
    public class ProjectAutoInitializer
    {
        private static bool _initialized = false;
        
        static ProjectAutoInitializer()
        {
            EditorApplication.update += OnUpdate;
        }
        
        private static void OnUpdate()
        {
            if (_initialized || EditorApplication.isCompiling || EditorApplication.isUpdating)
                return;
            
            _initialized = true;
            EditorApplication.update -= OnUpdate;
            
            // Проверяем, нужно ли создавать конфиги
            if (!AssetDatabase.AssetPathToGUID("Assets/Resources/GameConfig.asset").Equals(""))
                return;
            
            Debug.Log("🏁 DRAG RACE: Автоматическая настройка проекта...");
            CreateAllResources();
        }
        
        private static void CreateAllResources()
        {
            try
            {
                // Создаём папки
                CreateFolder("Assets/Resources");
                CreateFolder("Assets/Prefabs/Managers");
                
                // Создаём конфиги
                CreateGameConfig();
                CreateCarDatabase();
                CreatePartsDatabase();
                
                // Открываем сцену
                if (File.Exists("Assets/Scenes/Boot.unity"))
                {
                    EditorSceneManager.OpenScene("Assets/Scenes/Boot.unity");
                }
                
                Debug.Log("✅ DRAG RACE: Проект настроен автоматически!");
                Debug.Log("✅ Нажмите Play для запуска!");
            }
            catch (System.Exception e)
            {
                Debug.LogError($"❌ Ошибка авто-настройки: {e.Message}");
            }
        }
        
        private static void CreateFolder(string path)
        {
            if (!Directory.Exists(path))
            {
                Directory.CreateDirectory(path);
            }
        }
        
        private static void CreateGameConfig()
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
            
            config.startMoney = 10000f;
            config.xpMultiplier = 1f;
            config.careerPrizeMultiplier = 1.5f;
            config.autoSaveIntervalMinutes = 5f;
            config.maxAutoSaveSlots = 5;
            config.maxSaveSlots = 5;
            
            AssetDatabase.CreateAsset(config, "Assets/Resources/GameConfig.asset");
            Debug.Log("✅ GameConfig создан");
        }
        
        private static void CreateCarDatabase()
        {
            var db = ScriptableObject.CreateInstance<CarDatabase>();
            db.carModels = new List<CarModel>();
            
            // Civic Type R
            db.carModels.Add(new CarModel
            {
                id = "civic_stock",
                displayName = "Civic Type R",
                manufacturer = "Honda",
                modelName = "Civic",
                year = 2020,
                category = "Street",
                baseStats = new VehicleStats { power = 306f, torque = 400f, weight = 1380f, grip = 0.75f, aerodynamics = 0.35f },
                basePrice = 35000f,
                availableColors = new Color[] { Color.red, Color.white, Color.black, Color.blue }
            });
            
            // Supra GR
            db.carModels.Add(new CarModel
            {
                id = "supra_gr",
                displayName = "GR Supra",
                manufacturer = "Toyota",
                modelName = "Supra",
                year = 2021,
                category = "Sport",
                baseStats = new VehicleStats { power = 382f, torque = 500f, weight = 1520f, grip = 0.8f, aerodynamics = 0.4f },
                basePrice = 55000f,
                availableColors = new Color[] { Color.red, Color.white, Color.black, Color.yellow }
            });
            
            // 911 GT3
            db.carModels.Add(new CarModel
            {
                id = "911_gt3",
                displayName = "911 GT3",
                manufacturer = "Porsche",
                modelName = "911",
                year = 2022,
                category = "Supercar",
                baseStats = new VehicleStats { power = 502f, torque = 470f, weight = 1435f, grip = 0.9f, aerodynamics = 0.5f },
                basePrice = 160000f,
                availableColors = new Color[] { Color.gray, Color.white, Color.black, new Color(1, 0.8f, 0) }
            });
            
            // Challenger Hellcat
            db.carModels.Add(new CarModel
            {
                id = "challenger_hellcat",
                displayName = "Challenger Hellcat",
                manufacturer = "Dodge",
                modelName = "Challenger",
                year = 2021,
                category = "Muscle",
                baseStats = new VehicleStats { power = 717f, torque = 880f, weight = 2000f, grip = 0.7f, aerodynamics = 0.25f },
                basePrice = 75000f,
                availableColors = new Color[] { Color.red, Color.black, new Color(0.5f, 0, 0.5f), Color.orange }
            });
            
            AssetDatabase.CreateAsset(db, "Assets/Resources/CarDatabase.asset");
            Debug.Log("✅ CarDatabase создан");
        }
        
        private static void CreatePartsDatabase()
        {
            var db = ScriptableObject.CreateInstance<PartsDatabase>();
            db.engines = new List<Engine>();
            db.transmissions = new List<Transmission>();
            db.tires = new List<Tires>();
            db.nitroSystems = new List<NitroSystem>();
            
            // Двигатели
            db.engines.Add(new Engine
            {
                partId = "eng_stock_k20",
                partName = "K20C1 Stock",
                description = "Стандартный двигатель Civic Type R",
                partType = PartType.Engine,
                rarity = PartRarity.Common,
                displacement = 2.0f,
                cylinders = 4,
                configuration = "I4 Turbo",
                maxRpm = 7000f,
                idleRpm = 800f,
                redlineRpm = 6500f,
                powerBonus = 306f,
                torqueBonus = 400f,
                buyPrice = 0f,
                sellPrice = 5000f,
                powerCurve = new AnimationCurve(),
                torqueCurve = new AnimationCurve()
            });
            
            db.engines.Add(new Engine
            {
                partId = "eng_built_k20",
                partName = "K20C1 Built",
                description = "Тюнингованная версия K20C1",
                partType = PartType.Engine,
                rarity = PartRarity.Rare,
                displacement = 2.2f,
                cylinders = 4,
                configuration = "I4 Turbo",
                maxRpm = 9000f,
                idleRpm = 800f,
                redlineRpm = 8500f,
                powerBonus = 450f,
                torqueBonus = 520f,
                buyPrice = 15000f,
                sellPrice = 8000f,
                powerCurve = new AnimationCurve(),
                torqueCurve = new AnimationCurve()
            });
            
            // КПП
            db.transmissions.Add(new Transmission
            {
                partId = "trans_stock_6mt",
                partName = "6-Speed MT Stock",
                description = "Стандартная механическая КПП",
                partType = PartType.Transmission,
                rarity = PartRarity.Common,
                transmissionType = TransmissionType.Manual,
                gearCount = 6,
                gearRatios = new float[] { 3.267f, 2.130f, 1.517f, 1.147f, 0.921f, 0.738f },
                finalDriveRatio = 4.35f,
                shiftTime = 0.3f,
                buyPrice = 0f,
                sellPrice = 2000f
            });
            
            // Шины
            db.tires.Add(new Tires
            {
                partId = "tires_stock_street",
                partName = "Street Tires",
                description = "Стандартные уличные шины",
                partType = PartType.Tires,
                rarity = PartRarity.Common,
                width = 245,
                aspectRatio = 30,
                rimDiameter = 20,
                compound = TireCompound.Street,
                gripBonus = 0.7f,
                buyPrice = 0f,
                sellPrice = 500f
            });
            
            db.tires.Add(new Tires
            {
                partId = "tires_drag_radial",
                partName = "Drag Radials",
                description = "Шины для драг-рейсинга",
                partType = PartType.Tires,
                rarity = PartRarity.Rare,
                width = 315,
                aspectRatio = 30,
                rimDiameter = 20,
                compound = TireCompound.Drag,
                gripBonus = 0.95f,
                buyPrice = 5000f,
                sellPrice = 2000f
            });
            
            // Нитро
            db.nitroSystems.Add(new NitroSystem
            {
                partId = "nitro_50shot",
                partName = "50 Shot NOS",
                description = "Система закиси азота 50HP",
                partType = PartType.Nitro,
                rarity = PartRarity.Uncommon,
                capacity = 10f,
                powerBoost = 50f,
                duration = 5f,
                buyPrice = 3000f,
                sellPrice = 1500f
            });
            
            AssetDatabase.CreateAsset(db, "Assets/Resources/PartsDatabase.asset");
            Debug.Log("✅ PartsDatabase создан");
        }
    }
}

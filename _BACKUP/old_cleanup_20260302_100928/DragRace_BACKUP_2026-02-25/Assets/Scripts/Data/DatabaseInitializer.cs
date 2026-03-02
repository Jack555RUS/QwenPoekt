using UnityEngine;
using DragRace.Core;

namespace DragRace.Data
{
    /// <summary>
    /// Инициализация баз данных и конфигураций
    /// </summary>
    public static class DatabaseInitializer
    {
        /// <summary>
        /// Создать конфигурацию игры по умолчанию
        /// </summary>
        public static GameConfig CreateDefaultGameConfig()
        {
            var config = ScriptableObject.CreateInstance<GameConfig>();
            
            // Разрешения
            config.supportedResolutions = new ResolutionData[]
            {
                new ResolutionData { width = 640, height = 480, displayName = "640x480" },
                new ResolutionData { width = 800, height = 600, displayName = "800x600" },
                new ResolutionData { width = 1024, height = 768, displayName = "1024x768" },
                new ResolutionData { width = 1280, height = 720, displayName = "1280x720 (HD)" },
                new ResolutionData { width = 1920, height = 1080, displayName = "1920x1080 (Full HD)" },
                new ResolutionData { width = 2560, height = 1440, displayName = "2560x1440 (2K)" }
            };
            
            // Дистанции заездов
            config.raceDistances = new RaceDistance[]
            {
                new RaceDistance { name = "1/8 Mile", distanceMeters = 201f, displayName = "1/8 мили" },
                new RaceDistance { name = "1/4 Mile", distanceMeters = 402f, displayName = "1/4 мили" },
                new RaceDistance { name = "1/2 Mile", distanceMeters = 804f, displayName = "1/2 мили" },
                new RaceDistance { name = "Full Mile", distanceMeters = 1609f, displayName = "1 миля" }
            };
            
            return config;
        }
        
        /// <summary>
        /// Создать базу данных автомобилей по умолчанию
        /// </summary>
        public static CarDatabase CreateDefaultCarDatabase()
        {
            var db = ScriptableObject.CreateInstance<CarDatabase>();
            db.carModels = new System.Collections.Generic.List<CarModel>();
            
            // Стартовый автомобиль
            db.carModels.Add(new CarModel
            {
                id = "civic_stock",
                displayName = "Civic Type R",
                manufacturer = "Honda",
                modelName = "Civic",
                year = 2020,
                category = "Street",
                baseStats = new VehicleStats
                {
                    power = 306f,
                    torque = 400f,
                    weight = 1380f,
                    grip = 0.75f,
                    aerodynamics = 0.35f
                },
                basePrice = 35000f,
                availableTrims = new System.Collections.Generic.List<CarTrim>(),
                availableColors = new Color[] { Color.red, Color.white, Color.black, Color.blue },
                displayLength = 4.5f,
                displayHeight = 1.4f
            });
            
            // Спортивный автомобиль
            db.carModels.Add(new CarModel
            {
                id = "supra_gr",
                displayName = "GR Supra",
                manufacturer = "Toyota",
                modelName = "Supra",
                year = 2021,
                category = "Sport",
                baseStats = new VehicleStats
                {
                    power = 382f,
                    torque = 500f,
                    weight = 1520f,
                    grip = 0.8f,
                    aerodynamics = 0.4f
                },
                basePrice = 55000f,
                availableTrims = new System.Collections.Generic.List<CarTrim>(),
                availableColors = new Color[] { Color.red, Color.white, Color.black, Color.yellow },
                displayLength = 4.4f,
                displayHeight = 1.3f
            });
            
            // Суперкар
            db.carModels.Add(new CarModel
            {
                id = "911_gt3",
                displayName = "911 GT3",
                manufacturer = "Porsche",
                modelName = "911",
                year = 2022,
                category = "Supercar",
                baseStats = new VehicleStats
                {
                    power = 502f,
                    torque = 470f,
                    weight = 1435f,
                    grip = 0.9f,
                    aerodynamics = 0.5f
                },
                basePrice = 160000f,
                availableTrims = new System.Collections.Generic.List<CarTrim>(),
                availableColors = new Color[] { Color.gray, Color.white, Color.black, new Color(1, 0.8f, 0) },
                displayLength = 4.6f,
                displayHeight = 1.3f
            });
            
            // Маслкар
            db.carModels.Add(new CarModel
            {
                id = "challenger_hellcat",
                displayName = "Challenger Hellcat",
                manufacturer = "Dodge",
                modelName = "Challenger",
                year = 2021,
                category = "Muscle",
                baseStats = new VehicleStats
                {
                    power = 717f,
                    torque = 880f,
                    weight = 2000f,
                    grip = 0.7f,
                    aerodynamics = 0.25f
                },
                basePrice = 75000f,
                availableTrims = new System.Collections.Generic.List<CarTrim>(),
                availableColors = new Color[] { Color.red, Color.black, new Color(0.5f, 0, 0.5f), Color.orange },
                displayLength = 5.0f,
                displayHeight = 1.45f
            });
            
            return db;
        }
        
        /// <summary>
        /// Создать базу данных запчастей по умолчанию
        /// </summary>
        public static PartsDatabase CreateDefaultPartsDatabase()
        {
            var db = ScriptableObject.CreateInstance<PartsDatabase>();
            
            db.engines = new System.Collections.Generic.List<Engine>();
            db.transmissions = new System.Collections.Generic.List<Transmission>();
            db.tires = new System.Collections.Generic.List<Tires>();
            db.nitroSystems = new System.Collections.Generic.List<NitroSystem>();
            
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
                weightChange = 0f,
                buyPrice = 0f,
                sellPrice = 5000f
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
                weightChange = -10f,
                buyPrice = 15000f,
                sellPrice = 8000f
            });
            
            db.engines.Add(new Engine
            {
                partId = "eng_2jz_gte",
                partName = "2JZ-GTE",
                description = "Легендарный двигатель от Supra",
                partType = PartType.Engine,
                rarity = PartRarity.Legendary,
                displacement = 3.0f,
                cylinders = 6,
                configuration = "I6 Twin-Turbo",
                maxRpm = 8000f,
                idleRpm = 700f,
                redlineRpm = 7200f,
                powerBonus = 600f,
                torqueBonus = 700f,
                weightChange = 30f,
                buyPrice = 50000f,
                sellPrice = 25000f
            });
            
            // Коробки передач
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
                weightChange = 0f,
                buyPrice = 0f,
                sellPrice = 2000f
            });
            
            db.transmissions.Add(new Transmission
            {
                partId = "trans_pdk_7sp",
                partName = "7-Speed PDK",
                description = "Спортивная КПП с двойным сцеплением",
                partType = PartType.Transmission,
                rarity = PartRarity.Epic,
                transmissionType = TransmissionType.PDK,
                gearCount = 7,
                gearRatios = new float[] { 3.91f, 2.29f, 1.65f, 1.32f, 1.14f, 0.97f, 0.82f },
                finalDriveRatio = 3.44f,
                shiftTime = 0.1f,
                weightChange = 5f,
                buyPrice = 25000f,
                sellPrice = 12000f
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
                weightChange = 0f,
                buyPrice = 0f,
                sellPrice = 500f
            });
            
            db.tires.Add(new Tires
            {
                partId = "tires_drag_radial",
                partName = "Drag Radials",
                description = "Специализированные шины для драг-рейсинга",
                partType = PartType.Tires,
                rarity = PartRarity.Rare,
                width = 315,
                aspectRatio = 30,
                rimDiameter = 20,
                compound = TireCompound.Drag,
                gripBonus = 0.95f,
                weightChange = 5f,
                buyPrice = 5000f,
                sellPrice = 2000f
            });
            
            db.tires.Add(new Tires
            {
                partId = "tires_slick_pro",
                partName = "Pro Slicks",
                description = "Профессиональные слики для гонок",
                partType = PartType.Tires,
                rarity = PartRarity.Epic,
                width = 335,
                aspectRatio = 25,
                rimDiameter = 21,
                compound = TireCompound.Slick,
                gripBonus = 1.0f,
                weightChange = 3f,
                buyPrice = 10000f,
                sellPrice = 4500f
            });
            
            // Нитро системы
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
                gripBonus = 0f,
                weightChange = 15f,
                buyPrice = 3000f,
                sellPrice = 1500f
            });
            
            db.nitroSystems.Add(new NitroSystem
            {
                partId = "nitro_150shot",
                partName = "150 Shot NOS",
                description = "Мощная система закиси азота 150HP",
                partType = PartType.Nitro,
                rarity = PartRarity.Rare,
                capacity = 15f,
                powerBoost = 150f,
                duration = 8f,
                gripBonus = 0f,
                weightChange = 25f,
                buyPrice = 8000f,
                sellPrice = 4000f
            });
            
            return db;
        }
    }
}

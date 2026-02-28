using System;
using System.Collections.Generic;
using UnityEngine;

namespace DragRace.Data
{
    /// <summary>
    /// Основные игровые данные
    /// </summary>
    [Serializable]
    public class GameData
    {
        // Информация о игроке
        public PlayerData playerData;
        
        // Гараж игрока
        public List<VehicleData> playerVehicles;
        public int currentVehicleIndex;
        
        // Инвентарь запчастей
        public List<VehiclePartData> inventory;
        
        // Прогресс
        public List<RaceResult> raceHistory;
        public Dictionary<string, bool> unlockedContent;
        
        // Время игры
        public float totalPlayTime;
        public DateTime lastPlaySession;
        
        public GameData()
        {
            playerData = new PlayerData();
            playerVehicles = new List<VehicleData>();
            inventory = new List<VehiclePartData>();
            raceHistory = new List<RaceResult>();
            unlockedContent = new Dictionary<string, bool>();
            currentVehicleIndex = 0;
            totalPlayTime = 0f;
        }
    }
    
    /// <summary>
    /// Данные игрока
    /// </summary>
    [Serializable]
    public class PlayerData
    {
        public string playerName;
        public int level;
        public float experience;
        public float experienceToNextLevel;
        public float money;
        public int totalRaces;
        public int totalWins;
        public float totalDistanceKm;
        
        // Характеристики
        public float reactionTime; //越小越好 (меньше = лучше)
        public float shiftSpeed; //越小越好
        
        // Очки улучшения
        public int upgradePoints;
        
        public PlayerData()
        {
            playerName = "Racer";
            level = 1;
            experience = 0f;
            experienceToNextLevel = 100f;
            money = 10000f;
            totalRaces = 0;
            totalWins = 0;
            totalDistanceKm = 0f;
            reactionTime = 0.5f;
            shiftSpeed = 0.3f;
            upgradePoints = 0;
        }
        
        public void AddExperience(float xp)
        {
            experience += xp;
            while (experience >= experienceToNextLevel)
            {
                experience -= experienceToNextLevel;
                level++;
                upgradePoints += 5;
                experienceToNextLevel *= 1.2f;
            }
        }
    }
    
    /// <summary>
    /// Данные автомобиля
    /// </summary>
    [Serializable]
    public class VehicleData
    {
        public string vehicleId;
        public string vehicleName;
        public string modelName;
        public string manufacturer;
        public int year;
        
        // Характеристики
        public VehicleStats baseStats;
        public VehicleStats currentStats;
        
        // Установленные части
        public string engineId;
        public string transmissionId;
        public string tiresId;
        
        // Состояние
        public float condition; // 0-100%
        public bool isOwned;
        public float purchasePrice;
        public float currentValue;
        
        // Визуал
        public Color paintColor;
        public int visualVariant;
        
        public VehicleData()
        {
            baseStats = new VehicleStats();
            currentStats = new VehicleStats();
            condition = 100f;
            isOwned = false;
            paintColor = Color.red;
        }
    }
    
    /// <summary>
    /// Характеристики автомобиля
    /// </summary>
    [Serializable]
    public class VehicleStats
    {
        public float power; // л.с.
        public float torque; // Нм
        public float weight; // кг
        public float grip; // коэффициент сцепления 0-1
        public float aerodynamics; // коэффициент аэродинамики
        
        public float powerToWeight => power / (weight / 1000f);
        
        public VehicleStats()
        {
            power = 100f;
            torque = 150f;
            weight = 1000f;
            grip = 0.7f;
            aerodynamics = 0.3f;
        }
    }
    
    /// <summary>
    /// Данные запчасти
    /// </summary>
    [Serializable]
    public class VehiclePartData
    {
        public string partId;
        public string partName;
        public PartType partType;
        public PartRarity rarity;
        
        // Характеристики
        public VehicleStats statsBonus;
        
        // Экономика
        public float buyPrice;
        public float sellPrice;
        
        // Состояние
        public bool isInstalled;
        public bool isUsed; // б/у
        
        public VehiclePartData()
        {
            statsBonus = new VehicleStats();
        }
    }
    
    public enum PartType
    {
        Engine,
        Transmission,
        Tires,
        Exhaust,
        Turbo,
        Suspension,
        Brakes,
        Nitro
    }
    
    public enum PartRarity
    {
        Common,      // Обычное
        Uncommon,    // Необычное
        Rare,        // Редкое
        Epic,        // Эпическое
        Legendary    // Легендарное
    }
    
    /// <summary>
    /// Результат заезда
    /// </summary>
    [Serializable]
    public class RaceResult
    {
        public DateTime raceDate;
        public string distanceName;
        public float distanceMeters;
        public float time;
        public float topSpeed;
        public bool isWin;
        public string opponentName;
        public float earnedMoney;
        public float earnedXp;
        public VehicleData usedVehicle;
    }
    
    /// <summary>
    /// Настройки игры
    /// </summary>
    [Serializable]
    public class SettingsData
    {
        public int screenWidth;
        public int screenHeight;
        public bool fullscreen;
        public int masterVolume;
        public int musicVolume;
        public int sfxVolume;
        public KeyBindings keyBindings;
        
        public SettingsData()
        {
            screenWidth = 1920;
            screenHeight = 1080;
            fullscreen = false;
            masterVolume = 80;
            musicVolume = 60;
            sfxVolume = 70;
            keyBindings = new KeyBindings();
        }
    }
    
    /// <summary>
    /// Привязка клавиш
    /// </summary>
    [Serializable]
    public class KeyBindings
    {
        public KeyCode accelerate;
        public KeyCode shiftUp;
        public KeyCode shiftDown;
        public KeyCode nitro;
        public KeyCode pause;
        
        public KeyBindings()
        {
            accelerate = KeyCode.W;
            shiftUp = KeyCode.D;
            shiftDown = KeyCode.A;
            nitro = KeyCode.LeftShift;
            pause = KeyCode.Escape;
        }
    }
}

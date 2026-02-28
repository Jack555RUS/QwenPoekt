using System;
using System.Collections.Generic;

namespace DragRace.Core
{
    /// <summary>
    /// Данные игрока (сериализуемые)
    /// </summary>
    [Serializable]
    public class PlayerData
    {
        // Основная информация
        public string playerName;
        public int level;
        public int experience;
        public int money;
        
        // Прогресс карьеры
        public int careerTier;
        public int careerRaceIndex;
        
        // Статистика
        public int totalRaces;
        public int totalWins;
        public float totalDistance;
        
        // Характеристики персонажа (1.0 = база, 2.0 = макс)
        public float reactionStat;      // Скорость реакции на старте
        public float shiftSpeedStat;    // Скорость переключения передач
        
        // Гараж
        public List<string> ownedCars;  // ID владельцев автомобилей
        public string currentCarId;     // Текущий автомобиль
        
        // Инвентарь (запчасти)
        public Dictionary<string, int> inventory;
        
        // Настройки
        public PlayerSettings settings;
        
        public PlayerData()
        {
            playerName = "Racer";
            level = 1;
            experience = 0;
            money = 10000;
            careerTier = 0;
            careerRaceIndex = 0;
            totalRaces = 0;
            totalWins = 0;
            totalDistance = 0f;
            reactionStat = 1f;
            shiftSpeedStat = 1f;
            ownedCars = new List<string>();
            currentCarId = "";
            inventory = new Dictionary<string, int>();
            settings = new PlayerSettings();
        }
    }

    /// <summary>
    /// Настройки игрока
    /// </summary>
    [Serializable]
    public class PlayerSettings
    {
        public int resolutionIndex;
        public bool fullscreen;
        public int masterVolume;
        public int engineVolume;
        public int musicVolume;
        public Dictionary<string, string> keyBindings;
        
        public PlayerSettings()
        {
            resolutionIndex = 0;
            fullscreen = true;
            masterVolume = 80;
            engineVolume = 100;
            musicVolume = 70;
            keyBindings = new Dictionary<string, string>
            {
                { "Accelerate", "W" },
                { "ShiftUp", "D" },
                { "ShiftDown", "A" },
                { "Nitro", "LeftShift" },
                { "Pause", "Escape" }
            };
        }
    }

    /// <summary>
    /// Данные сохранения
    /// </summary>
    [Serializable]
    public class SaveData
    {
        public PlayerData playerData;
        public string saveDate;
        public string saveTime;
        public bool isAutoSave;
        
        public SaveData(PlayerData data, bool autoSave = false)
        {
            playerData = data;
            isAutoSave = autoSave;
            saveDate = DateTime.Now.ToString("dd.MM.yyyy");
            saveTime = DateTime.Now.ToString("HH:mm:ss");
        }
    }
}

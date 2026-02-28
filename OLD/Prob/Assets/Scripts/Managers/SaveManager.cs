using System;
using System.IO;
using UnityEngine;
using RacingGame.Utilities;

namespace RacingGame.Managers
{
    /// <summary>
    /// Менеджер сохранений. Управляет сохранением и загрузкой данных игры.
    /// </summary>
    [Serializable]
    public class GameData
    {
        public string playerName;
        public int currentMoney;
        public int currentExperience;
        public int unlockedCars;
        public int currentCarIndex;
        public CarData[] ownedCars;
        public string lastScene;
        public float playTime;
        public DateTime lastSaveTime;

        public GameData()
        {
            playerName = "Player";
            currentMoney = 1000;
            currentExperience = 0;
            unlockedCars = 1;
            currentCarIndex = 0;
            ownedCars = new CarData[10];
            lastScene = "MainMenu";
            playTime = 0f;
            lastSaveTime = DateTime.Now;
        }
    }

    [Serializable]
    public class CarData
    {
        public string carName;
        public int speed;
        public int handling;
        public int acceleration;
        public int braking;
        public Color color;

        public CarData(string name = "Car")
        {
            carName = name;
            speed = 50;
            handling = 50;
            acceleration = 50;
            braking = 50;
            color = Color.white;
        }
    }

    public static class SaveManager
    {
        private static readonly string SaveFileName = "savegame.dat";
        private static string SavePath => Path.Combine(Application.persistentDataPath, SaveFileName);

        public static GameData CurrentData { get; private set; }

        public static void Initialize()
        {
            GameLogger.LogInfo($"Путь к сохранениям: {SavePath}");
            CurrentData = null;
        }

        public static bool HasSave()
        {
            bool exists = File.Exists(SavePath);
            GameLogger.LogDebug($"Проверка сохранения: {exists}");
            return exists;
        }

        public static void SaveGame()
        {
            try
            {
                if (CurrentData == null)
                {
                    CurrentData = new GameData();
                }

                CurrentData.lastSaveTime = DateTime.Now;

                string json = JsonUtility.ToJson(CurrentData, true);
                string encrypted = Encrypt(json);

                File.WriteAllText(SavePath, encrypted);
                GameLogger.LogInfo("Игра успешно сохранена");
            }
            catch (Exception ex)
            {
                GameLogger.LogError($"Ошибка сохранения: {ex.Message}");
            }
        }

        public static void LoadGame()
        {
            try
            {
                if (!File.Exists(SavePath))
                {
                    GameLogger.LogWarning("Файл сохранения не найден");
                    return;
                }

                string encrypted = File.ReadAllText(SavePath);
                string json = Decrypt(encrypted);
                CurrentData = JsonUtility.FromJson<GameData>(json);

                GameLogger.LogInfo($"Игра загружена: Игрок={CurrentData.playerName}, Деньги={CurrentData.currentMoney}");
            }
            catch (Exception ex)
            {
                GameLogger.LogError($"Ошибка загрузки: {ex.Message}");
                CurrentData = new GameData();
            }
        }

        public static void CreateNewGame(string playerName = "Player")
        {
            CurrentData = new GameData
            {
                playerName = playerName,
                lastSaveTime = DateTime.Now
            };

            // Инициализируем первую машину
            CurrentData.ownedCars[0] = new CarData("Starter Car");
            CurrentData.ownedCars[0].color = Color.red;

            GameLogger.LogInfo($"Новая игра создана для: {playerName}");
        }

        public static void DeleteSave()
        {
            try
            {
                if (File.Exists(SavePath))
                {
                    File.Delete(SavePath);
                    GameLogger.LogInfo("Сохранение удалено");
                }
                CurrentData = null;
            }
            catch (Exception ex)
            {
                GameLogger.LogError($"Ошибка удаления сохранения: {ex.Message}");
            }
        }

        // Простое шифрование (XOR)
        private static string Encrypt(string data)
        {
            char key = 'K';
            char[] chars = data.ToCharArray();
            for (int i = 0; i < chars.Length; i++)
            {
                chars[i] = (char)(chars[i] ^ key);
            }
            return new string(chars);
        }

        private static string Decrypt(string data)
        {
            return Encrypt(data); // XOR обратим
        }

        // Методы для работы с данными
        public static void AddMoney(int amount)
        {
            if (CurrentData == null) CurrentData = new GameData();
            CurrentData.currentMoney += amount;
            GameLogger.LogInfo($"Добавлено денег: {amount}, всего: {CurrentData.currentMoney}");
        }

        public static void SpendMoney(int amount)
        {
            if (CurrentData == null) CurrentData = new GameData();
            if (CurrentData.currentMoney >= amount)
            {
                CurrentData.currentMoney -= amount;
                GameLogger.LogInfo($"Потрачено денег: {amount}, осталось: {CurrentData.currentMoney}");
            }
            else
            {
                GameLogger.LogWarning("Недостаточно денег");
            }
        }

        public static void AddExperience(int amount)
        {
            if (CurrentData == null) CurrentData = new GameData();
            CurrentData.currentExperience += amount;
            GameLogger.LogInfo($"Добавлено опыта: {amount}, всего: {CurrentData.currentExperience}");
        }

        public static void UpdateCarData(int index, CarData carData)
        {
            if (CurrentData == null) CurrentData = new GameData();
            if (index >= 0 && index < CurrentData.ownedCars.Length)
            {
                CurrentData.ownedCars[index] = carData;
                GameLogger.LogInfo($"Машина {index} обновлена: {carData.carName}");
            }
        }

        public static CarData GetCarData(int index)
        {
            if (CurrentData == null || index < 0 || index >= CurrentData.ownedCars.Length)
            {
                return new CarData();
            }
            return CurrentData.ownedCars[index];
        }
    }
}

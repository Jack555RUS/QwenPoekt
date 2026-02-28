using UnityEngine;
using System;
using System.IO;
using System.Collections.Generic;
using ProbMenu.Core;
using Logger = ProbMenu.Core.Logger;

namespace ProbMenu.SaveSystem
{
    /// <summary>
    /// Менеджер сохранений
    /// 5 слотов ручных сохранений + 5 автосохранений
    /// </summary>
    public class SaveManager : MonoBehaviour
    {
        private static SaveManager _instance;
        public static SaveManager Instance
        {
            get
            {
                if (_instance == null)
                {
                    _instance = FindObjectOfType<SaveManager>();
                    if (_instance == null)
                    {
                        GameObject go = new GameObject("SaveManager");
                        _instance = go.AddComponent<SaveManager>();
                        DontDestroyOnLoad(go);
                        Logger.I("SaveManager created");
                    }
                }
                return _instance;
            }
        }

        // Пути к сохранениям
        private readonly string SAVE_FOLDER = "/Saves";
        private readonly string AUTO_SAVE_FOLDER = "/AutoSaves";
        
        // Количество слотов
        private const int MAX_SAVE_SLOTS = 5;
        private const int MAX_AUTO_SAVES = 5;
        
        // Интервал автосохранения (5 минут)
        private const float AUTO_SAVE_INTERVAL = 300f;
        
        private float _autoSaveTimer = 0f;
        private int _currentAutoSaveIndex = 0;
        private int _totalSavesPerformed = 0;
        private int _totalLoadsPerformed = 0;

        [Serializable]
        public class SaveData
        {
            public string playerName;
            public int level;
            public int experience;
            public int money;
            public int currentCarId;
            public List<int> ownedCars;
            public string lastScene;
            public DateTime saveTime;
            
            public SaveData()
            {
                playerName = "Player";
                level = 1;
                experience = 0;
                money = 1000;
                currentCarId = 0;
                ownedCars = new List<int> { 0 };
                lastScene = "MainMenu";
                saveTime = DateTime.Now;
            }
        }

        private void Start()
        {
            DontDestroyOnLoad(gameObject);
            Logger.I("=== SAVE MANAGER INITIALIZED ===");
            
            // Создать папки для сохранений
            string savesPath = Application.persistentDataPath + SAVE_FOLDER;
            string autoSavesPath = Application.persistentDataPath + AUTO_SAVE_FOLDER;
            
            try
            {
                if (!Directory.Exists(savesPath))
                {
                    Directory.CreateDirectory(savesPath);
                    Logger.D($"Created save folder: {savesPath}");
                }
                
                if (!Directory.Exists(autoSavesPath))
                {
                    Directory.CreateDirectory(autoSavesPath);
                    Logger.D($"Created auto-save folder: {autoSavesPath}");
                }
                
                Logger.I($"Save folder: {savesPath}");
                Logger.I($"Auto-save folder: {autoSavesPath}");
            }
            catch (Exception e)
            {
                Logger.E($"Failed to create save folders: {e.Message}");
            }
        }

        private void Update()
        {
            // Таймер автосохранения
            _autoSaveTimer += Time.deltaTime;
            if (_autoSaveTimer >= AUTO_SAVE_INTERVAL)
            {
                _autoSaveTimer = 0f;
                AutoSave();
            }
        }

        #region Save/Load

        /// <summary>
        /// Сохранить в указанный слот
        /// </summary>
        public bool Save(int slotIndex, SaveData data)
        {
            // Assert проверки
            Logger.Assert(slotIndex >= 0 && slotIndex < MAX_SAVE_SLOTS, 
                $"Invalid save slot: {slotIndex} (must be 0-{MAX_SAVE_SLOTS-1})");
            Logger.AssertNotNull(data, "SaveData");
            Logger.AssertNotNull(data.playerName, "SaveData.playerName");
            
            if (slotIndex < 0 || slotIndex >= MAX_SAVE_SLOTS)
            {
                Logger.E($"Invalid save slot: {slotIndex}");
                return false;
            }

            if (data == null)
            {
                Logger.E("SaveData is null!");
                return false;
            }

            try
            {
                string path = GetSavePath(slotIndex);
                string json = JsonUtility.ToJson(data, true);
                
                Logger.Assert(!string.IsNullOrEmpty(json), "JSON is empty!");
                
                File.WriteAllText(path, json);
                
                _totalSavesPerformed++;
                Logger.I($"✅ Saved to slot {slotIndex}: {path} (Total saves: {_totalSavesPerformed})");
                return true;
            }
            catch (Exception e)
            {
                Logger.E($"❌ Save failed: {e.Message}");
                Logger.C($"Stack trace: {e.StackTrace}");
                return false;
            }
        }

        /// <summary>
        /// Загрузить из указанного слота
        /// </summary>
        public SaveData Load(int slotIndex)
        {
            // Assert проверки
            Logger.Assert(slotIndex >= 0 && slotIndex < MAX_SAVE_SLOTS, 
                $"Invalid save slot: {slotIndex}");
            
            if (slotIndex < 0 || slotIndex >= MAX_SAVE_SLOTS)
            {
                Logger.E($"Invalid save slot: {slotIndex}");
                return null;
            }

            try
            {
                string path = GetSavePath(slotIndex);
                
                if (!File.Exists(path))
                {
                    Logger.D($"Save file not found: {path}");
                    return null;
                }

                string json = File.ReadAllText(path);
                
                Logger.Assert(!string.IsNullOrEmpty(json), "JSON is empty!");
                
                SaveData data = JsonUtility.FromJson<SaveData>(json);
                
                Logger.AssertNotNull(data, "Deserialized SaveData");
                
                _totalLoadsPerformed++;
                Logger.I($"✅ Loaded from slot {slotIndex} (Total loads: {_totalLoadsPerformed})");
                return data;
            }
            catch (Exception e)
            {
                Logger.E($"❌ Load failed: {e.Message}");
                Logger.C($"Stack trace: {e.StackTrace}");
                return null;
            }
        }

        /// <summary>
        /// Проверить существование сохранения
        /// </summary>
        public bool HasSave(int slotIndex)
        {
            string path = GetSavePath(slotIndex);
            return File.Exists(path);
        }

        /// <summary>
        /// Удалить сохранение
        /// </summary>
        public void Delete(int slotIndex)
        {
            string path = GetSavePath(slotIndex);
            
            if (File.Exists(path))
            {
                File.Delete(path);
                Logger.I($"🗑️ Deleted save slot {slotIndex}");
            }
        }

        #endregion

        #region Auto Save

        /// <summary>
        /// Автосохранение (циклически по 5 слотам)
        /// </summary>
        public void AutoSave()
        {
            SaveData data = GetCurrentSaveData();
            
            string path = GetAutoSavePath(_currentAutoSaveIndex);
            
            try
            {
                string json = JsonUtility.ToJson(data, true);
                File.WriteAllText(path, json);
                
                Logger.I($"🔄 Auto-saved to {_currentAutoSaveIndex}: {path}");

                // Циклический переход к следующему слоту
                _currentAutoSaveIndex = (_currentAutoSaveIndex + 1) % MAX_AUTO_SAVES;
            }
            catch (Exception e)
            {
                Logger.E($"❌ Auto-save failed: {e.Message}");
            }
        }

        /// <summary>
        /// Загрузить последнее автосохранение
        /// </summary>
        public SaveData LoadLastAutoSave()
        {
            // Ищем последний по времени автосейв
            string autoSavesPath = Application.persistentDataPath + AUTO_SAVE_FOLDER;
            
            if (!Directory.Exists(autoSavesPath))
                return null;

            string[] files = Directory.GetFiles(autoSavesPath, "*.json");
            
            if (files.Length == 0)
                return null;

            // Сортируем по времени создания
            Array.Sort(files, (a, b) => 
                File.GetLastWriteTime(b).CompareTo(File.GetLastWriteTime(a)));

            try
            {
                string json = File.ReadAllText(files[0]);
                SaveData data = JsonUtility.FromJson<SaveData>(json);

                Logger.I($"✅ Loaded last auto-save: {files[0]}");
                return data;
            }
            catch (Exception e)
            {
                Logger.E($"❌ Load auto-save failed: {e.Message}");
                return null;
            }
        }

        #endregion

        #region Helpers

        private string GetSavePath(int slotIndex)
        {
            return Application.persistentDataPath + SAVE_FOLDER + $"/save_{slotIndex}.json";
        }

        private string GetAutoSavePath(int slotIndex)
        {
            return Application.persistentDataPath + AUTO_SAVE_FOLDER + $"/auto_{slotIndex}.json";
        }

        /// <summary>
        /// Получить текущие данные для сохранения
        /// </summary>
        private SaveData GetCurrentSaveData()
        {
            // TODO: Получить актуальные данные из GameManager
            return new SaveData
            {
                playerName = "Player",
                level = 1,
                experience = 0,
                money = 1000,
                currentCarId = 0,
                ownedCars = new List<int> { 0 },
                lastScene = UnityEngine.SceneManagement.SceneManager.GetActiveScene().name,
                saveTime = DateTime.Now
            };
        }

        /// <summary>
        /// Получить информацию о сохранении
        /// </summary>
        public string GetSaveInfo(int slotIndex)
        {
            SaveData data = Load(slotIndex);
            
            if (data == null)
                return "Пусто";

            return $"{data.playerName} | Ур.{data.level} | ${data.money} | {data.saveTime:dd.MM HH:mm}";
        }

        /// <summary>
        /// Получить статистику сохранений
        /// </summary>
        public string GetStatistics()
        {
            return $"Saves: {_totalSavesPerformed} | Loads: {_totalLoadsPerformed} | Auto-saves: {_currentAutoSaveIndex}";
        }

        #endregion

        #region Quick Saves

        public void QuickSave()
        {
            SaveData data = GetCurrentSaveData();
            Save(0, data); // Быстрое сохранение в слот 0
            Logger.I("⚡ Quick Save!");
        }

        public SaveData QuickLoad()
        {
            Logger.I("⚡ Quick Load!");
            return Load(0);
        }

        #endregion
    }
}

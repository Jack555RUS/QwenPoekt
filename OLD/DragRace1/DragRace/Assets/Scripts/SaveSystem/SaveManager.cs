using UnityEngine;
using System;
using System.IO;
using System.Collections.Generic;

namespace DragRace.Core
{
    /// <summary>
    /// Менеджер сохранений (Singleton)
    /// 5 ручных слотов + 5 автосохранений
    /// </summary>
    public class SaveManager : MonoBehaviour
    {
        #region Singleton
        private static SaveManager _instance;
        
        public static SaveManager Instance
        {
            get
            {
                if (_instance == null)
                {
                    _instance = FindFirstObjectByType<SaveManager>();
                    if (_instance == null)
                    {
                        GameObject go = new GameObject("SaveManager");
                        _instance = go.AddComponent<SaveManager>();
                        DontDestroyOnLoad(go);
                    }
                }
                return _instance;
            }
        }
        #endregion

        #region Constants
        public const int MANUAL_SAVE_SLOTS = 5;
        public const int AUTO_SAVE_SLOTS = 5;
        private const string SAVE_FOLDER = "Saves";
        private const string MANUAL_PREFIX = "save_";
        private const string AUTO_PREFIX = "autosave_";
        #endregion

        #region State
        private PlayerData _currentData;
        private int _currentAutoSaveIndex = 0;
        private bool _isInitialized = false;
        #endregion

        #region Events
        public event Action OnSaveLoaded;
        #endregion

        private void Awake()
        {
            if (_instance != null && _instance != this)
            {
                Destroy(gameObject);
                return;
            }
            _instance = this;
            DontDestroyOnLoad(gameObject);
        }

        /// <summary>
        /// Инициализация менеджера сохранений
        /// </summary>
        public void Initialize()
        {
            if (_isInitialized) return;

            // Создание папки для сохранений
            string savePath = GetSavePath();
            if (!Directory.Exists(savePath))
            {
                Directory.CreateDirectory(savePath);
            }

            // Загрузка индекса автосохранения
            LoadAutoSaveIndex();

            _isInitialized = true;
            Debug.Log("✅ SaveManager инициализирован");
        }

        /// <summary>
        /// Получить путь к папке сохранений
        /// </summary>
        private string GetSavePath()
        {
            return Path.Combine(Application.persistentDataPath, SAVE_FOLDER);
        }

        /// <summary>
        /// Получить путь к файлу сохранения
        /// </summary>
        private string GetSaveFilePath(int slot, bool isAutoSave = false)
        {
            string prefix = isAutoSave ? AUTO_PREFIX : MANUAL_PREFIX;
            return Path.Combine(GetSavePath(), $"{prefix}{slot}.json");
        }

        /// <summary>
        /// Создать новое сохранение
        /// </summary>
        public void CreateNewSave(PlayerData data)
        {
            _currentData = data;
            SaveGame(0); // Сохраняем в первый слот
            Debug.Log($"✅ Новая игра создана: {data.playerName}");
        }

        /// <summary>
        /// Сохранить игру в указанный слот
        /// </summary>
        public void SaveGame(int slot)
        {
            if (_currentData == null)
            {
                Debug.LogError("❌ Нет данных для сохранения!");
                return;
            }

            if (slot < 0 || slot >= MANUAL_SAVE_SLOTS)
            {
                Debug.LogError($"❌ Неверный слот сохранения: {slot}");
                return;
            }

            SaveData saveData = new SaveData(_currentData, false);
            string json = JsonUtility.ToJson(saveData, true);
            string filePath = GetSaveFilePath(slot);

            File.WriteAllText(filePath, json);
            Debug.Log($"💾 Игра сохранена в слот {slot}");
        }

        /// <summary>
        /// Загрузить игру из указанного слота
        /// </summary>
        public bool LoadGame(int slot)
        {
            string filePath = GetSaveFilePath(slot);
            
            if (!File.Exists(filePath))
            {
                Debug.LogWarning($"⚠️ Слот {slot} пуст");
                return false;
            }

            try
            {
                string json = File.ReadAllText(filePath);
                SaveData saveData = JsonUtility.FromJson<SaveData>(json);
                _currentData = saveData.playerData;
                
                Debug.Log($"📂 Игра загружена из слота {slot}");
                Debug.Log($"   Игрок: {_currentData.playerName}");
                Debug.Log($"   Деньги: ${_currentData.money}");
                Debug.Log($"   Уровень: {_currentData.level}");
                
                OnSaveLoaded?.Invoke();
                return true;
            }
            catch (Exception e)
            {
                Debug.LogError($"❌ Ошибка загрузки: {e.Message}");
                return false;
            }
        }

        /// <summary>
        /// Автосохранение
        /// </summary>
        public void AutoSave()
        {
            if (_currentData == null)
            {
                Debug.LogWarning("⚠️ Нечего автосохранять");
                return;
            }

            SaveData saveData = new SaveData(_currentData, true);
            string json = JsonUtility.ToJson(saveData, true);
            string filePath = GetSaveFilePath(_currentAutoSaveIndex, true);

            File.WriteAllText(filePath, json);
            Debug.Log($"💾 Автосохранение #{_currentAutoSaveIndex + 1}");

            // Циклический переход к следующему слоту
            _currentAutoSaveIndex = (_currentAutoSaveIndex + 1) % AUTO_SAVE_SLOTS;
            SaveAutoSaveIndex();
        }

        /// <summary>
        /// Загрузить автосохранение по индексу
        /// </summary>
        public bool LoadAutoSave(int index)
        {
            if (index < 0 || index >= AUTO_SAVE_SLOTS)
            {
                Debug.LogError($"❌ Неверный индекс автосохранения: {index}");
                return false;
            }

            string filePath = GetSaveFilePath(index, true);
            
            if (!File.Exists(filePath))
            {
                Debug.LogWarning($"⚠️ Автосохранение #{index + 1} не найдено");
                return false;
            }

            try
            {
                string json = File.ReadAllText(filePath);
                SaveData saveData = JsonUtility.FromJson<SaveData>(json);
                _currentData = saveData.playerData;
                
                Debug.Log($"📂 Автосохранение #{index + 1} загружено");
                Debug.Log($"   Дата: {saveData.saveDate} {saveData.saveTime}");
                
                OnSaveLoaded?.Invoke();
                return true;
            }
            catch (Exception e)
            {
                Debug.LogError($"❌ Ошибка загрузки автосохранения: {e.Message}");
                return false;
            }
        }

        /// <summary>
        /// Проверить наличие сохранения в слоте
        /// </summary>
        public bool HasSave(int slot, bool isAutoSave = false)
        {
            string filePath = GetSaveFilePath(slot, isAutoSave);
            return File.Exists(filePath);
        }

        /// <summary>
        /// Получить информацию о сохранении
        /// </summary>
        public SaveInfo GetSaveInfo(int slot, bool isAutoSave = false)
        {
            string filePath = GetSaveFilePath(slot, isAutoSave);
            
            if (!File.Exists(filePath))
            {
                return null;
            }

            try
            {
                string json = File.ReadAllText(filePath);
                SaveData saveData = JsonUtility.FromJson<SaveData>(json);
                
                return new SaveInfo
                {
                    playerName = saveData.playerData.playerName,
                    date = saveData.saveDate,
                    time = saveData.saveTime,
                    level = saveData.playerData.level,
                    money = saveData.playerData.money,
                    isAutoSave = saveData.isAutoSave
                };
            }
            catch
            {
                return null;
            }
        }

        /// <summary>
        /// Удалить сохранение
        /// </summary>
        public void DeleteSave(int slot, bool isAutoSave = false)
        {
            string filePath = GetSaveFilePath(slot, isAutoSave);
            
            if (File.Exists(filePath))
            {
                File.Delete(filePath);
                Debug.Log($"🗑️ Сохранение удалено: слот {slot}");
            }
        }

        /// <summary>
        /// Сохранить все данные
        /// </summary>
        public void SaveAll()
        {
            if (_currentData != null)
            {
                SaveGame(0);
            }
            SettingsManager.SaveSettings();
        }

        /// <summary>
        /// Получить текущие данные игрока
        /// </summary>
        public PlayerData GetCurrentData()
        {
            return _currentData;
        }

        /// <summary>
        /// Сохранить индекс автосохранения
        /// </summary>
        private void SaveAutoSaveIndex()
        {
            PlayerPrefs.SetInt("AutoSaveIndex", _currentAutoSaveIndex);
            PlayerPrefs.Save();
        }

        /// <summary>
        /// Загрузить индекс автосохранения
        /// </summary>
        private void LoadAutoSaveIndex()
        {
            _currentAutoSaveIndex = PlayerPrefs.GetInt("AutoSaveIndex", 0);
        }

        /// <summary>
        /// Информация о сохранении для UI
        /// </summary>
        [Serializable]
        public class SaveInfo
        {
            public string playerName;
            public string date;
            public string time;
            public int level;
            public int money;
            public bool isAutoSave;
        }
    }
}

using System;
using System.IO;
using UnityEngine;
using DragRace.Data;

namespace DragRace.SaveSystem
{
    /// <summary>
    /// Менеджер сохранений
    /// </summary>
    public class SaveManager : MonoBehaviour
    {
        public static SaveManager Instance { get; private set; }

        private const string SAVE_FOLDER = "SaveGames";
        private const string AUTO_SAVE_FOLDER = "AutoSaves";
        private const string SETTINGS_FILE = "settings.json";

        // Пути
        private string saveFolderPath;
        private string autoSaveFolderPath;

        // Таймер автосохранения
        private float autoSaveTimer;
        private int currentAutoSaveIndex;

        // Текущие данные
        private GameData currentGameData;
        private SettingsData currentSettings;
        
        // События
        public event Action OnGameSaved;
        public event Action OnGameLoaded;

        private void Awake()
        {
            if (Instance != null && Instance != this)
            {
                Destroy(gameObject);
                return;
            }

            Instance = this;
            DontDestroyOnLoad(gameObject);

            InitializePaths();
            LoadSettings();
        }

        private void Update()
        {
            if (currentGameData != null)
            {
                autoSaveTimer += Time.deltaTime;
                if (autoSaveTimer >= 300f) // 5 минут
                {
                    AutoSave();
                    autoSaveTimer = 0f;
                }
            }
        }

        private void InitializePaths()
        {
            saveFolderPath = Path.Combine(Application.persistentDataPath, SAVE_FOLDER);
            autoSaveFolderPath = Path.Combine(Application.persistentDataPath, AUTO_SAVE_FOLDER);

            if (!Directory.Exists(saveFolderPath))
                Directory.CreateDirectory(saveFolderPath);

            if (!Directory.Exists(autoSaveFolderPath))
                Directory.CreateDirectory(autoSaveFolderPath);
        }

        #region Сохранение игры

        public void SaveGame(int slotIndex)
        {
            if (currentGameData == null)
            {
                Debug.LogError("Нет данных для сохранения!");
                return;
            }

            string fileName = $"save_{slotIndex}.json";
            string filePath = Path.Combine(saveFolderPath, fileName);

            SaveData saveData = new SaveData
            {
                gameData = currentGameData,
                saveTime = DateTime.Now,
                slotIndex = slotIndex
            };

            string json = JsonUtility.ToJson(saveData, true);
            File.WriteAllText(filePath, json);

            Debug.Log($"Игра сохранена в слот {slotIndex}");
            OnGameSaved?.Invoke();
        }

        private void AutoSave()
        {
            if (currentGameData == null) return;

            string fileName = $"autosave_{currentAutoSaveIndex}.json";
            string filePath = Path.Combine(autoSaveFolderPath, fileName);

            SaveData saveData = new SaveData
            {
                gameData = currentGameData,
                saveTime = DateTime.Now,
                slotIndex = -1,
                isAutoSave = true
            };

            string json = JsonUtility.ToJson(saveData, true);
            File.WriteAllText(filePath, json);

            Debug.Log($"Автосохранение {currentAutoSaveIndex}");

            currentAutoSaveIndex = (currentAutoSaveIndex + 1) % 5;
        }

        #endregion

        #region Загрузка игры

        public bool LoadGame(int slotIndex)
        {
            string fileName = $"save_{slotIndex}.json";
            string filePath = Path.Combine(saveFolderPath, fileName);

            if (!File.Exists(filePath))
            {
                Debug.LogWarning($"Сохранение в слоте {slotIndex} не найдено");
                return false;
            }

            try
            {
                string json = File.ReadAllText(filePath);
                SaveData saveData = JsonUtility.FromJson<SaveData>(json);

                currentGameData = saveData.gameData;
                Debug.Log($"Игра загружена из слота {slotIndex}");

                OnGameLoaded?.Invoke();
                return true;
            }
            catch (Exception e)
            {
                Debug.LogError($"Ошибка загрузки: {e.Message}");
                return false;
            }
        }

        public bool LoadAutoSave(int index)
        {
            string fileName = $"autosave_{index}.json";
            string filePath = Path.Combine(autoSaveFolderPath, fileName);

            if (!File.Exists(filePath))
            {
                Debug.LogWarning($"Автосохранение {index} не найдено");
                return false;
            }

            try
            {
                string json = File.ReadAllText(filePath);
                SaveData saveData = JsonUtility.FromJson<SaveData>(json);

                currentGameData = saveData.gameData;
                Debug.Log($"Автосохранение {index} загружено");

                OnGameLoaded?.Invoke();
                return true;
            }
            catch (Exception e)
            {
                Debug.LogError($"Ошибка загрузки: {e.Message}");
                return false;
            }
        }

        #endregion

        #region Информация о сохранениях

        public SaveInfo[] GetSaveSlotsInfo()
        {
            SaveInfo[] infos = new SaveInfo[5];

            for (int i = 0; i < 5; i++)
            {
                string fileName = $"save_{i}.json";
                string filePath = Path.Combine(saveFolderPath, fileName);

                if (File.Exists(filePath))
                {
                    try
                    {
                        string json = File.ReadAllText(filePath);
                        SaveData saveData = JsonUtility.FromJson<SaveData>(json);

                        infos[i] = new SaveInfo
                        {
                            slotIndex = i,
                            saveTime = saveData.saveTime,
                            playerName = saveData.gameData?.playerData?.playerName ?? "Unknown",
                            playerLevel = saveData.gameData?.playerData?.level ?? 1,
                            isAutoSave = false,
                            exists = true
                        };
                    }
                    catch
                    {
                        infos[i] = new SaveInfo { slotIndex = i, exists = false };
                    }
                }
                else
                {
                    infos[i] = new SaveInfo { slotIndex = i, exists = false };
                }
            }

            return infos;
        }

        public SaveInfo[] GetAutoSavesInfo()
        {
            SaveInfo[] infos = new SaveInfo[5];

            for (int i = 0; i < 5; i++)
            {
                string fileName = $"autosave_{i}.json";
                string filePath = Path.Combine(autoSaveFolderPath, fileName);

                if (File.Exists(filePath))
                {
                    try
                    {
                        string json = File.ReadAllText(filePath);
                        SaveData saveData = JsonUtility.FromJson<SaveData>(json);

                        infos[i] = new SaveInfo
                        {
                            slotIndex = i,
                            saveTime = saveData.saveTime,
                            playerName = saveData.gameData?.playerData?.playerName ?? "Unknown",
                            playerLevel = saveData.gameData?.playerData?.level ?? 1,
                            isAutoSave = true,
                            exists = true
                        };
                    }
                    catch
                    {
                        infos[i] = new SaveInfo { slotIndex = i, exists = false };
                    }
                }
                else
                {
                    infos[i] = new SaveInfo { slotIndex = i, exists = false };
                }
            }

            return infos;
        }

        #endregion

        #region Настройки

        public void SaveSettings()
        {
            string filePath = Path.Combine(Application.persistentDataPath, SETTINGS_FILE);
            string json = JsonUtility.ToJson(currentSettings, true);
            File.WriteAllText(filePath, json);
        }

        public void LoadSettings()
        {
            string filePath = Path.Combine(Application.persistentDataPath, SETTINGS_FILE);

            if (File.Exists(filePath))
            {
                try
                {
                    string json = File.ReadAllText(filePath);
                    currentSettings = JsonUtility.FromJson<SettingsData>(json);
                }
                catch
                {
                    currentSettings = new SettingsData();
                }
            }
            else
            {
                currentSettings = new SettingsData();
            }
        }

        public SettingsData GetSettings() => currentSettings ?? new SettingsData();

        public void SetSettings(SettingsData settings)
        {
            currentSettings = settings;
            SaveSettings();
        }

        #endregion

        #region Управление данными

        public void InitializeNewGame(string playerName)
        {
            currentGameData = new GameData();
            currentGameData.playerData.playerName = playerName;
            currentGameData.playerData.money = 10000f;

            autoSaveTimer = 0f;
        }

        public GameData GetCurrentGameData() => currentGameData;

        public void SetGameData(GameData data)
        {
            currentGameData = data;
        }

        #endregion

        #region Удаление сохранений

        public void DeleteSave(int slotIndex)
        {
            string fileName = $"save_{slotIndex}.json";
            string filePath = Path.Combine(saveFolderPath, fileName);

            if (File.Exists(filePath))
            {
                File.Delete(filePath);
                Debug.Log($"Сохранение в слоте {slotIndex} удалено");
            }
        }

        #endregion
    }

    #region Вспомогательные классы

    [Serializable]
    public class SaveData
    {
        public GameData gameData;
        public DateTime saveTime;
        public int slotIndex;
        public bool isAutoSave;
    }

    [Serializable]
    public class SaveInfo
    {
        public int slotIndex;
        public DateTime saveTime;
        public string playerName;
        public int playerLevel;
        public bool isAutoSave;
        public bool exists;
    }

    #endregion
}

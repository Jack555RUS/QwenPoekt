using UnityEngine;
using System;
using System.IO;
using ProbMenu.Core;
using Logger = ProbMenu.Core.Logger;

namespace ProbMenu.Settings
{
    /// <summary>
    /// Менеджер настроек игры
    /// Разрешение, Fullscreen, Звук, Управление
    /// </summary>
    public class SettingsManager : MonoBehaviour
    {
        private static SettingsManager _instance;
        public static SettingsManager Instance
        {
            get
            {
                if (_instance == null)
                {
                    _instance = FindObjectOfType<SettingsManager>();
                    if (_instance == null)
                    {
                        GameObject go = new GameObject("SettingsManager");
                        _instance = go.AddComponent<SettingsManager>();
                        DontDestroyOnLoad(go);
                        Logger.I("SettingsManager created");
                    }
                }
                return _instance;
            }
        }

        // Путь к файлу настроек
        private readonly string SETTINGS_FILE = "/settings.json";

        // Текущие настройки
        private GameSettings settings;
        private int _settingsAppliedCount = 0;

        // Доступные разрешения (от 640x480 до 2K)
        private readonly Resolution[] availableResolutions = new Resolution[]
        {
            CreateResolution(640, 480),
            CreateResolution(800, 600),
            CreateResolution(1024, 768),
            CreateResolution(1280, 720),
            CreateResolution(1366, 768),
            CreateResolution(1600, 900),
            CreateResolution(1920, 1080),
            CreateResolution(2560, 1440), // 2K
        };

        [Serializable]
        public class GameSettings
        {
            public int resolutionIndex;
            public bool fullscreen;
            public int masterVolume;      // 0-100, шаг 10
            public int musicVolume;       // 0-100, шаг 10
            public int sfxVolume;         // 0-100, шаг 10
            public KeyCode keyGas;        // Газ
            public KeyCode keyShiftUp;    // Переключение вверх
            public KeyCode keyShiftDown;  // Переключение вниз
            public KeyCode keyNitro;      // Нитро
            public KeyCode keyPause;      // Пауза

            public GameSettings()
            {
                resolutionIndex = 1; // 800x600 по умолчанию
                fullscreen = false;
                masterVolume = 80;
                musicVolume = 70;
                sfxVolume = 80;
                keyGas = KeyCode.W;
                keyShiftUp = KeyCode.D;
                keyShiftDown = KeyCode.A;
                keyNitro = KeyCode.LeftShift;
                keyPause = KeyCode.Escape;
            }
        }

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

        private void Start()
        {
            LoadSettings();
            ApplySettings();
            Logger.I("=== SETTINGS MANAGER INITIALIZED ===");
            Logger.I($"Resolution: {GetResolutionName(settings.resolutionIndex)}");
            Logger.I($"Fullscreen: {settings.fullscreen}");
            Logger.I($"Volume: {settings.masterVolume}%");
        }

        #region Load/Save

        public void LoadSettings()
        {
            string path = Application.persistentDataPath + SETTINGS_FILE;

            if (File.Exists(path))
            {
                try
                {
                    string json = File.ReadAllText(path);
                    settings = JsonUtility.FromJson<GameSettings>(json);
                    
                    Logger.AssertNotNull(settings, "Deserialized GameSettings");
                    Logger.I("✅ Settings loaded");
                }
                catch (Exception e)
                {
                    Logger.E($"❌ Failed to load settings: {e.Message}");
                    Logger.W("Using default settings");
                    settings = new GameSettings();
                }
            }
            else
            {
                Logger.D("No settings file, using defaults");
                settings = new GameSettings();
            }
        }

        public void SaveSettings()
        {
            string path = Application.persistentDataPath + SETTINGS_FILE;

            try
            {
                Logger.AssertNotNull(settings, "Settings is null!");
                
                string json = JsonUtility.ToJson(settings, true);
                Logger.Assert(!string.IsNullOrEmpty(json), "Settings JSON is empty!");
                
                File.WriteAllText(path, json);
                Logger.I("✅ Settings saved");
            }
            catch (Exception e)
            {
                Logger.E($"❌ Failed to save settings: {e.Message}");
            }
        }

        #endregion

        #region Apply Settings

        public void ApplySettings()
        {
            ApplyResolution();
            ApplyVolume();
            Logger.I("⚙️ Settings applied");
        }

        public void ApplyResolution()
        {
            if (settings.resolutionIndex < 0 || settings.resolutionIndex >= availableResolutions.Length)
                settings.resolutionIndex = 1;

            Resolution res = availableResolutions[settings.resolutionIndex];

            Screen.SetResolution(res.width, res.height, settings.fullscreen);
            Logger.I($"🖥️ Resolution: {res.width}x{res.height}, Fullscreen: {settings.fullscreen}");
        }

        public void ApplyVolume()
        {
            AudioListener.volume = settings.masterVolume / 100f;
            Logger.I($"🔊 Volume: {settings.masterVolume}%");
        }

        #endregion

        #region Getters

        public Resolution[] GetAvailableResolutions()
        {
            return availableResolutions;
        }

        public string GetResolutionName(int index)
        {
            if (index < 0 || index >= availableResolutions.Length)
                return "Unknown";

            Resolution res = availableResolutions[index];
            return $"{res.width}x{res.height}";
        }

        public int GetCurrentResolutionIndex() => settings.resolutionIndex;
        public bool IsFullscreen() => settings.fullscreen;
        public int GetMasterVolume() => settings.masterVolume;
        public int GetMusicVolume() => settings.musicVolume;
        public int GetSFXVolume() => settings.sfxVolume;

        public KeyCode GetKeyGas() => settings.keyGas;
        public KeyCode GetKeyShiftUp() => settings.keyShiftUp;
        public KeyCode GetKeyShiftDown() => settings.keyShiftDown;
        public KeyCode GetKeyNitro() => settings.keyNitro;
        public KeyCode GetKeyPause() => settings.keyPause;

        public string GetKeyName(KeyCode key)
        {
            return key.ToString();
        }

        #endregion

        #region Setters

        public void SetResolutionIndex(int index)
        {
            if (index >= 0 && index < availableResolutions.Length)
            {
                settings.resolutionIndex = index;
                ApplyResolution();
            }
        }

        public void SetFullscreen(bool fullscreen)
        {
            settings.fullscreen = fullscreen;
            ApplyResolution();
        }

        public void SetMasterVolume(int volume)
        {
            settings.masterVolume = Mathf.Clamp(volume, 0, 100);
            ApplyVolume();
        }

        public void SetMusicVolume(int volume)
        {
            settings.musicVolume = Mathf.Clamp(volume, 0, 100);
        }

        public void SetSFXVolume(int volume)
        {
            settings.sfxVolume = Mathf.Clamp(volume, 0, 100);
        }

        public void SetKeyGas(KeyCode key) => settings.keyGas = key;
        public void SetKeyShiftUp(KeyCode key) => settings.keyShiftUp = key;
        public void SetKeyShiftDown(KeyCode key) => settings.keyShiftDown = key;
        public void SetKeyNitro(KeyCode key) => settings.keyNitro = key;
        public void SetKeyPause(KeyCode key) => settings.keyPause = key;

        #endregion

        #region Helpers

        private static Resolution CreateResolution(int width, int height)
        {
            return new Resolution
            {
                width = width,
                height = height
            };
        }

        /// <summary>
        /// Проверка на дублирование клавиш
        /// </summary>
        public bool IsKeyDuplicated(KeyCode newKey, KeyCode excludeKey = KeyCode.None)
        {
            KeyCode[] allKeys = new KeyCode[]
            {
                settings.keyGas,
                settings.keyShiftUp,
                settings.keyShiftDown,
                settings.keyNitro,
                settings.keyPause
            };

            int count = 0;
            foreach (KeyCode key in allKeys)
            {
                if (key == newKey)
                    count++;
            }

            // Если клавиша уже используется (более 1 раза или не исключена)
            return count > 1 || (count == 1 && newKey != excludeKey);
        }

        /// <summary>
        /// Сбросить настройки к умолчанию
        /// </summary>
        public void ResetToDefaults()
        {
            settings = new GameSettings();
            ApplySettings();
            SaveSettings();
            Logger.I("🔄 Settings reset to defaults");
        }

        #endregion

        #region Quick Actions

        public void ToggleFullscreen()
        {
            settings.fullscreen = !settings.fullscreen;
            ApplyResolution();
        }

        public void IncreaseVolume(int step = 10)
        {
            SetMasterVolume(settings.masterVolume + step);
        }

        public void DecreaseVolume(int step = 10)
        {
            SetMasterVolume(settings.masterVolume - step);
        }

        #endregion
    }
}

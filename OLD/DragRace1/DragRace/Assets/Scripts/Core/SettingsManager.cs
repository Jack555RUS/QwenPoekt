using UnityEngine;

namespace DragRace.Core
{
    /// <summary>
    /// Менеджер настроек игры
    /// </summary>
    public static class SettingsManager
    {
        private static PlayerSettings _currentSettings;
        public static PlayerSettings CurrentSettings => _currentSettings;

        private static readonly string SETTINGS_FILE = "settings.json";
        private static readonly string SETTINGS_PATH = System.IO.Path.Combine(
            Application.persistentDataPath, 
            SETTINGS_FILE
        );

        /// <summary>
        /// Загрузка настроек
        /// </summary>
        public static void LoadSettings()
        {
            if (System.IO.File.Exists(SETTINGS_PATH))
            {
                string json = System.IO.File.ReadAllText(SETTINGS_PATH);
                _currentSettings = JsonUtility.FromJson<PlayerSettings>(json);
                Debug.Log("✅ Настройки загружены");
            }
            else
            {
                _currentSettings = new PlayerSettings();
                Debug.Log("📝 Созданы новые настройки");
            }

            ApplySettings();
        }

        /// <summary>
        /// Сохранение настроек
        /// </summary>
        public static void SaveSettings()
        {
            string json = JsonUtility.ToJson(_currentSettings, true);
            System.IO.File.WriteAllText(SETTINGS_PATH, json);
            Debug.Log("💾 Настройки сохранены");
        }

        /// <summary>
        /// Применение настроек
        /// </summary>
        public static void ApplySettings()
        {
            // Разрешение
            Resolution[] resolutions = Screen.resolutions;
            if (_currentSettings.resolutionIndex < resolutions.Length)
            {
                Resolution res = resolutions[_currentSettings.resolutionIndex];
                Screen.SetResolution(res.width, res.height, _currentSettings.fullscreen);
            }

            // Громкость
            AudioListener.volume = _currentSettings.masterVolume / 100f;

            Debug.Log("⚙️ Настройки применены");
        }

        /// <summary>
        /// Установить разрешение
        /// </summary>
        public static void SetResolution(int index)
        {
            _currentSettings.resolutionIndex = index;
            ApplySettings();
        }

        /// <summary>
        /// Установить полноэкранный режим
        /// </summary>
        public static void SetFullscreen(bool fullscreen)
        {
            _currentSettings.fullscreen = fullscreen;
            ApplySettings();
        }

        /// <summary>
        /// Установить громкость
        /// </summary>
        public static void SetMasterVolume(int volume)
        {
            _currentSettings.masterVolume = Mathf.Clamp(volume, 0, 100);
            AudioListener.volume = _currentSettings.masterVolume / 100f;
        }

        /// <summary>
        /// Получить доступные разрешения
        /// </summary>
        public static Resolution[] GetAvailableResolutions()
        {
            return Screen.resolutions;
        }

        /// <summary>
        /// Проверка клавиши на дубликат
        /// </summary>
        public static bool IsKeyDuplicate(string newKey, string excludeAction = "")
        {
            foreach (var binding in _currentSettings.keyBindings)
            {
                if (binding.Key != excludeAction && binding.Value == newKey)
                {
                    return true;
                }
            }
            return false;
        }

        /// <summary>
        /// Переназначить клавишу
        /// </summary>
        public static bool RebindKey(string action, string newKey)
        {
            if (IsKeyDuplicate(newKey, action))
            {
                Debug.LogWarning($"⚠️ Клавиша {newKey} уже используется!");
                return false;
            }

            _currentSettings.keyBindings[action] = newKey;
            SaveSettings();
            Debug.Log($"✅ {action} переназначена на {newKey}");
            return true;
        }
    }
}

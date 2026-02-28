using UnityEngine;
using UnityEngine.UI;
using System.Collections.Generic;

namespace DragRace.UI
{
    /// <summary>
    /// UI Настроек игры
    /// Разрешение, громкость, управление
    /// </summary>
    public class SettingsUI : MonoBehaviour
    {
        [Header("Панели")]
        [Tooltip("Основная панель настроек")]
        public GameObject settingsPanel;
        
        [Tooltip("Видео настройки")]
        public GameObject videoPanel;
        
        [Tooltip("Аудио настройки")]
        public GameObject audioPanel;
        
        [Tooltip("Настройки управления")]
        public GameObject controlsPanel;
        
        [Header("Видео")]
        [Tooltip("Dropdown разрешений")]
        public Dropdown resolutionDropdown;
        
        [Tooltip("Toggle полноэкранного режима")]
        public Toggle fullscreenToggle;
        
        [Tooltip("Качество графики")]
        public Dropdown qualityDropdown;
        
        [Header("Аудио")]
        [Tooltip("Слайдер общей громкости")]
        public Slider masterVolumeSlider;
        
        [Tooltip("Слайдер музыки")]
        public Slider musicVolumeSlider;
        
        [Tooltip("Слайдер эффектов")]
        public Slider sfxVolumeSlider;
        
        [Tooltip("Слайдер двигателя")]
        public Slider engineVolumeSlider;
        
        [Header("Управление")]
        [Tooltip("Список кнопок действий")]
        public Button[] actionButtons;
        
        [Tooltip("Тексты названий действий")]
        public Text[] actionNames;
        
        [Tooltip("Тексты клавиш")]
        public Text[] actionKeys;
        
        [Header("Кнопки")]
        [Tooltip("Кнопка применить")]
        public Button applyButton;
        
        [Tooltip("Кнопка сбросить")]
        public Button resetButton;
        
        [Tooltip("Кнопка назад")]
        public Button backButton;
        
        [Header("Диалог подтверждения")]
        [Tooltip("Объект диалога")]
        public GameObject confirmDialog;
        
        [Tooltip("Текст диалога")]
        public Text confirmText;
        
        [Tooltip("Кнопка подтверждения")]
        public Button confirmYesButton;
        
        [Tooltip("Кнопка отмены")]
        public Button confirmNoButton;
        
        // Состояние
        private Resolution[] resolutions;
        private int selectedResolutionIndex;
        private bool hasChanges = false;
        private bool waitingForKeybind = false;
        private int selectedActionIndex = -1;
        
        private Dictionary<string, KeyCode> keyBindings = new Dictionary<string, KeyCode>();
        
        private void Awake()
        {
            InitializeSettings();
        }
        
        private void InitializeSettings()
        {
            Debug.Log("⚙️ SettingsUI инициализирован");
            
            // Загрузка текущих настроек
            Core.SettingsManager.LoadSettings();
            var settings = Core.SettingsManager.CurrentSettings;
            
            // Инициализация видео
            InitializeVideo(settings);
            
            // Инициализация аудио
            InitializeAudio(settings);
            
            // Инициализация управления
            InitializeControls(settings);
            
            // Подписка на кнопки
            applyButton?.onClick.AddListener(OnApplyClicked);
            resetButton?.onClick.AddListener(OnResetClicked);
            backButton?.onClick.AddListener(OnBackClicked);
            confirmYesButton?.onClick.AddListener(OnConfirmYes);
            confirmNoButton?.onClick.AddListener(OnConfirmNo);
            
            confirmDialog?.SetActive(false);
        }
        
        #region Video Settings
        
        private void InitializeVideo(Core.PlayerSettings settings)
        {
            // Получение доступных разрешений
            resolutions = Screen.resolutions;
            resolutionDropdown?.ClearOptions();
            
            List<string> options = new List<string>();
            selectedResolutionIndex = 0;
            
            for (int i = 0; i < resolutions.Length; i++)
            {
                options.Add($"{resolutions[i].width} x {resolutions[i].height} @ {resolutions[i].refreshRateRatio.numerator / resolutions[i].refreshRateRatio.denominator:0}Hz");
                
                if (resolutions[i].width == Screen.currentResolution.width &&
                    resolutions[i].height == Screen.currentResolution.height)
                {
                    selectedResolutionIndex = i;
                }
            }
            
            resolutionDropdown?.AddOptions(options);
            resolutionDropdown.value = selectedResolutionIndex;
            
            // Полноэкранный режим
            fullscreenToggle.isOn = settings.fullscreen;
            
            // Качество
            qualityDropdown.value = QualitySettings.GetQualityLevel();
            
            // События
            resolutionDropdown?.onValueChanged.AddListener(_ => hasChanges = true);
            fullscreenToggle?.onValueChanged.AddListener(_ => hasChanges = true);
            qualityDropdown?.onValueChanged.AddListener(_ => hasChanges = true);
        }
        
        #endregion
        
        #region Audio Settings
        
        private void InitializeAudio(Core.PlayerSettings settings)
        {
            masterVolumeSlider.value = settings.masterVolume;
            musicVolumeSlider.value = settings.musicVolume;
            engineVolumeSlider.value = settings.engineVolume;
            
            // События
            masterVolumeSlider?.onValueChanged.AddListener(v => {
                Core.SettingsManager.SetMasterVolume((int)v);
                hasChanges = true;
            });
            
            musicVolumeSlider?.onValueChanged.AddListener(_ => hasChanges = true);
            sfxVolumeSlider?.onValueChanged.AddListener(_ => hasChanges = true);
            engineVolumeSlider?.onValueChanged.AddListener(_ => hasChanges = true);
        }
        
        #endregion
        
        #region Control Settings
        
        private void InitializeControls(Core.PlayerSettings settings)
        {
            keyBindings.Clear();
            
            string[] actions = { "Accelerate", "ShiftUp", "ShiftDown", "Nitro", "Pause" };
            string[] displayNames = { "Газ", "Переключение вверх", "Переключение вниз", "Нитро", "Пауза" };
            
            for (int i = 0; i < actions.Length && i < actionButtons.Length; i++)
            {
                string action = actions[i];
                KeyCode key = KeyCode.W;
                
                if (settings.keyBindings.ContainsKey(action))
                {
                    key = (KeyCode)System.Enum.Parse(typeof(KeyCode), settings.keyBindings[action]);
                }
                
                keyBindings[action] = key;
                
                if (i < actionNames.Length)
                    actionNames[i].text = displayNames[i];
                
                if (i < actionKeys.Length)
                    actionKeys[i].text = key.ToString();
                
                int index = i;
                if (actionButtons[i] != null)
                {
                    actionButtons[i].onClick.AddListener(() => OnKeybindButtonClicked(index, action));
                }
            }
        }
        
        private void OnKeybindButtonClicked(int index, string action)
        {
            selectedActionIndex = index;
            waitingForKeybind = true;
            
            if (confirmDialog != null && confirmText != null)
            {
                confirmText.text = $"Нажмите новую клавишу для \"{actionNames[index].text}\"";
                confirmDialog.SetActive(true);
            }
        }
        
        private void Update()
        {
            if (waitingForKeybind && Input.anyKeyDown)
            {
                KeyCode newKey = Input.GetKey(KeyCode.None) ? KeyCode.None : GetAnyKeyDown();
                
                if (newKey != KeyCode.None && selectedActionIndex >= 0 && selectedActionIndex < actionKeys.Length)
                {
                    // Проверка на дубликат
                    if (Core.SettingsManager.IsKeyDuplicate(newKey.ToString(), GetActionName(selectedActionIndex)))
                    {
                        Debug.LogWarning($"⚠️ Клавиша {newKey} уже используется!");
                    }
                    else
                    {
                        string action = GetActionName(selectedActionIndex);
                        keyBindings[action] = newKey;
                        actionKeys[selectedActionIndex].text = newKey.ToString();
                        hasChanges = true;
                        
                        Debug.Log($"✅ {action} переназначена на {newKey}");
                    }
                }
                
                waitingForKeybind = false;
                confirmDialog?.SetActive(false);
            }
        }
        
        private KeyCode GetAnyKeyDown()
        {
            KeyCode[] keys = (KeyCode[])System.Enum.GetValues(typeof(KeyCode));
            foreach (KeyCode key in keys)
            {
                if (Input.GetKeyDown(key) && key != KeyCode.Escape)
                {
                    return key;
                }
            }
            return KeyCode.None;
        }
        
        private string GetActionName(int index)
        {
            string[] actions = { "Accelerate", "ShiftUp", "ShiftDown", "Nitro", "Pause" };
            return index >= 0 && index < actions.Length ? actions[index] : "";
        }
        
        #endregion
        
        #region Button Handlers
        
        private void OnApplyClicked()
        {
            if (!hasChanges) return;
            
            // Применение видео настроек
            ApplyVideoSettings();
            
            // Применение настроек управления
            ApplyControlSettings();
            
            // Сохранение
            Core.SettingsManager.SaveSettings();
            
            Debug.Log("✅ Настройки применены и сохранены");
            
            hasChanges = false;
        }
        
        private void OnResetClicked()
        {
            if (confirmDialog != null && confirmText != null)
            {
                confirmText.text = "Сбросить все настройки к значениям по умолчанию?";
                confirmDialog.SetActive(true);
            }
        }
        
        private void OnBackClicked()
        {
            if (hasChanges)
            {
                if (confirmDialog != null && confirmText != null)
                {
                    confirmText.text = "Есть несохранённые изменения. Выйти без сохранения?";
                    confirmDialog.SetActive(true);
                }
            }
            else
            {
                gameObject.SetActive(false);
            }
        }
        
        private void OnConfirmYes()
        {
            confirmDialog?.SetActive(false);
            
            if (confirmText != null)
            {
                if (confirmText.text.Contains("Сбросить"))
                {
                    ResetToDefaults();
                }
                else if (confirmText.text.Contains("Выйти"))
                {
                    gameObject.SetActive(false);
                }
                else
                {
                    // Подтверждение переназначения клавиши
                    waitingForKeybind = true;
                }
            }
        }
        
        private void OnConfirmNo()
        {
            confirmDialog?.SetActive(false);
            waitingForKeybind = false;
        }
        
        #endregion
        
        #region Helpers
        
        private void ApplyVideoSettings()
        {
            if (resolutionDropdown != null && selectedResolutionIndex < resolutions.Length)
            {
                Resolution res = resolutions[selectedResolutionIndex];
                Screen.SetResolution(res.width, res.height, fullscreenToggle.isOn);
            }
            
            if (qualityDropdown != null)
            {
                QualitySettings.SetQualityLevel(qualityDropdown.value);
            }
            
            Core.SettingsManager.SetFullscreen(fullscreenToggle.isOn);
        }
        
        private void ApplyControlSettings()
        {
            var settings = Core.SettingsManager.CurrentSettings;
            settings.keyBindings.Clear();
            
            foreach (var kvp in keyBindings)
            {
                settings.keyBindings[kvp.Key] = kvp.Value.ToString();
            }
        }
        
        private void ResetToDefaults()
        {
            // Сброс к значениям по умолчанию
            var settings = new Core.PlayerSettings();
            
            // Видео
            selectedResolutionIndex = 0;
            resolutionDropdown.value = 0;
            fullscreenToggle.isOn = true;
            qualityDropdown.value = 2; // Medium

            // Аудио
            masterVolumeSlider.value = 80;
            musicVolumeSlider.value = 70;
            engineVolumeSlider.value = 100;
            
            // Управление
            InitializeControls(settings);
            
            hasChanges = true;
            
            Debug.Log("🔄 Настройки сброшены к значениям по умолчанию");
        }
        
        #endregion
        
        #region Public Methods
        
        /// <summary>
        /// Показать настройки
        /// </summary>
        public void ShowSettings()
        {
            gameObject.SetActive(true);
            settingsPanel.SetActive(true);
            videoPanel.SetActive(true);
            audioPanel.SetActive(false);
            controlsPanel.SetActive(false);
        }
        
        /// <summary>
        /// Показать видео настройки
        /// </summary>
        public void ShowVideoSettings()
        {
            settingsPanel.SetActive(false);
            videoPanel.SetActive(true);
            audioPanel.SetActive(false);
            controlsPanel.SetActive(false);
        }
        
        /// <summary>
        /// Показать аудио настройки
        /// </summary>
        public void ShowAudioSettings()
        {
            settingsPanel.SetActive(false);
            videoPanel.SetActive(false);
            audioPanel.SetActive(true);
            controlsPanel.SetActive(false);
        }
        
        /// <summary>
        /// Показать настройки управления
        /// </summary>
        public void ShowControlSettings()
        {
            settingsPanel.SetActive(false);
            videoPanel.SetActive(false);
            audioPanel.SetActive(false);
            controlsPanel.SetActive(true);
        }
        
        #endregion
    }
}

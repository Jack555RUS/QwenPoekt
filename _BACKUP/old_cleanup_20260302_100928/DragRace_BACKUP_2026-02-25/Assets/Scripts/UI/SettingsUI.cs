using UnityEngine;
using UnityEngine.UI;
using DragRace.Core;
using DragRace.Data;

namespace DragRace.UI
{
    /// <summary>
    /// Настройки игры
    /// </summary>
    public class SettingsUI : MonoBehaviour
    {
        [Header("Видео")]
        public Dropdown resolutionDropdown;
        public Toggle fullscreenToggle;
        public Button applyVideoButton;
        
        [Header("Звук")]
        public Slider masterVolumeSlider;
        public Slider musicVolumeSlider;
        public Slider sfxVolumeSlider;
        public Text masterVolumeText;
        public Text musicVolumeText;
        public Text sfxVolumeText;
        
        [Header("Управление")]
        public Button keyBindingsButton;
        public GameObject keyBindingsPanel;
        
        [Header("Подтверждение")]
        public GameObject confirmDialog;
        
        private SettingsData currentSettings;
        private SettingsData pendingSettings;
        private bool hasChanges;
        
        private void Awake()
        {
            InitializeSettings();
            SubscribeToEvents();
        }
        
        private void Start()
        {
            UpdateUI();
        }
        
        private void OnDestroy()
        {
            UnsubscribeFromEvents();
        }
        
        private void InitializeSettings()
        {
            currentSettings = GameManager.Instance.Settings;
            pendingSettings = new SettingsData
            {
                screenWidth = currentSettings.screenWidth,
                screenHeight = currentSettings.screenHeight,
                fullscreen = currentSettings.fullscreen,
                masterVolume = currentSettings.masterVolume,
                musicVolume = currentSettings.musicVolume,
                sfxVolume = currentSettings.sfxVolume,
                keyBindings = currentSettings.keyBindings
            };
            
            hasChanges = false;
        }
        
        #region Инициализация UI
        
        private void UpdateUI()
        {
            UpdateResolutionDropdown();
            UpdateVideoSettings();
            UpdateAudioSettings();
        }
        
        private void UpdateResolutionDropdown()
        {
            if (resolutionDropdown == null) return;
            
            resolutionDropdown.ClearOptions();
            
            var resolutions = GameConfig.Instance?.supportedResolutions;
            if (resolutions == null || resolutions.Length == 0) return;
            
            var options = new System.Collections.Generic.List<string>();
            int currentIndex = 0;
            
            for (int i = 0; i < resolutions.Length; i++)
            {
                options.Add($"{resolutions[i].width}x{resolutions[i].height}");
                
                if (resolutions[i].width == pendingSettings.screenWidth &&
                    resolutions[i].height == pendingSettings.screenHeight)
                {
                    currentIndex = i;
                }
            }
            
            resolutionDropdown.AddOptions(options);
            resolutionDropdown.value = currentIndex;
        }
        
        private void UpdateVideoSettings()
        {
            if (fullscreenToggle != null)
                fullscreenToggle.isOn = pendingSettings.fullscreen;
        }
        
        private void UpdateAudioSettings()
        {
            if (masterVolumeSlider != null)
            {
                masterVolumeSlider.value = pendingSettings.masterVolume;
                masterVolumeText.text = $"{pendingSettings.masterVolume}%";
            }
            
            if (musicVolumeSlider != null)
            {
                musicVolumeSlider.value = pendingSettings.musicVolume;
                musicVolumeText.text = $"{pendingSettings.musicVolume}%";
            }
            
            if (sfxVolumeSlider != null)
            {
                sfxVolumeSlider.value = pendingSettings.sfxVolume;
                sfxVolumeText.text = $"{pendingSettings.sfxVolume}%";
            }
        }
        
        #endregion
        
        #region Подписка на события
        
        private void SubscribeToEvents()
        {
            if (resolutionDropdown != null)
                resolutionDropdown.onValueChanged.AddListener(OnResolutionChanged);
            
            if (fullscreenToggle != null)
                fullscreenToggle.onValueChanged.AddListener(OnFullscreenChanged);
            
            if (applyVideoButton != null)
                applyVideoButton.onClick.AddListener(OnApplyVideoSettings);
            
            if (masterVolumeSlider != null)
                masterVolumeSlider.onValueChanged.AddListener(OnMasterVolumeChanged);
            
            if (musicVolumeSlider != null)
                musicVolumeSlider.onValueChanged.AddListener(OnMusicVolumeChanged);
            
            if (sfxVolumeSlider != null)
                sfxVolumeSlider.onValueChanged.AddListener(OnSfxVolumeChanged);
            
            if (keyBindingsButton != null)
                keyBindingsButton.onClick.AddListener(OnKeyBindingsClicked);
        }
        
        private void UnsubscribeFromEvents()
        {
            if (resolutionDropdown != null)
                resolutionDropdown.onValueChanged.RemoveListener(OnResolutionChanged);
            
            if (fullscreenToggle != null)
                fullscreenToggle.onValueChanged.RemoveListener(OnFullscreenChanged);
            
            if (applyVideoButton != null)
                applyVideoButton.onClick.RemoveListener(OnApplyVideoSettings);
            
            if (masterVolumeSlider != null)
                masterVolumeSlider.onValueChanged.RemoveListener(OnMasterVolumeChanged);
            
            if (musicVolumeSlider != null)
                musicVolumeSlider.onValueChanged.RemoveListener(OnMusicVolumeChanged);
            
            if (sfxVolumeSlider != null)
                sfxVolumeSlider.onValueChanged.RemoveListener(OnSfxVolumeChanged);
            
            if (keyBindingsButton != null)
                keyBindingsButton.onClick.RemoveListener(OnKeyBindingsClicked);
        }
        
        #endregion
        
        #region Обработчики
        
        private void OnResolutionChanged(int index)
        {
            var resolutions = GameConfig.Instance?.supportedResolutions;
            if (resolutions == null || index >= resolutions.Length) return;
            
            pendingSettings.screenWidth = resolutions[index].width;
            pendingSettings.screenHeight = resolutions[index].height;
            hasChanges = true;
        }
        
        private void OnFullscreenChanged(bool isFullscreen)
        {
            pendingSettings.fullscreen = isFullscreen;
            hasChanges = true;
        }
        
        private void OnApplyVideoSettings()
        {
            if (!hasChanges) return;
            
            ShowConfirmDialog("Применить настройки видео?", () =>
            {
                currentSettings.screenWidth = pendingSettings.screenWidth;
                currentSettings.screenHeight = pendingSettings.screenHeight;
                currentSettings.fullscreen = pendingSettings.fullscreen;
                
                GameManager.Instance.UpdateSettings(currentSettings);
                hasChanges = false;
            });
        }
        
        private void OnMasterVolumeChanged(float value)
        {
            pendingSettings.masterVolume = Mathf.RoundToInt(value / 10) * 10; // Шаг 10
            masterVolumeText.text = $"{pendingSettings.masterVolume}%";
            hasChanges = true;
            
            AudioListener.volume = pendingSettings.masterVolume / 100f;
        }
        
        private void OnMusicVolumeChanged(float value)
        {
            pendingSettings.musicVolume = Mathf.RoundToInt(value / 10) * 10;
            musicVolumeText.text = $"{pendingSettings.musicVolume}%";
            hasChanges = true;
        }
        
        private void OnSfxVolumeChanged(float value)
        {
            pendingSettings.sfxVolume = Mathf.RoundToInt(value / 10) * 10;
            sfxVolumeText.text = $"{pendingSettings.sfxVolume}%";
            hasChanges = true;
        }
        
        private void OnKeyBindingsClicked()
        {
            if (keyBindingsPanel != null)
                keyBindingsPanel.SetActive(true);
        }
        
        #endregion
        
        #region Подтверждение
        
        private void ShowConfirmDialog(string message, System.Action onConfirm)
        {
            if (confirmDialog != null)
            {
                confirmDialog.SetActive(true);
                // TODO: Настроить текст и кнопки
            }
            else
            {
                onConfirm?.Invoke();
            }
        }
        
        public void ConfirmChanges()
        {
            // Вызывается кнопкой подтверждения
        }
        
        public void CancelChanges()
        {
            if (confirmDialog != null)
                confirmDialog.SetActive(false);
        }
        
        #endregion
        
        #region Сохранение
        
        public void SaveAndExit()
        {
            if (hasChanges)
            {
                currentSettings.masterVolume = pendingSettings.masterVolume;
                currentSettings.musicVolume = pendingSettings.musicVolume;
                currentSettings.sfxVolume = pendingSettings.sfxVolume;
                
                GameManager.Instance.UpdateSettings(currentSettings);
            }
            
            gameObject.SetActive(false);
        }
        
        #endregion
        
        #region ESC
        
        private void Update()
        {
            if (Input.GetKeyDown(KeyCode.Escape))
            {
                if (keyBindingsPanel != null && keyBindingsPanel.activeSelf)
                {
                    keyBindingsPanel.SetActive(false);
                }
                else
                {
                    SaveAndExit();
                }
            }
        }
        
        #endregion
    }
}

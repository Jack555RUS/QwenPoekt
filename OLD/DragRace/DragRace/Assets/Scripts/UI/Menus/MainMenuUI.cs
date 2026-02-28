using UnityEngine;
using UnityEngine.UI;
using DragRace.Core;
using DragRace.SaveSystem;

namespace DragRace.UI.Menus
{
    /// <summary>
    /// Главное меню
    /// </summary>
    public class MainMenuUI : MonoBehaviour
    {
        [Header("Панели")]
        public GameObject mainPanel;
        public GameObject newGamePanel;
        public GameObject loadGamePanel;
        public GameObject settingsPanel;
        public GameObject saveGamePanel;
        
        [Header("Кнопки главного меню")]
        public Button newGameButton;
        public Button continueButton;
        public Button saveButton;
        public Button loadButton;
        public Button settingsButton;
        public Button exitButton;
        
        [Header("Новая игра")]
        public InputField playerNameInput;
        public Button confirmNewGameButton;
        public Button cancelNewGameButton;
        
        [Header("Навигация")]
        private GameObject currentPanel;
        
        private void Awake()
        {
            SubscribeToEvents();
        }
        
        private void Start()
        {
            ShowPanel(mainPanel);
            UpdateContinueButton();
        }
        
        private void OnDestroy()
        {
            UnsubscribeFromEvents();
        }
        
        private void SubscribeToEvents()
        {
            if (newGameButton != null)
                newGameButton.onClick.AddListener(OnNewGameClicked);
            
            if (continueButton != null)
                continueButton.onClick.AddListener(OnContinueClicked);
            
            if (saveButton != null)
                saveButton.onClick.AddListener(OnSaveClicked);
            
            if (loadButton != null)
                loadButton.onClick.AddListener(OnLoadClicked);
            
            if (settingsButton != null)
                settingsButton.onClick.AddListener(OnSettingsClicked);
            
            if (exitButton != null)
                exitButton.onClick.AddListener(OnExitClicked);
            
            if (confirmNewGameButton != null)
                confirmNewGameButton.onClick.AddListener(OnConfirmNewGame);
            
            if (cancelNewGameButton != null)
                cancelNewGameButton.onClick.AddListener(OnCancelNewGame);
        }
        
        private void UnsubscribeFromEvents()
        {
            if (newGameButton != null)
                newGameButton.onClick.RemoveListener(OnNewGameClicked);
            
            if (continueButton != null)
                continueButton.onClick.RemoveListener(OnContinueClicked);
            
            if (saveButton != null)
                saveButton.onClick.RemoveListener(OnSaveClicked);
            
            if (loadButton != null)
                loadButton.onClick.RemoveListener(OnLoadClicked);
            
            if (settingsButton != null)
                settingsButton.onClick.RemoveListener(OnSettingsClicked);
            
            if (exitButton != null)
                exitButton.onClick.RemoveListener(OnExitClicked);
            
            if (confirmNewGameButton != null)
                confirmNewGameButton.onClick.RemoveListener(OnConfirmNewGame);
            
            if (cancelNewGameButton != null)
                cancelNewGameButton.onClick.RemoveListener(OnCancelNewGame);
        }
        
        #region Обработчики кнопок
        
        private void OnNewGameClicked()
        {
            ShowPanel(newGamePanel);
            if (playerNameInput != null)
                playerNameInput.text = "";
        }
        
        private void OnContinueClicked()
        {
            // Загрузка последнего автосохранения
            var autoSaves = GameManager.Instance.GetAutoSaves();
            for (int i = autoSaves.Length - 1; i >= 0; i--)
            {
                if (autoSaves[i].exists)
                {
                    GameManager.Instance.LoadGame(autoSaves[i].slotIndex);
                    GameManager.Instance.ChangeState(GameState.GameMenu);
                    return;
                }
            }
        }
        
        private void OnSaveClicked()
        {
            ShowPanel(saveGamePanel);
        }
        
        private void OnLoadClicked()
        {
            ShowPanel(loadGamePanel);
            // TODO: Обновить список сохранений
        }
        
        private void OnSettingsClicked()
        {
            ShowPanel(settingsPanel);
        }
        
        private void OnExitClicked()
        {
            #if UNITY_EDITOR
                UnityEditor.EditorApplication.isPlaying = false;
            #else
                Application.Quit();
            #endif
        }
        
        private void OnConfirmNewGame()
        {
            if (playerNameInput == null || string.IsNullOrWhiteSpace(playerNameInput.text))
            {
                Debug.LogWarning("Введите имя персонажа!");
                return;
            }
            
            GameManager.Instance.StartNewGame(playerNameInput.text);
        }
        
        private void OnCancelNewGame()
        {
            ShowPanel(mainPanel);
        }
        
        #endregion
        
        #region Навигация
        
        private void ShowPanel(GameObject panel)
        {
            if (currentPanel != null)
                currentPanel.SetActive(false);
            
            currentPanel = panel;
            
            if (panel != null)
                panel.SetActive(true);
        }
        
        private void UpdateContinueButton()
        {
            if (continueButton != null)
            {
                var autoSaves = GameManager.Instance.GetAutoSaves();
                bool hasSave = false;
                
                foreach (var save in autoSaves)
                {
                    if (save.exists)
                    {
                        hasSave = true;
                        break;
                    }
                }
                
                continueButton.interactable = hasSave;
            }
        }
        
        #endregion
        
        #region ESC
        
        private void Update()
        {
            if (Input.GetKeyDown(KeyCode.Escape))
            {
                if (currentPanel != mainPanel && currentPanel != null)
                {
                    ShowPanel(mainPanel);
                }
            }
        }
        
        #endregion
    }
}

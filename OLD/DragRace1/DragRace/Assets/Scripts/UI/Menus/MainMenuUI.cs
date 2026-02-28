using UnityEngine;
using UnityEngine.UI;
using DragRace.Core;

namespace DragRace.UI.Menus
{
    /// <summary>
    /// Главное меню
    /// </summary>
    public class MainMenuUI : MonoBehaviour
    {
        [Header("Панели")]
        [SerializeField] private GameObject mainPanel;
        [SerializeField] private GameObject newGamePanel;
        [SerializeField] private GameObject loadGamePanel;
        [SerializeField] private GameObject settingsPanel;
        [SerializeField] private GameObject saveGamePanel;

        [Header("Кнопки главного меню")]
        [SerializeField] private Button newGameButton;
        [SerializeField] private Button continueButton;
        [SerializeField] private Button saveButton;
        [SerializeField] private Button loadButton;
        [SerializeField] private Button settingsButton;
        [SerializeField] private Button exitButton;

        [Header("Новая игра")]
        [SerializeField] private InputField playerNameInput;
        [SerializeField] private Button confirmNewGameButton;
        [SerializeField] private Button cancelNewGameButton;

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
            newGameButton?.onClick.AddListener(OnNewGameClicked);
            continueButton?.onClick.AddListener(OnContinueClicked);
            saveButton?.onClick.AddListener(OnSaveClicked);
            loadButton?.onClick.AddListener(OnLoadClicked);
            settingsButton?.onClick.AddListener(OnSettingsClicked);
            exitButton?.onClick.AddListener(OnExitClicked);
            confirmNewGameButton?.onClick.AddListener(OnConfirmNewGame);
            cancelNewGameButton?.onClick.AddListener(OnCancelNewGame);
        }

        private void UnsubscribeFromEvents()
        {
            newGameButton?.onClick.RemoveListener(OnNewGameClicked);
            continueButton?.onClick.RemoveListener(OnContinueClicked);
            saveButton?.onClick.RemoveListener(OnSaveClicked);
            loadButton?.onClick.RemoveListener(OnLoadClicked);
            settingsButton?.onClick.RemoveListener(OnSettingsClicked);
            exitButton?.onClick.RemoveListener(OnExitClicked);
            confirmNewGameButton?.onClick.RemoveListener(OnConfirmNewGame);
            cancelNewGameButton?.onClick.RemoveListener(OnCancelNewGame);
        }

        #region Обработчики кнопок

        private void OnNewGameClicked()
        {
            ShowPanel(newGamePanel);
            playerNameInput?.SetTextWithoutNotify("");
        }

        private void OnContinueClicked()
        {
            // Загрузка последнего автосохранения
            for (int i = SaveManager.AUTO_SAVE_SLOTS - 1; i >= 0; i--)
            {
                if (SaveManager.Instance.HasSave(i, true))
                {
                    SaveManager.Instance.LoadAutoSave(i);
                    GameManager.Instance.SetGameState(GameManager.GameState.Playing);
                    return;
                }
            }
        }

        private void OnSaveClicked() => ShowPanel(saveGamePanel);
        private void OnLoadClicked() => ShowPanel(loadGamePanel);
        private void OnSettingsClicked() => ShowPanel(settingsPanel);

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

        private void OnCancelNewGame() => ShowPanel(mainPanel);

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
                continueButton.interactable = false;

                for (int i = SaveManager.AUTO_SAVE_SLOTS - 1; i >= 0; i--)
                {
                    if (SaveManager.Instance.HasSave(i, true))
                    {
                        continueButton.interactable = true;
                        break;
                    }
                }
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

using UnityEngine;
using UnityEngine.UI;
using UnityEngine.EventSystems;
using UnityEngine.SceneManagement;
using ProbMenu.Core;
using ProbMenu.SaveSystem;
using ProbMenu.Data;
using ProbMenu.Racing;
using Logger = ProbMenu.Core.Logger;

namespace ProbMenu.Menus
{
    /// <summary>
    /// Контроллер меню игры с ИДЕАЛЬНОЙ навигацией
    /// </summary>
    public class GameMenuController : MonoBehaviour
    {
        [Header("Настройки сцен")]
        [SerializeField] private string raceScene = "Race";
        [SerializeField] private string garageScene = "Garage";
        [SerializeField] private string tuningScene = "Tuning";
        [SerializeField] private string shopScene = "Shop";

        [Header("UI Панели")]
        [SerializeField] private GameObject mainPanel;
        [SerializeField] private GameObject garagePanel;
        [SerializeField] private GameObject tuningPanel;
        [SerializeField] private GameObject shopPanel;

        [Header("Кнопки")]
        [Tooltip("5 кнопок: Заезд, Гараж, Тюнинг, Магазин, Меню")]
        [SerializeField] private Button[] gameMenuButtons = new Button[5];

        [Header("Цвета - ОЧЕНЬ КОНТРАСТНЫЕ!")]
        [SerializeField] private Color selectedColor = Color.cyan; // ЯРКО-ГОЛУБОЙ
        [SerializeField] private Color normalColor = Color.gray;
        [SerializeField] private Color hoveredColor = Color.white;

        private PlayerData playerData;
        private CareerManager careerManager;
        private int currentButtonIndex = 0;

        private void Start()
        {
            Logger.I("=== GAME MENU ===");
            Logger.I("↑↓ навигация, Enter выбор, Esc возврат");

            LoadPlayerData();
            InitializeCareerManager();
            
            // Автоматический поиск кнопок
            if (gameMenuButtons == null || gameMenuButtons[0] == null)
            {
                gameMenuButtons = FindObjectsOfType<Button>();
                Logger.W($"Найдено {gameMenuButtons.Length} кнопок");
            }

            InitializeButtons();
            UpdateUI();
            ShowMainPanel();
            
            // Выделяем первую кнопку СРАЗУ
            SelectButton(0);
        }

        private void Update()
        {
            HandleNavigation();
            
            if (UnityEngine.Input.GetKeyDown(KeyCode.Escape))
            {
                OnBackToMainMenu();
            }
        }

        #region Initialization

        private void InitializeButtons()
        {
            for (int i = 0; i < gameMenuButtons.Length; i++)
            {
                if (gameMenuButtons[i] == null) continue;

                // Навигация
                var navigation = gameMenuButtons[i].navigation;
                navigation.mode = Navigation.Mode.Explicit;
                navigation.selectOnUp = (i > 0) ? gameMenuButtons[i - 1] : gameMenuButtons[gameMenuButtons.Length - 1];
                navigation.selectOnDown = (i < gameMenuButtons.Length - 1) ? gameMenuButtons[i + 1] : gameMenuButtons[0];
                gameMenuButtons[i].navigation = navigation;
                
                // ЦВЕТА
                ColorBlock colors = gameMenuButtons[i].colors;
                colors.normalColor = normalColor;
                colors.highlightedColor = hoveredColor;
                colors.selectedColor = selectedColor; // ЯРКО-ГОЛУБОЙ!
                colors.pressedColor = Color.red;
                gameMenuButtons[i].colors = colors;
                
                int index = i;
                gameMenuButtons[i].onClick.AddListener(() => OnButtonClicked(index));
            }
        }

        private void InitializeCareerManager()
        {
            careerManager = FindObjectOfType<CareerManager>();
            if (careerManager == null)
            {
                var go = new GameObject("CareerManager");
                careerManager = go.AddComponent<CareerManager>();
            }
        }

        private void ShowMainPanel()
        {
            if (mainPanel != null) mainPanel.SetActive(true);
            if (garagePanel != null) garagePanel.SetActive(false);
            if (tuningPanel != null) tuningPanel.SetActive(false);
            if (shopPanel != null) shopPanel.SetActive(false);
        }

        #endregion

        #region Navigation

        private void HandleNavigation()
        {
            if (UnityEngine.Input.GetKeyDown(KeyCode.UpArrow))
            {
                NavigateUp();
            }

            if (UnityEngine.Input.GetKeyDown(KeyCode.DownArrow))
            {
                NavigateDown();
            }

            if (UnityEngine.Input.GetKeyDown(KeyCode.Return) || UnityEngine.Input.GetKeyDown(KeyCode.Space))
            {
                SelectCurrentButton();
            }
        }

        private void NavigateUp()
        {
            if (gameMenuButtons == null || gameMenuButtons.Length == 0) return;
            currentButtonIndex = (currentButtonIndex - 1 + gameMenuButtons.Length) % gameMenuButtons.Length;
            SelectButton(currentButtonIndex);
        }

        private void NavigateDown()
        {
            if (gameMenuButtons == null || gameMenuButtons.Length == 0) return;
            currentButtonIndex = (currentButtonIndex + 1) % gameMenuButtons.Length;
            SelectButton(currentButtonIndex);
        }

        private void SelectButton(int index)
        {
            if (gameMenuButtons == null || index < 0 || index >= gameMenuButtons.Length) return;
            if (gameMenuButtons[index] == null) return;

            EventSystem.current.SetSelectedGameObject(gameMenuButtons[index].gameObject);
            Logger.I($"🔘 Кнопка {index}: {gameMenuButtons[index].name} (ГОЛУБАЯ!)");
        }

        private void SelectCurrentButton()
        {
            if (gameMenuButtons == null || gameMenuButtons.Length == 0) return;
            if (gameMenuButtons[currentButtonIndex] == null) return;

            Logger.I($"▶️ ВЫБОР кнопки {currentButtonIndex}");
            gameMenuButtons[currentButtonIndex].onClick.Invoke();
        }

        private void OnButtonClicked(int index)
        {
            currentButtonIndex = index;
            Logger.I($"🖱️ Клик: {index}");

            switch (index)
            {
                case 0: OnRace(); break;
                case 1: OnGarage(); break;
                case 2: OnTuning(); break;
                case 3: OnShop(); break;
                case 4: OnBackToMainMenu(); break;
            }
        }

        #endregion

        #region Menu Actions

        public void OnRace()
        {
            Logger.I("🏁 ЗАЕЗД");
            if (playerData == null) { Logger.E("Нет данных!"); return; }
            GameManager.Instance.ChangeState(GameManager.GameState.Playing);
            GameManager.Instance.LoadScene(raceScene);
        }

        public void OnGarage()
        {
            Logger.I("🚗 ГАРАЖ");
            if (garagePanel != null) { mainPanel.SetActive(false); garagePanel.SetActive(true); }
            else GameManager.Instance.LoadScene(garageScene);
        }

        public void OnTuning()
        {
            Logger.I("🔧 ТЮНИНГ");
            if (tuningPanel != null) { mainPanel.SetActive(false); tuningPanel.SetActive(true); }
            else GameManager.Instance.LoadScene(tuningScene);
        }

        public void OnShop()
        {
            Logger.I("🛒 МАГАЗИН");
            Logger.I($"Баланс: ${playerData?.money ?? 0}");
            if (shopPanel != null) { mainPanel.SetActive(false); shopPanel.SetActive(true); }
            else GameManager.Instance.LoadScene(shopScene);
        }

        public void OnBackToMainMenu()
        {
            Logger.I("⬅️ ВОЗВРАТ");
            SaveManager.Instance.AutoSave();
            GameManager.Instance.ChangeState(GameManager.GameState.MainMenu);
            GameManager.Instance.LoadScene("MainMenu");
        }

        #endregion

        #region Data

        private void LoadPlayerData()
        {
            var saveData = SaveManager.Instance.Load(0);
            if (saveData != null)
            {
                playerData = new PlayerData
                {
                    playerName = saveData.playerName,
                    level = saveData.level,
                    experience = saveData.experience,
                    money = saveData.money,
                    currentCarId = saveData.currentCarId,
                    ownedCars = saveData.ownedCars
                };
                Logger.I($"✅ {playerData.playerName} (Ур.{playerData.level})");
            }
            else
            {
                playerData = new PlayerData();
                Logger.I("📄 Новый игрок");
            }
        }

        private void UpdateUI() { }
        public PlayerData GetPlayerData() => playerData;

        #endregion
    }
}

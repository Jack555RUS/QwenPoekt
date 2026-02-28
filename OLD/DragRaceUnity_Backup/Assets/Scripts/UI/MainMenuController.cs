using UnityEngine;
using UnityEngine.UI;
using UnityEngine.EventSystems;
using ProbMenu.Core;
using ProbMenu.SaveSystem;
using ProbMenu.Data;
using System;
using Logger = ProbMenu.Core.Logger;

namespace ProbMenu.Menus
{
    /// <summary>
    /// Главное меню игры
    /// Версия с РУЧНЫМ назначением кнопок через инспектор
    /// </summary>
    public class MainMenuController : MonoBehaviour
    {
        #region Fields
        
        [Header("UI Elements - НАЗНАЧИТЬ В ИНСПЕКТОРЕ!")]
        [Tooltip("Панель главного меню")]
        [SerializeField] private GameObject mainMenuPanel;
        
        [Tooltip("Панель слотов сохранений")]
        [SerializeField] private GameObject saveSlotsPanel;
        
        [Tooltip("5 кнопок слотов")]
        [SerializeField] private Button[] saveSlotButtons = new Button[5];
        
        [Tooltip("5 текстов слотов")]
        [SerializeField] private Text[] saveSlotTexts = new Text[5];
        
        [Tooltip("Заголовок панели слотов")]
        [SerializeField] private Text slotTitleText;
        
        [Header("КНОПКИ МЕНЮ - НАЗНАЧИТЬ ВРУЧНУЮ!")]
        [Tooltip("Кнопка: Новая игра")]
        [SerializeField] private Button btnNewGame;
        
        [Tooltip("Кнопка: Продолжить")]
        [SerializeField] private Button btnContinue;
        
        [Tooltip("Кнопка: Сохранить")]
        [SerializeField] private Button btnSave;
        
        [Tooltip("Кнопка: Загрузить")]
        [SerializeField] private Button btnLoad;
        
        [Tooltip("Кнопка: Настройки")]
        [SerializeField] private Button btnSettings;
        
        [Tooltip("Кнопка: Выход")]
        [SerializeField] private Button btnExit;
        
        // Массив для навигации
        private Button[] menuButtons = new Button[6];

        [Header("Colors - ОЧЕНЬ ЯРКИЕ!")]
        [SerializeField] private Color selectedColor = new Color(1f, 1f, 0f, 1f); // ЯРКО-ЖЁЛТЫЙ
        [SerializeField] private Color normalColor = new Color(0.5f, 0.5f, 0.5f, 1f); // Серый
        [SerializeField] private Color hoveredColor = Color.white;

        // State
        private int currentButtonIndex;
        private bool showingSaveSlots;
        private int currentSlotIndex;
        private bool isSavingMode;
        
        #endregion

        #region Unity Lifecycle

        private void Awake()
        {
            Logger.I("===========================================");
            Logger.I("=== ГЛАВНОЕ МЕНЮ - AWAKE ===");
            Logger.I("===========================================");
            
            // Инициализация состояния
            currentButtonIndex = 0;
            showingSaveSlots = false;
            currentSlotIndex = 0;
            isSavingMode = false;
            
            InitializeEventSystem();
            SetupButtonsArray();
            SetupNavigation();
            CreateSaveSlotsPanel();
            
            Logger.I("✅ Awake завершён");
        }

        private void Start()
        {
            Logger.I("=== ГЛАВНОЕ МЕНЮ - START ===");
            
            // Скрываем слоты
            if (saveSlotsPanel != null)
            {
                saveSlotsPanel.SetActive(false);
            }
            
            // Выделяем первую кнопку через 1 кадр
            Invoke(nameof(SelectFirstButton), 0.1f);
            
            Logger.I("✅ Меню готово");
            Logger.I("===========================================");
        }

        private void Update()
        {
            HandleInput();
        }
        
        #endregion

        #region Initialization

        private void InitializeEventSystem()
        {
            EventSystem eventSystem = FindObjectOfType<EventSystem>();
            
            if (eventSystem == null)
            {
                Logger.I("Создаю EventSystem...");
                GameObject go = new GameObject("EventSystem");
                eventSystem = go.AddComponent<EventSystem>();
                go.AddComponent<StandaloneInputModule>();
            }
            
            Logger.I($"✅ EventSystem: {eventSystem.name}");
        }

        private void SetupButtonsArray()
        {
            Logger.I("🔧 Назначение кнопок...");
            
            // Проверяем что все кнопки назначены
            if (btnNewGame == null) Logger.E("❌ btnNewGame не назначена!");
            if (btnContinue == null) Logger.E("❌ btnContinue не назначена!");
            if (btnSave == null) Logger.E("❌ btnSave не назначена!");
            if (btnLoad == null) Logger.E("❌ btnLoad не назначена!");
            if (btnSettings == null) Logger.E("❌ btnSettings не назначена!");
            if (btnExit == null) Logger.E("❌ btnExit не назначена!");
            
            // Создаём массив в правильном порядке
            menuButtons[0] = btnNewGame;
            menuButtons[1] = btnContinue;
            menuButtons[2] = btnSave;
            menuButtons[3] = btnLoad;
            menuButtons[4] = btnSettings;
            menuButtons[5] = btnExit;
            
            int count = 0;
            for (int i = 0; i < menuButtons.Length; i++)
            {
                if (menuButtons[i] != null)
                {
                    Logger.I($"  [{i}] {menuButtons[i].name}");
                    count++;
                }
            }
            
            Logger.I($"✅ Кнопок назначено: {count}/6");
        }

        private void SetupNavigation()
        {
            Logger.I("🔧 Настройка навигации...");
            
            for (int i = 0; i < menuButtons.Length; i++)
            {
                if (menuButtons[i] == null)
                {
                    Logger.W($"⚠️ Кнопка {i} = null!");
                    continue;
                }

                // Навигация вверх/вниз
                var nav = menuButtons[i].navigation;
                nav.mode = Navigation.Mode.Explicit;
                
                // ВВЕРХ (предыдущая кнопка)
                if (i > 0)
                    nav.selectOnUp = menuButtons[i - 1];
                else
                    nav.selectOnUp = menuButtons[menuButtons.Length - 1]; // Зацикливание
                
                // ВНИЗ (следующая кнопка)
                if (i < menuButtons.Length - 1)
                    nav.selectOnDown = menuButtons[i + 1];
                else
                    nav.selectOnDown = menuButtons[0]; // Зацикливание
                    
                menuButtons[i].navigation = nav;
                
                // Цвета - ОЧЕНЬ ЯРКИЕ!
                ColorBlock colors = menuButtons[i].colors;
                colors.normalColor = normalColor;
                colors.highlightedColor = hoveredColor;
                colors.selectedColor = selectedColor; // ЯРКО-ЖЁЛТЫЙ!
                colors.pressedColor = Color.red;
                menuButtons[i].colors = colors;
                
                // Обработчик клика - ТОЛЬКО ОДИН РАЗ!
                menuButtons[i].onClick.RemoveAllListeners(); // Удаляем старые
                int buttonIndex = i;
                menuButtons[i].onClick.AddListener(() => OnButtonClick(buttonIndex));
                
                Logger.I($"  ✅ Кнопка {i}: {menuButtons[i].name}");
            }
            
            Logger.I("✅ Навигация настроена");
        }

        #endregion

        #region Input Handling

        private void HandleInput()
        {
            if (showingSaveSlots)
            {
                HandleSlotsInput();
            }
            else
            {
                HandleMenuInput();
            }
        }

        private void HandleMenuInput()
        {
            // ВВЕРХ
            if (UnityEngine.Input.GetKeyDown(KeyCode.UpArrow))
            {
                currentButtonIndex = (currentButtonIndex - 1 + menuButtons.Length) % menuButtons.Length;
                EventSystem.current.SetSelectedGameObject(menuButtons[currentButtonIndex].gameObject);
                Logger.I($"↑ Кнопка {currentButtonIndex}: {menuButtons[currentButtonIndex].name}");
            }

            // ВНИЗ
            if (UnityEngine.Input.GetKeyDown(KeyCode.DownArrow))
            {
                currentButtonIndex = (currentButtonIndex + 1) % menuButtons.Length;
                EventSystem.current.SetSelectedGameObject(menuButtons[currentButtonIndex].gameObject);
                Logger.I($"↓ Кнопка {currentButtonIndex}: {menuButtons[currentButtonIndex].name}");
            }

            // ENTER или ПРОБЕЛ
            if (UnityEngine.Input.GetKeyDown(KeyCode.Return) || UnityEngine.Input.GetKeyDown(KeyCode.Space))
            {
                Logger.I($"↵ Выбор кнопки {currentButtonIndex}");
                
                if (menuButtons[currentButtonIndex] != null)
                {
                    menuButtons[currentButtonIndex].onClick.Invoke();
                }
            }
        }

        private void HandleSlotsInput()
        {
            // ВВЕРХ
            if (UnityEngine.Input.GetKeyDown(KeyCode.UpArrow))
            {
                currentSlotIndex = (currentSlotIndex - 1 + saveSlotButtons.Length) % saveSlotButtons.Length;
                EventSystem.current.SetSelectedGameObject(saveSlotButtons[currentSlotIndex].gameObject);
                Logger.I($"↑ Слот {currentSlotIndex}");
            }

            // ВНИЗ
            if (UnityEngine.Input.GetKeyDown(KeyCode.DownArrow))
            {
                currentSlotIndex = (currentSlotIndex + 1) % saveSlotButtons.Length;
                EventSystem.current.SetSelectedGameObject(saveSlotButtons[currentSlotIndex].gameObject);
                Logger.I($"↓ Слот {currentSlotIndex}");
            }

            // ENTER или ПРОБЕЛ
            if (UnityEngine.Input.GetKeyDown(KeyCode.Return) || UnityEngine.Input.GetKeyDown(KeyCode.Space))
            {
                Logger.I($"↵ Выбор слота {currentSlotIndex}");
                SelectSlot(currentSlotIndex);
            }

            // ESC - ОТМЕНА
            if (UnityEngine.Input.GetKeyDown(KeyCode.Escape))
            {
                Logger.I("⎋ Отмена - возврат в меню");
                HideSlots();
            }
        }
        
        #endregion

        #region Button Click Handlers

        private void OnButtonClick(int index)
        {
            currentButtonIndex = index;
            Logger.I($"🖱️ Клик кнопки {index}");

            switch (index)
            {
                case 0: OnNewGame(); break;
                case 1: OnContinue(); break;
                case 2: OnSave(); break;
                case 3: OnLoad(); break;
                case 4: OnSettings(); break;
                case 5: OnExit(); break;
            }
        }

        private void OnNewGame()
        {
            Logger.I("🎮 НОВАЯ ИГРА");
            
            var playerData = new PlayerData 
            { 
                playerName = "Player", 
                money = 50000,
                level = 1
            };
            
            var saveData = new SaveManager.SaveData
            {
                playerName = playerData.playerName,
                level = playerData.level,
                money = playerData.money,
                lastScene = "GameMenu",
                saveTime = DateTime.Now
            };

            SaveManager.Instance.Save(0, saveData);
            Logger.I("💾 Автосохранение в слот 0");
            
            GameManager.Instance.ChangeState(GameManager.GameState.Playing);
            GameManager.Instance.LoadScene("GameMenu");
        }

        private void OnContinue()
        {
            Logger.I("▶️ ПРОДОЛЖИТЬ");
            
            var saveData = SaveManager.Instance.Load(0);
            
            if (saveData != null)
            {
                Logger.I($"✅ Загружено: {saveData.playerName}");
                GameManager.Instance.ChangeState(GameManager.GameState.Playing);
                GameManager.Instance.LoadScene("GameMenu");
            }
            else
            {
                Logger.W("⚠️ Нет сохранений!");
            }
        }

        private void OnSave()
        {
            Logger.I("💾 СОХРАНИТЬ");
            ShowSlots(true);
        }

        private void OnLoad()
        {
            Logger.I("📂 ЗАГРУЗИТЬ");
            ShowSlots(false);
        }

        private void OnSettings()
        {
            Logger.I("⚙️ НАСТРОЙКИ");
            Logger.I("⚠️ Настройки ещё не реализованы");
        }

        private void OnExit()
        {
            Logger.I("🚪 ВЫХОД ИЗ ИГРЫ");
            SaveManager.Instance.AutoSave();
            GameManager.Instance.QuitGame();
        }
        
        #endregion

        #region Save/Load Slots

        private void ShowSlots(bool saving)
        {
            Logger.I("===========================================");
            Logger.I($"ShowSlots({(saving ? "SAVE" : "LOAD")})");
            
            showingSaveSlots = true;
            isSavingMode = saving;
            
            // Обновляем заголовок
            if (slotTitleText != null)
            {
                slotTitleText.text = saving ? "💾 СОХРАНЕНИЕ" : "📂 ЗАГРУЗКА";
                slotTitleText.color = Color.white;
                slotTitleText.fontSize = 24;
                slotTitleText.alignment = TextAnchor.MiddleCenter;
            }
            
            // Показываем панель
            if (saveSlotsPanel != null)
            {
                saveSlotsPanel.SetActive(true);
                Logger.I("✅ Панель слотов АКТИВНА");
            }
            
            UpdateSlotsDisplay();
            currentSlotIndex = 0;
            
            if (saveSlotButtons != null && saveSlotButtons.Length > 0 && saveSlotButtons[0] != null)
            {
                EventSystem.current.SetSelectedGameObject(saveSlotButtons[0].gameObject);
                Logger.I("✅ Выделен слот 0");
            }
            
            Logger.I("===========================================");
        }

        private void HideSlots()
        {
            Logger.I("↩️ HideSlots - возврат в меню");
            showingSaveSlots = false;
            
            if (saveSlotsPanel != null)
            {
                saveSlotsPanel.SetActive(false);
            }
            
            SelectButton(currentButtonIndex);
        }

        private void UpdateSlotsDisplay()
        {
            if (saveSlotTexts == null) return;
            
            for (int i = 0; i < 5; i++)
            {
                var saveData = SaveManager.Instance.Load(i);
                
                string text = saveData != null
                    ? $"Слот {i}: {saveData.playerName} (Ур.{saveData.level})\n${saveData.money}\n{saveData.saveTime:dd.MM.yyyy HH:mm}"
                    : $"Слот {i}: Пусто";
                
                if (saveSlotTexts[i] != null)
                {
                    saveSlotTexts[i].text = text;
                }
            }
        }

        private void SelectSlot(int index)
        {
            Logger.I($"SelectSlot({index}) - {(isSavingMode ? "SAVE" : "LOAD")}");
            
            var saveData = SaveManager.Instance.Load(index);

            if (isSavingMode)
            {
                var currentData = SaveManager.Instance.Load(0);
                if (currentData != null)
                {
                    SaveManager.Instance.Save(index, currentData);
                    Logger.I($"💾 Сохранено в слот {index}");
                    UpdateSlotsDisplay();
                }
            }
            else
            {
                if (saveData != null)
                {
                    Logger.I($"📂 Загружено: {saveData.playerName}");
                    GameManager.Instance.ChangeState(GameManager.GameState.Playing);
                    GameManager.Instance.LoadScene("GameMenu");
                }
                else
                {
                    Logger.W("⚠️ Слот пуст!");
                }
            }
            
            HideSlots();
        }
        
        #endregion

        #region Helper Methods

        private void SelectFirstButton()
        {
            SelectButton(0);
            Logger.I("✅ Первая кнопка выделена");
        }

        private void SelectButton(int index)
        {
            if (menuButtons == null || index < 0 || index >= menuButtons.Length) return;
            if (menuButtons[index] == null) return;

            EventSystem.current.SetSelectedGameObject(menuButtons[index].gameObject);
            currentButtonIndex = index;
            Logger.I($"🔘 Выделена кнопка {index}: {menuButtons[index].name}");
        }

        private void CreateSaveSlotsPanel()
        {
            Logger.I("🔧 CreateSaveSlotsPanel()");
            
            Canvas canvas = FindObjectOfType<Canvas>();
            if (canvas == null)
            {
                Logger.W("⚠️ Canvas не найден! Создаю...");
                GameObject go = new GameObject("Canvas");
                canvas = go.AddComponent<Canvas>();
                canvas.renderMode = RenderMode.ScreenSpaceOverlay;
                go.AddComponent<GraphicRaycaster>();
            }

            GameObject panel = new GameObject("SaveSlotsPanel");
            panel.transform.SetParent(canvas.transform, false);
            
            RectTransform rt = panel.AddComponent<RectTransform>();
            rt.sizeDelta = new Vector2(600, 450);
            rt.anchoredPosition = Vector2.zero;
            
            Image bg = panel.AddComponent<Image>();
            bg.color = new Color(0, 0, 0, 0.95f);
            
            VerticalLayoutGroup vlg = panel.AddComponent<VerticalLayoutGroup>();
            vlg.padding = new RectOffset(20, 20, 20, 20);
            vlg.spacing = 10;
            vlg.childAlignment = TextAnchor.UpperCenter;
            
            saveSlotsPanel = panel;
            saveSlotButtons = new Button[5];
            saveSlotTexts = new Text[5];
            
            // Заголовок
            GameObject titleObj = new GameObject("Title");
            titleObj.transform.SetParent(panel.transform, false);
            RectTransform titleRt = titleObj.AddComponent<RectTransform>();
            titleRt.sizeDelta = new Vector2(560, 40);
            
            slotTitleText = titleObj.AddComponent<Text>();
            slotTitleText.font = Resources.GetBuiltinResource<Font>("LegacyRuntime.ttf");
            slotTitleText.fontSize = 24;
            slotTitleText.alignment = TextAnchor.MiddleCenter;
            slotTitleText.color = Color.white;
            slotTitleText.text = "Выберите слот";
            
            for (int i = 0; i < 5; i++)
            {
                CreateSaveSlot(panel.transform, i, out saveSlotButtons[i], out saveSlotTexts[i]);
            }
            
            CreateCancelButton(panel.transform);
            
            Logger.I("✅ Слоты созданы");
        }

        private void CreateSaveSlot(Transform parent, int index, out Button btn, out Text txt)
        {
            GameObject slot = new GameObject($"SaveSlot{index}");
            slot.transform.SetParent(parent, false);
            
            RectTransform slotRt = slot.AddComponent<RectTransform>();
            slotRt.sizeDelta = new Vector2(560, 60);
            
            btn = slot.AddComponent<Button>();
            
            Image img = slot.AddComponent<Image>();
            img.color = new Color(0.2f, 0.2f, 0.2f, 1f);
            
            var nav = btn.navigation;
            nav.mode = Navigation.Mode.Explicit;
            if (index > 0) nav.selectOnUp = saveSlotButtons[index - 1];
            if (index < 4) nav.selectOnDown = saveSlotButtons[index + 1];
            btn.navigation = nav;
            
            ColorBlock colors = btn.colors;
            colors.normalColor = new Color(0.2f, 0.2f, 0.2f, 1f);
            colors.selectedColor = new Color(0f, 1f, 0f, 1f);
            colors.highlightedColor = Color.white;
            btn.colors = colors;
            
            GameObject textObj = new GameObject("Text");
            textObj.transform.SetParent(slot.transform, false);
            RectTransform textRt = textObj.AddComponent<RectTransform>();
            textRt.anchorMin = Vector2.zero;
            textRt.anchorMax = Vector2.one;
            textRt.offsetMin = new Vector2(15, 15);
            textRt.offsetMax = new Vector2(-15, -15);
            
            txt = textObj.AddComponent<Text>();
            txt.font = Resources.GetBuiltinResource<Font>("LegacyRuntime.ttf");
            txt.fontSize = 16;
            txt.alignment = TextAnchor.MiddleLeft;
            txt.color = Color.white;
            txt.text = $"Слот {index}: Пусто";
        }

        private void CreateCancelButton(Transform parent)
        {
            GameObject cancel = new GameObject("CancelButton");
            cancel.transform.SetParent(parent, false);
            
            RectTransform rt = cancel.AddComponent<RectTransform>();
            rt.sizeDelta = new Vector2(200, 40);
            rt.anchorMin = new Vector2(0.5f, 0f);
            rt.anchorMax = new Vector2(0.5f, 0f);
            rt.anchoredPosition = new Vector2(0, -10);
            
            Button btn = cancel.AddComponent<Button>();
            Image img = cancel.AddComponent<Image>();
            img.color = new Color(0.6f, 0.2f, 0.2f, 1f);
            
            GameObject textObj = new GameObject("Text");
            textObj.transform.SetParent(cancel.transform, false);
            RectTransform textRt = textObj.AddComponent<RectTransform>();
            textRt.anchorMin = Vector2.zero;
            textRt.anchorMax = Vector2.one;
            
            Text txt = textObj.AddComponent<Text>();
            txt.font = Resources.GetBuiltinResource<Font>("LegacyRuntime.ttf");
            txt.fontSize = 16;
            txt.alignment = TextAnchor.MiddleCenter;
            txt.color = Color.white;
            txt.text = "Отмена (Esc)";
            
            btn.onClick.AddListener(HideSlots);
            
            Logger.I("  ✅ Кнопка отмены создана");
        }
        
        #endregion
    }
}

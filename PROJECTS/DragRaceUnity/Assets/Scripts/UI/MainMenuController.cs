using UnityEngine;
using UnityEngine.UI;
using UnityEngine.EventSystems;

/// <summary>
/// Контроллер главного меню с навигацией.
/// </summary>
public class MainMenuController : MonoBehaviour
{
    [Header("Диалог выхода")]
    [SerializeField] private ExitConfirmationDialog exitDialog;

    [Header("Навигация")]
    [SerializeField] private Button firstButton;
    [SerializeField] private Button lastButton;

    private Button[] _buttons;
    private int _currentIndex = 0;

    #region Unity Methods

    private void Start()
    {
        Logger.Info("Главное меню загружено. Ожидание ввода...", this);
        
        // Находим все кнопки
        _buttons = GetComponentsInChildren<Button>(true);
        
        if (_buttons.Length > 0)
        {
            // Выделяем первую кнопку
            firstButton = _buttons[0];
            lastButton = _buttons[_buttons.Length - 1];
            
            EventSystem.current?.SetSelectedGameObject(firstButton.gameObject);
            
            Logger.Info($"Найдено кнопок: {_buttons.Length}", this);
        }
    }

    private void Update()
    {
        HandleKeyboardNavigation();
    }

    #endregion

    #region Keyboard Navigation

    private void HandleKeyboardNavigation()
    {
        if (Input.GetKeyDown(KeyCode.UpArrow))
        {
            NavigateUp();
        }
        else if (Input.GetKeyDown(KeyCode.DownArrow))
        {
            NavigateDown();
        }
        else if (Input.GetKeyDown(KeyCode.Return) || Input.GetKeyDown(KeyCode.KeypadEnter))
        {
            ActivateCurrentButton();
        }
        else if (Input.GetKeyDown(KeyCode.Escape))
        {
            OnExit();
        }
    }

    private void NavigateUp()
    {
        if (_buttons == null || _buttons.Length == 0) return;
        
        _currentIndex--;
        if (_currentIndex < 0)
        {
            _currentIndex = _buttons.Length - 1;
        }
        
        EventSystem.current?.SetSelectedGameObject(_buttons[_currentIndex].gameObject);
        Logger.Debug($"Навигация вверх: кнопка {_currentIndex}", this);
    }

    private void NavigateDown()
    {
        if (_buttons == null || _buttons.Length == 0) return;
        
        _currentIndex++;
        if (_currentIndex >= _buttons.Length)
        {
            _currentIndex = 0;
        }
        
        EventSystem.current?.SetSelectedGameObject(_buttons[_currentIndex].gameObject);
        Logger.Debug($"Навигация вниз: кнопка {_currentIndex}", this);
    }

    private void ActivateCurrentButton()
    {
        if (_buttons == null || _buttons.Length == 0) return;
        
        var currentButton = _buttons[_currentIndex];
        if (currentButton != null && currentButton.interactable)
        {
            currentButton.onClick?.Invoke();
            Logger.Debug($"Активация кнопки: {_currentIndex}", this);
        }
    }

    #endregion

    #region Button Handlers

    public void OnNewGame()
    {
        Logger.Info("Нажата кнопка: НОВАЯ ИГРА", this);
        HandleNewGame();
    }

    public void OnContinue()
    {
        Logger.Info("Нажата кнопка: ПРОДОЛЖИТЬ", this);
        HandleContinue();
    }

    public void OnSave()
    {
        Logger.Info("Нажата кнопка: СОХРАНИТЬ", this);
        HandleSave();
    }

    public void OnLoad()
    {
        Logger.Info("Нажата кнопка: ЗАГРУЗИТЬ", this);
        HandleLoad();
    }

    public void OnSettings()
    {
        Logger.Info("Нажата кнопка: НАСТРОЙКИ", this);
        HandleSettings();
    }

    public void OnExit()
    {
        Logger.Info("Нажата кнопка: ВЫХОД", this);
        HandleExit();
    }

    #endregion

    #region Private Methods

    private void HandleNewGame()
    {
        Logger.Debug("Выполняется логика создания новой игры...", this);
        
        PlayerData newData = new PlayerData();
        bool saved = SaveSystem.Save(0, newData);
        
        if (saved)
        {
            Logger.Info("Новая игра создана и сохранена", this);
        }
        else
        {
            Logger.Error("Не удалось создать новую игру", this);
        }
    }

    private void HandleContinue()
    {
        Logger.Debug("Выполняется логика продолжения игры...", this);
        
        if (SaveSystem.HasSave(0))
        {
            PlayerData data = SaveSystem.Load(0);
            Logger.Info($"Продолжение: {data.PlayerName}, Уровень {data.Level}", this);
        }
        else
        {
            Logger.Warning("Нет сохранений для продолжения", this);
        }
    }

    private void HandleSave()
    {
        Logger.Debug("Выполняется логика сохранения...", this);
        
        PlayerData data = new PlayerData
        {
            PlayerName = "Hero",
            Level = 5,
            Money = 2500
        };
        
        bool saved = SaveSystem.Save(0, data);
        
        if (saved)
        {
            Logger.Info("Игра сохранена", this);
        }
        else
        {
            Logger.Error("Не удалось сохранить игру", this);
        }
    }

    private void HandleLoad()
    {
        Logger.Debug("Выполняется логика загрузки...", this);
        
        string[] saves = SaveSystem.GetAllSaveInfo();
        
        foreach (string save in saves)
        {
            Logger.Info(save, this);
        }
    }

    private void HandleSettings()
    {
        Logger.Debug("Выполняется логика открытия настроек...", this);
    }

    private void HandleExit()
    {
        Logger.Debug("Открытие диалога подтверждения выхода...", this);
        
        if (exitDialog != null)
        {
            exitDialog.ShowDialog();
        }
        else
        {
            Logger.Warning("Диалог выхода не назначен! Выполняется прямой выход.", this);
            DoExit();
        }
    }

    private void DoExit()
    {
        Logger.Debug("Выполняется выход из приложения...", this);

#if UNITY_EDITOR
        UnityEditor.EditorApplication.isPlaying = false;
#else
        Application.Quit();
#endif

        Logger.Info("Приложение закрыто", this);
    }

    #endregion
}

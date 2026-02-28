using UnityEngine;
using UnityEngine.UI;

/// <summary>
/// Диалог подтверждения выхода.
/// </summary>
public class ExitConfirmationDialog : MonoBehaviour
{
    [Header("Панель диалога")]
    [SerializeField] private GameObject dialogPanel;
    
    [Header("Кнопки")]
    [SerializeField] private Button saveAndExitButton;
    [SerializeField] private Button exitWithoutSaveButton;
    [SerializeField] private Button cancelButton;

    private void Awake()
    {
        // Скрываем диалог при старте
        if (dialogPanel != null)
        {
            dialogPanel.SetActive(false);
        }
    }

    private void OnEnable()
    {
        // Подписываемся на кнопки
        if (saveAndExitButton != null)
            saveAndExitButton.onClick.AddListener(SaveAndExit);
        
        if (exitWithoutSaveButton != null)
            exitWithoutSaveButton.onClick.AddListener(ExitWithoutSave);
        
        if (cancelButton != null)
            cancelButton.onClick.AddListener(CloseDialog);
    }

    private void OnDisable()
    {
        // Отписываемся от кнопок
        if (saveAndExitButton != null)
            saveAndExitButton.onClick.RemoveListener(SaveAndExit);
        
        if (exitWithoutSaveButton != null)
            exitWithoutSaveButton.onClick.RemoveListener(ExitWithoutSave);
        
        if (cancelButton != null)
            cancelButton.onClick.RemoveListener(CloseDialog);
    }

    /// <summary>
    /// Показать диалог.
    /// </summary>
    public void ShowDialog()
    {
        if (dialogPanel != null)
        {
            dialogPanel.SetActive(true);
            Logger.Info("Диалог подтверждения выхода открыт", this);
        }
    }

    /// <summary>
    /// Закрыть диалог.
    /// </summary>
    private void CloseDialog()
    {
        if (dialogPanel != null)
        {
            dialogPanel.SetActive(false);
            Logger.Info("Диалог подтверждения выхода закрыт", this);
        }
    }

    /// <summary>
    /// Сохранить и выйти.
    /// </summary>
    private void SaveAndExit()
    {
        Logger.Info("Сохранение прогресса и выход...", this);
        
        // Автосохранение текущего прогресса
        PlayerData currentData = SaveSystem.Load(0);
        if (currentData == null)
        {
            currentData = new PlayerData();
        }
        
        // Обновляем статистику
        currentData.UpdatePlayTime(Time.time);
        
        // Сохраняем
        bool saved = SaveSystem.Save(0, currentData);
        
        if (saved)
        {
            Logger.Info("Прогресс сохранён. Выход из игры.", this);
        }
        else
        {
            Logger.Warning("Не удалось сохранить прогресс, но выход выполняется.", this);
        }
        
        // Выход
        CloseDialog();
        DoExit();
    }

    /// <summary>
    /// Выйти без сохранения.
    /// </summary>
    private void ExitWithoutSave()
    {
        Logger.Info("Выход без сохранения", this);
        CloseDialog();
        DoExit();
    }

    /// <summary>
    /// Выполнить выход.
    /// </summary>
    private void DoExit()
    {
#if UNITY_EDITOR
        UnityEditor.EditorApplication.isPlaying = false;
#else
        Application.Quit();
#endif
    }
}

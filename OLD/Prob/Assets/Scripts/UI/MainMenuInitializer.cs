using UnityEngine;
using UnityEngine.Audio;
using UnityEngine.UIElements;

namespace RacingGame.UI
{
    /// <summary>
    /// Инициализатор главного меню. Создает менеджеров и настраивает UI.
    /// </summary>
    public class MainMenuInitializer : MonoBehaviour
    {
        [Header("UI Документы")]
        [SerializeField] private VisualTreeAsset _mainMenuAsset;
        [SerializeField] private VisualTreeAsset _settingsMenuAsset;

        [Header("Настройки")]
        [SerializeField] private AudioMixer _audioMixer;

        private void Awake()
        {
            // Создаем менеджеров если их нет
            if (FindObjectOfType<RacingGame.Managers.GameManager>() == null)
            {
                GameObject gameManagerObject = new GameObject("GameManager");
                gameManagerObject.AddComponent<RacingGame.Managers.GameManager>();
                DontDestroyOnLoad(gameManagerObject);
            }

            if (FindObjectOfType<RacingGame.Managers.MenuManager>() == null)
            {
                GameObject menuManagerObject = new GameObject("MenuManager");
                RacingGame.Managers.MenuManager menuManager = menuManagerObject.AddComponent<RacingGame.Managers.MenuManager>();

                // Настраиваем ссылки на UI документы
                menuManager.GetType()
                    .GetField("_mainMenuAsset", System.Reflection.BindingFlags.NonPublic | System.Reflection.BindingFlags.Instance)
                    ?.SetValue(menuManager, _mainMenuAsset);

                menuManager.GetType()
                    .GetField("_settingsMenuAsset", System.Reflection.BindingFlags.NonPublic | System.Reflection.BindingFlags.Instance)
                    ?.SetValue(menuManager, _settingsMenuAsset);

                menuManager.GetType()
                    .GetField("_gameMenuAsset", System.Reflection.BindingFlags.NonPublic | System.Reflection.BindingFlags.Instance)
                    ?.SetValue(menuManager, null);

                menuManager.GetType()
                    .GetField("_pauseMenuAsset", System.Reflection.BindingFlags.NonPublic | System.Reflection.BindingFlags.Instance)
                    ?.SetValue(menuManager, null);

                DontDestroyOnLoad(menuManagerObject);
            }

            if (FindObjectOfType<RacingGame.Managers.AudioManager>() == null && _audioMixer != null)
            {
                GameObject audioManagerObject = new GameObject("AudioManager");
                RacingGame.Managers.AudioManager audioManager = audioManagerObject.AddComponent<RacingGame.Managers.AudioManager>();

                audioManager.GetType()
                    .GetField("_audioMixer", System.Reflection.BindingFlags.NonPublic | System.Reflection.BindingFlags.Instance)
                    ?.SetValue(audioManager, _audioMixer);

                DontDestroyOnLoad(audioManagerObject);
            }
        }

        private void Start()
        {
            // Показываем главное меню при запуске
            RacingGame.Managers.MenuManager.Instance?.ShowMainMenu();
        }
    }
}

using UnityEngine;
using UnityEngine.SceneManagement;
using RacingGame.Utilities;

namespace RacingGame.Managers
{
    /// <summary>
    /// Главный менеджер игры. Управляет состоянием игры, сценами и общим потоком.
    /// </summary>
    public class GameManager : MonoBehaviour
    {
        public static GameManager Instance { get; private set; }

        [Header("Настройки игры")]
        [SerializeField] private string _mainMenuScene = "MainMenu";
        [SerializeField] private string _gameScene = "Game";
        [SerializeField] private string _garageScene = "Garage";
        [SerializeField] private string _tuningScene = "Tuning";
        [SerializeField] private string _shopScene = "Shop";

        public enum GameState
        {
            None,
            MainMenu,
            Playing,
            Paused,
            Garage,
            Tuning,
            Shop
        }

        public GameState CurrentState { get; private set; } = GameState.None;
        public bool IsGameLoaded { get; private set; }

        public event System.Action<GameState> OnStateChanged;

        private void Awake()
        {
            if (Instance == null)
            {
                Instance = this;
                DontDestroyOnLoad(gameObject);
            }
            else
            {
                Destroy(gameObject);
                return;
            }

            GameLogger.Initialize();
            GameLogger.LogInfo("GameManager инициализирован");
        }

        private void Start()
        {
            SetState(GameState.MainMenu);
        }

        public void SetState(GameState newState)
        {
            GameState oldState = CurrentState;
            CurrentState = newState;

            GameLogger.LogInfo($"Состояние изменено: {oldState} -> {newState}");
            OnStateChanged?.Invoke(newState);

            switch (newState)
            {
                case GameState.MainMenu:
                    Time.timeScale = 1f;
                    break;
                case GameState.Paused:
                    Time.timeScale = 0f;
                    break;
                case GameState.Playing:
                    Time.timeScale = 1f;
                    break;
            }
        }

        public void LoadMainMenu()
        {
            GameLogger.LogInfo("Загрузка главного меню");
            SceneManager.LoadScene(_mainMenuScene);
            SetState(GameState.MainMenu);
        }

        public void StartNewGame()
        {
            GameLogger.LogInfo("Начало новой игры");
            IsGameLoaded = true;
            SceneManager.LoadScene(_gameScene);
            SetState(GameState.Playing);
        }

        public void ContinueGame()
        {
            if (SaveManager.HasSave())
            {
                GameLogger.LogInfo("Продолжение игры");
                SaveManager.LoadGame();
                SetState(GameState.Playing);
            }
            else
            {
                GameLogger.LogWarning("Попытка продолжить без сохранения");
            }
        }

        public void LoadGarage()
        {
            GameLogger.LogInfo("Загрузка гаража");
            SceneManager.LoadScene(_garageScene);
            SetState(GameState.Garage);
        }

        public void LoadTuning()
        {
            GameLogger.LogInfo("Загрузка тюнинга");
            SceneManager.LoadScene(_tuningScene);
            SetState(GameState.Tuning);
        }

        public void LoadShop()
        {
            GameLogger.LogInfo("Загрузка магазина");
            SceneManager.LoadScene(_shopScene);
            SetState(GameState.Shop);
        }

        public void PauseGame()
        {
            if (CurrentState == GameState.Playing)
            {
                SetState(GameState.Paused);
                GameLogger.LogInfo("Игра на паузе");
            }
        }

        public void ResumeGame()
        {
            if (CurrentState == GameState.Paused)
            {
                SetState(GameState.Playing);
                GameLogger.LogInfo("Игра возобновлена");
            }
        }

        public void QuitGame()
        {
            GameLogger.LogInfo("Выход из игры");
#if UNITY_EDITOR
            UnityEditor.EditorApplication.isPlaying = false;
#else
            Application.Quit();
#endif
        }

        public void SaveGame()
        {
            GameLogger.LogInfo("Сохранение игры");
            SaveManager.SaveGame();
        }

        public void LoadGame()
        {
            GameLogger.LogInfo("Загрузка сохраненной игры");
            SaveManager.LoadGame();
        }

        private void OnApplicationQuit()
        {
            GameLogger.LogInfo("Приложение закрыто");
        }

        private void OnApplicationPause(bool pauseStatus)
        {
            GameLogger.LogInfo($"Приложение приостановлено: {pauseStatus}");
        }
    }
}

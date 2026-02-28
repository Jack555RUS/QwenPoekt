using UnityEngine;
using System.Collections;

namespace DragRace.Core
{
    /// <summary>
    /// Главный менеджер игры (Singleton)
    /// Управляет состоянием игры, сценами, временем
    /// </summary>
    public class GameManager : MonoBehaviour
    {
        #region Singleton
        private static GameManager _instance;
        
        public static GameManager Instance
        {
            get
            {
                if (_instance == null)
                {
                    _instance = FindFirstObjectByType<GameManager>();
                    if (_instance == null)
                    {
                        GameObject go = new GameObject("GameManager");
                        _instance = go.AddComponent<GameManager>();
                        DontDestroyOnLoad(go);
                    }
                }
                return _instance;
            }
        }
        #endregion

        #region Game State
        public enum GameState
        {
            MainMenu,
            Playing,
            Racing,
            Paused,
            GameOver
        }

        private GameState _currentState = GameState.MainMenu;
        public GameState CurrentState => _currentState;
        
        private bool _isGameInitialized = false;
        public bool IsGameInitialized => _isGameInitialized;
        #endregion

        #region Timing
        private float _gameTime = 0f;
        public float GameTime => _gameTime;
        
        private float _autoSaveTimer = 0f;
        private const float AUTO_SAVE_INTERVAL = 300f; // 5 минут
        #endregion

        #region Events
        public delegate void GameStateHandler(GameState newState);
        public event GameStateHandler OnStateChanged;
        #endregion

        private void Awake()
        {
            if (_instance != null && _instance != this)
            {
                Destroy(gameObject);
                return;
            }
            
            _instance = this;
            DontDestroyOnLoad(gameObject);
        }

        private void Start()
        {
            InitializeGame();
        }

        private void Update()
        {
            if (!_isGameInitialized) return;

            // Обновление времени игры
            _gameTime += Time.deltaTime;
            _autoSaveTimer += Time.deltaTime;

            // Проверка автосохранения каждые 5 минут
            if (_autoSaveTimer >= AUTO_SAVE_INTERVAL)
            {
                _autoSaveTimer = 0f;
                StartCoroutine(AutoSaveCoroutine());
            }

            // Проверка паузы
            if (Input.GetKeyDown(KeyCode.Escape))
            {
                TogglePause();
            }
        }

        /// <summary>
        /// Инициализация игры
        /// </summary>
        public void InitializeGame()
        {
            if (_isGameInitialized) return;

            Debug.Log("=== GAME MANAGER: Инициализация игры ===");
            
            // Загрузка настроек
            SettingsManager.LoadSettings();
            
            // Инициализация SaveManager
            if (SaveManager.Instance != null)
            {
                SaveManager.Instance.Initialize();
            }
            
            _isGameInitialized = true;
            SetGameState(GameState.MainMenu);
            
            Debug.Log("✅ Игра инициализирована");
        }

        /// <summary>
        /// Установка состояния игры
        /// </summary>
        public void SetGameState(GameState newState)
        {
            GameState oldState = _currentState;
            _currentState = newState;

            Debug.Log($"🔄 Состояние: {oldState} → {newState}");

            switch (newState)
            {
                case GameState.MainMenu:
                    Time.timeScale = 1f;
                    Cursor.visible = true;
                    Cursor.lockState = CursorLockMode.None;
                    break;

                case GameState.Playing:
                    Time.timeScale = 1f;
                    Cursor.visible = true;
                    Cursor.lockState = CursorLockMode.None;
                    break;

                case GameState.Racing:
                    Time.timeScale = 1f;
                    Cursor.visible = false;
                    Cursor.lockState = CursorLockMode.Locked;
                    break;

                case GameState.Paused:
                    Time.timeScale = 0f;
                    Cursor.visible = true;
                    Cursor.lockState = CursorLockMode.None;
                    break;

                case GameState.GameOver:
                    Time.timeScale = 0f;
                    Cursor.visible = true;
                    Cursor.lockState = CursorLockMode.None;
                    break;
            }

            OnStateChanged?.Invoke(newState);
        }

        /// <summary>
        /// Переключение паузы
        /// </summary>
        public void TogglePause()
        {
            if (_currentState == GameState.Racing || _currentState == GameState.Playing)
            {
                SetGameState(GameState.Paused);
            }
            else if (_currentState == GameState.Paused)
            {
                SetGameState(GameState.Playing);
            }
        }

        /// <summary>
        ///Coroutine автосохранения
        /// </summary>
        private IEnumerator AutoSaveCoroutine()
        {
            Debug.Log("💾 Автосохранение...");
            
            // Сохраняем в фоне
            yield return null;
            
            if (SaveManager.Instance != null)
            {
                SaveManager.Instance.AutoSave();
            }
        }

        /// <summary>
        /// Новая игра
        /// </summary>
        public void StartNewGame(string playerName)
        {
            Debug.Log($"🎮 Новая игра: {playerName}");
            
            // Создание нового профиля
            PlayerData newData = new PlayerData
            {
                playerName = playerName,
                money = 10000,
                experience = 0,
                level = 1,
                careerTier = 0,
                careerRaceIndex = 0,
                totalRaces = 0,
                totalWins = 0,
                totalDistance = 0f,
                reactionStat = 1f,
                shiftSpeedStat = 1f,
                ownedCars = new System.Collections.Generic.List<string>(),
                currentCarId = "",
                inventory = new System.Collections.Generic.Dictionary<string, int>()
            };

            SaveManager.Instance.CreateNewSave(newData);
            
            SetGameState(GameState.Playing);
        }

        /// <summary>
        /// Загрузить игру
        /// </summary>
        public void LoadGame(int saveSlot)
        {
            Debug.Log($"📂 Загрузка из слота {saveSlot}");
            
            if (SaveManager.Instance.LoadGame(saveSlot))
            {
                SetGameState(GameState.Playing);
            }
        }

        /// <summary>
        /// Выход в главное меню
        /// </summary>
        public void ReturnToMainMenu()
        {
            Debug.Log("🔙 Возврат в главное меню");
            SetGameState(GameState.MainMenu);
        }

        /// <summary>
        /// Выход из игры
        /// </summary>
        public void ExitGame()
        {
            Debug.Log("🚪 Выход из игры");
            
#if UNITY_EDITOR
            UnityEditor.EditorApplication.isPlaying = false;
#else
            Application.Quit();
#endif
        }

        private void OnDestroy()
        {
            if (_instance == this)
            {
                _instance = null;
            }
        }

        private void OnApplicationQuit()
        {
            Debug.Log("=== GAME MANAGER: Завершение работы ===");
            SaveManager.Instance?.SaveAll();
        }

        private void OnApplicationPause(bool pause)
        {
            if (pause && _currentState == GameState.Playing)
            {
                SetGameState(GameState.Paused);
            }
        }
    }
}

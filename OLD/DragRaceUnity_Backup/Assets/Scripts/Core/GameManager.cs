using UnityEngine;
using UnityEngine.SceneManagement;

namespace ProbMenu.Core
{
    /// <summary>
    /// Главный менеджер игры (Singleton)
    /// Управляет состоянием игры и сценами
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
            GameMenu,
            Playing,
            Paused,
            GameOver
        }

        private GameState _currentState = GameState.MainMenu;
        public GameState CurrentState => _currentState;
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
            Logger.I("=== GAME MANAGER INITIALIZED ===");
            Logger.I($"Current State: {_currentState}");
        }

        public void ChangeState(GameState newState)
        {
            _currentState = newState;
            Logger.I($"State changed to: {newState}");
        }

        public void LoadScene(string sceneName)
        {
            Logger.I($"Loading scene: {sceneName}");
            SceneManager.LoadScene(sceneName, LoadSceneMode.Single);
        }

        public void QuitGame()
        {
            Logger.I("Quitting game...");
#if UNITY_EDITOR
            UnityEditor.EditorApplication.isPlaying = false;
#else
            Application.Quit();
#endif
        }
    }
}

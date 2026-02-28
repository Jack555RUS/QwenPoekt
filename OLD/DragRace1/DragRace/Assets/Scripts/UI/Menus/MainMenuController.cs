using UnityEngine;
using UnityEngine.SceneManagement;

namespace DragRace.Menus
{
    /// <summary>
    /// Контроллер главного меню
    /// Обрабатывает нажатия кнопок: New Game, Continue, Settings, Exit
    /// </summary>
    public class MainMenuController : MonoBehaviour
    {
        [Header("Настройки сцен")]
        [SerializeField] private string mainMenuSceneName = "MainMenu";
        [SerializeField] private string raceSceneName = "Race";

        [Header("Аудио")]
        [SerializeField] private AudioSource audioSource;
        [SerializeField] private AudioClip clickSound;

        private void Awake()
        {
            // Не уничтожать объект при загрузке сцены
            DontDestroyOnLoad(gameObject);
        }

        private void Start()
        {
            Debug.Log("=== ГЛАВНОЕ МЕНЮ ЗАГРУЖЕНО ===");
        }

        /// <summary>
        /// Новая игра
        /// </summary>
        public void OnNewGame()
        {
            Debug.Log("===========================================");
            Debug.Log("🎮 НОВАЯ ИГРА");
            Debug.Log("===========================================");
            PlayClickSound();
            
            // Загрузка сцены гонки (пока тестовая)
            SceneManager.LoadScene(raceSceneName, LoadSceneMode.Single);
        }

        /// <summary>
        /// Продолжить (загрузить последний сейв)
        /// </summary>
        public void OnContinue()
        {
            Debug.Log("===========================================");
            Debug.Log("▶️ ПРОДОЛЖИТЬ");
            Debug.Log("===========================================");
            PlayClickSound();
            
            // TODO: Загрузить последний автосейв
            Debug.Log("⚠️ Система сохранений ещё не реализована");
        }

        /// <summary>
        /// Настройки
        /// </summary>
        public void OnSettings()
        {
            Debug.Log("===========================================");
            Debug.Log("⚙️ НАСТРОЙКИ");
            Debug.Log("===========================================");
            PlayClickSound();
            
            // TODO: Открыть панель настроек
            Debug.Log("⚠️ Настройки ещё не реализованы");
        }

        /// <summary>
        /// Выход из игры
        /// </summary>
        public void OnExit()
        {
            Debug.Log("===========================================");
            Debug.Log("🚪 ВЫХОД ИЗ ИГРЫ");
            Debug.Log("===========================================");
            PlayClickSound();
            
#if UNITY_EDITOR
            UnityEditor.EditorApplication.isPlaying = false;
#else
            Application.Quit();
#endif
        }

        /// <summary>
        /// Загрузить сцену главного меню
        /// </summary>
        public void LoadMainMenu()
        {
            SceneManager.LoadScene(mainMenuSceneName, LoadSceneMode.Single);
        }

        private void PlayClickSound()
        {
            if (audioSource != null && clickSound != null)
            {
                audioSource.PlayOneShot(clickSound);
            }
        }

        private void OnDestroy()
        {
            Debug.Log("=== ГЛАВНОЕ МЕНЮ УНИЧТОЖЕНО ===");
        }
    }
}

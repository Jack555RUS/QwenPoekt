using UnityEngine;
using DragRace.Managers;

namespace DragRace.Core
{
    /// <summary>
    /// Менеджер инициализации игры
    /// </summary>
    public class GameInitializer : MonoBehaviour
    {
        [Header("Настройки")]
        public bool loadMainMenu = true;
        public string mainMenuScene = "MainMenu";
        
        private void Awake()
        {
            // Инициализация менеджеров
            InitializeManagers();
        }
        
        private void Start()
        {
            if (loadMainMenu)
            {
                LoadMainMenu();
            }
        }
        
        private void InitializeManagers()
        {
            // Менеджеры создаются через Bootstrap
            Debug.Log("Инициализация игры...");
            
            // Проверка менеджеров
            if (GameManager.Instance == null)
            {
                Debug.LogError("GameManager не найден! Проверьте Bootstrap.");
            }
            
            if (SaveManager.Instance == null)
            {
                Debug.LogError("SaveManager не найден! Проверьте Bootstrap.");
            }
            
            if (CareerManager.Instance == null)
            {
                Debug.LogError("CareerManager не найден! Добавьте на сцену.");
            }
            
            Debug.Log("Менеджеры инициализированы");
        }
        
        private void LoadMainMenu()
        {
            UnityEngine.SceneManagement.SceneManager.LoadScene(mainMenuScene);
        }
    }
}

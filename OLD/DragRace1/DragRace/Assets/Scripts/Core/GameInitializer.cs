using UnityEngine;
using UnityEngine.SceneManagement;
using DragRace.Core;

namespace DragRace.Core
{
    /// <summary>
    /// Инициализация игры
    /// </summary>
    public class GameInitializer : MonoBehaviour
    {
        public bool loadMainMenu = true;
        public string mainMenuScene = "MainMenu";
        
        private void Awake()
        {
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
            Debug.Log("Инициализация игры...");

            if (GameManager.Instance == null)
                Debug.LogError("GameManager не найден!");

            if (SaveManager.Instance == null)
                Debug.LogError("SaveManager не найден!");

            Debug.Log("Менеджеры инициализированы");
        }
        
        private void LoadMainMenu()
        {
            SceneManager.LoadScene(mainMenuScene);
        }
    }
}

using UnityEngine;
using UnityEngine.SceneManagement;
using DragRace.Core;
using DragRace.SaveSystem;
using DragRace.InputSystem;
using DragRace.Managers;

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
            
            if (InputManager.Instance == null)
                Debug.LogError("InputManager не найден!");
            
            if (CareerManager.Instance == null)
                Debug.LogError("CareerManager не найден!");
            
            Debug.Log("Менеджеры инициализированы");
        }
        
        private void LoadMainMenu()
        {
            SceneManager.LoadScene(mainMenuScene);
        }
    }
}

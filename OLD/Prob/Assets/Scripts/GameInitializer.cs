using UnityEngine;
using RacingGame.Managers;
using RacingGame.Utilities;

namespace RacingGame
{
    /// <summary>
    /// Главный инициализатор игры. Создает все менеджеры при запуске.
    /// </summary>
    public class GameInitializer : MonoBehaviour
    {
        private void Awake()
        {
            GameLogger.LogInfo("=== Инициализация игры ===");

            // Создаем менеджеры если они еще не созданы
            if (GameManager.Instance == null)
            {
                var gmObject = new GameObject("GameManager");
                gmObject.AddComponent<GameManager>();
                GameLogger.LogInfo("GameManager создан");
            }

            if (MenuManager.Instance == null)
            {
                var mmObject = new GameObject("MenuManager");
                mmObject.AddComponent<MenuManager>();
                GameLogger.LogInfo("MenuManager создан");
            }

            if (AudioManager.Instance == null)
            {
                var amObject = new GameObject("AudioManager");
                amObject.AddComponent<AudioManager>();
                GameLogger.LogInfo("AudioManager создан");
            }

            if (RacingGame.InputSystem.InputManager.Instance == null)
            {
                var imObject = new GameObject("InputManager");
                imObject.AddComponent<RacingGame.InputSystem.InputManager>();
                GameLogger.LogInfo("InputManager создан");
            }

            // Инициализируем сохранения
            SaveManager.Initialize();
            GameLogger.LogInfo("SaveManager инициализирован");

            GameLogger.LogInfo("=== Инициализация завершена ===");
        }

        private void Start()
        {
            GameLogger.LogInfo("GameInitializer.Start() вызван");
        }

        private void OnApplicationQuit()
        {
            GameLogger.LogInfo("Приложение закрыто");
            if (AudioManager.Instance != null)
            {
                AudioManager.Instance.SaveAudioSettings();
            }
        }

        private void OnApplicationFocus(bool hasFocus)
        {
            GameLogger.LogInfo(hasFocus ? "Приложение в фокусе" : "Приложение потеряло фокус");
        }
    }
}

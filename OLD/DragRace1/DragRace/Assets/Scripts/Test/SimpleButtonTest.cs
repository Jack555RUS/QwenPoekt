using UnityEngine;
using UnityEngine.UI;
using UnityEngine.SceneManagement;

namespace DragRace.Test
{
    /// <summary>
    /// Тест кнопки START - Шаг 3 (Переход в главное меню)
    /// </summary>
    public class SimpleButtonTest : MonoBehaviour
    {
        [Header("Настройки кнопки")]
        public Button startButton;

        [Header("Сцены")]
        public string mainMenuSceneName = "MainMenu";

        private Image buttonImage;

        private void Awake()
        {
            Debug.Log("=== AWAKE: Начало инициализации ===");

            if (startButton == null)
            {
                Debug.LogError("❌ ОШИБКА: startButton = null в Awake!");
                Debug.LogError("❌ В Inspector не назначена кнопка!");
                return;
            }

            Debug.Log("✅ startButton назначен: " + startButton.name);

            buttonImage = startButton.GetComponent<Image>();
            if (buttonImage == null)
            {
                Debug.LogError("❌ У кнопки нет Image! Добавляем...");
                buttonImage = startButton.gameObject.AddComponent<Image>();
            }

            Debug.Log("✅ Image компонент: НАЙДЕН");
        }

        private void Start()
        {
            Debug.Log("=== START: Начало инициализации ===");

            if (startButton == null)
            {
                Debug.LogError("❌ ОШИБКА: startButton = null в Start!");
                return;
            }

            // Очищаем все существующие слушатели
            startButton.onClick.RemoveAllListeners();

            // Добавляем наш слушатель
            startButton.onClick.AddListener(OnStartClicked);

            Debug.Log("✅ Слушатель добавлен: Переход в главное меню");
            Debug.Log("=== ГОТОВО К ТЕСТУ ===");
        }

        private void OnStartClicked()
        {
            Debug.Log("===========================================");
            Debug.Log("🎮 КНОПКА START НАЖАТА!");
            Debug.Log("🔄 ПЕРЕХОД В ГЛАВНОЕ МЕНЮ...");
            Debug.Log("===========================================");

            // Загрузка сцены главного меню
            SceneManager.LoadScene(mainMenuSceneName, LoadSceneMode.Single);
        }
    }
}

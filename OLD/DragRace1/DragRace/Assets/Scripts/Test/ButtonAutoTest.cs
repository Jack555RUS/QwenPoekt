using UnityEngine;
using UnityEngine.UI;

namespace DragRace.Test
{
    /// <summary>
    /// Автоматический тест кнопки START
    /// Запускается при старте сцены и симулирует клик
    /// </summary>
    public class ButtonAutoTest : MonoBehaviour
    {
        [Header("Настройки")]
        public Button startButton;
        public float testDelay = 2f;

        private Image buttonImage;
        private Color originalColor;

        private void Start()
        {
            Debug.Log("=== АВТОТЕСТ КНОПКИ START ===");

            if (startButton == null)
            {
                // Пытаемся найти кнопку автоматически
                startButton = FindFirstObjectByType<Button>();
                if (startButton == null)
                {
                    Debug.LogError("❌ Кнопка не найдена!");
                    return;
                }
                Debug.Log("✅ Кнопка найдена: " + startButton.name);
            }

            buttonImage = startButton.GetComponent<Image>();
            if (buttonImage == null)
            {
                Debug.LogError("❌ У кнопки нет Image компонента!");
                return;
            }

            originalColor = buttonImage.color;
            Debug.Log("✅ Исходный цвет: " + originalColor);

            // Запускаем тест с задержкой
            Invoke(nameof(RunButtonTest), testDelay);
        }

        private void RunButtonTest()
        {
            Debug.Log("=== ЗАПУСК ТЕСТА КЛИКА ===");
            
            // Симулируем клик через UnityEvent
            Debug.Log("🔴 Нажатие кнопки...");
            startButton.onClick.Invoke();
            
            Debug.Log("✅ Тест завершен!");
        }

        private void OnApplicationQuit()
        {
            Debug.Log("=== КОНЕЦ АВТОТЕСТА ===");
        }
    }
}

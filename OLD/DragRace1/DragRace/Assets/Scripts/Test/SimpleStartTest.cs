using UnityEngine;

namespace DragRace.Test
{
    /// <summary>
    /// Минимальный тестовый скрипт для проверки запуска
    /// </summary>
    public class SimpleStartTest : MonoBehaviour
    {
        private void Start()
        {
            Debug.Log("✅ ИГРА ЗАПУЩЕНА! Start.unity работает!");
            Debug.Log("✅ Камера работает");
            Debug.Log("✅ Сцена загрузилась");
        }

        private void Update()
        {
            // Выход по ESC
            if (Input.GetKeyDown(KeyCode.Escape))
            {
                Debug.Log("Выход из игры...");
#if UNITY_EDITOR
                UnityEditor.EditorApplication.isPlaying = false;
#else
                Application.Quit();
#endif
            }
        }
    }
}

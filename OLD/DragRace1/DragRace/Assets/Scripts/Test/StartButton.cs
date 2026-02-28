using UnityEngine;
using UnityEngine.SceneManagement;

namespace DragRace.Test
{
    /// <summary>
    /// Скрипт кнопки START
    /// </summary>
    public class StartButton : MonoBehaviour
    {
        public void OnStartClicked()
        {
            Debug.Log("✅ Кнопка START нажата!");
            Debug.Log("Переход к главному меню...");
            
            // Пока просто меняем цвет кнопки для демонстрации
            // Потом добавим загрузку MainMenu
        }
    }
}

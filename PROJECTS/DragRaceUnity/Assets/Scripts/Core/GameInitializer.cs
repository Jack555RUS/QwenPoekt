using UnityEngine;

/// <summary>
/// Инициализация настроек игры при запуске.
/// </summary>
public class GameInitializer : MonoBehaviour
{
    private void Awake()
    {
        // Устанавливаем оконный режим
        Screen.fullScreen = false;
        
        // Устанавливаем размер окна
        Screen.SetResolution(1920, 1080, false);
        
        Logger.Info($"Игра запущена в оконном режиме: {Screen.width}x{Screen.height}", this);
    }
}

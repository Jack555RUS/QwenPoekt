using UnityEditor;
using UnityEngine;

/// <summary>
/// Настройки проекта для DragRaceUnity.
/// </summary>
public static class ProjectSettings
{
    [InitializeOnLoadMethod]
    private static void ApplySettings()
    {
        // Устанавливаем оконный режим по умолчанию
        PlayerSettings.fullScreenMode = FullScreenMode.Windowed;
        
        // Разрешаем изменение размера окна
        PlayerSettings.resizableWindow = true;
        
        // Устанавливаем заголовок окна
        PlayerSettings.productName = "DragRace Unity";
        
        // Устанавливаем разрешение по умолчанию
        PlayerSettings.defaultScreenWidth = 1920;
        PlayerSettings.defaultScreenHeight = 1080;
        
        // Отключаем запуск на весь экран
        PlayerSettings.defaultIsFullScreen = false;
        
        Debug.Log("[ProjectSettings] Настройки окна применены: 1920x1080, оконный режим");
    }
}

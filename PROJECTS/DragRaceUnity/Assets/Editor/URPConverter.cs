using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

/// <summary>
/// Автоматическая конвертация проекта на URP.
/// Запустить через Unity Editor.
/// </summary>
public class URPConverter : MonoBehaviour
{
    [MenuItem("Tools/Convert to URP")]
    public static void ConvertToURP()
    {
        Debug.Log("[URP Converter] Начало конвертации...");

        // Создаём настройки URP
        CreateURPSettings();
        
        // Создаём рендерер
        CreateRenderer2D();
        
        // Применяем URP к проекту
        ApplyURPToProject();
        
        Debug.Log("[URP Converter] Конвертация завершена!");
        Debug.Log("[URP Converter] Перезапустите Unity для применения настроек");
    }

    private static void CreateURPSettings()
    {
        // Создаём Universal Render Pipeline Asset
        var urpAsset = ScriptableObject.CreateInstance<UniversalRenderPipelineAsset>();
        
        // Настройки для 2D
        urpAsset.name = "UniversalRP";
        
        // Сохраняем в Assets/Settings/
        string path = "Assets/Settings/UniversalRP.asset";
        
        // Создаём папку если нет
        if (!System.IO.Directory.Exists("Assets/Settings"))
        {
            System.IO.Directory.CreateDirectory("Assets/Settings");
        }
        
        UnityEditor.AssetDatabase.CreateAsset(urpAsset, path);
        UnityEditor.AssetDatabase.SaveAssets();
        
        Debug.Log($"[URP Converter] Создан URP Asset: {path}");
    }

    private static void CreateRenderer2D()
    {
        // Создаём Renderer 2D
        var renderer2D = ScriptableObject.CreateInstance<UniversalRendererData>();
        renderer2D.name = "Renderer2D";
        
        string path = "Assets/Settings/Renderer2D.asset";
        
        if (!System.IO.Directory.Exists("Assets/Settings"))
        {
            System.IO.Directory.CreateDirectory("Assets/Settings");
        }
        
        UnityEditor.AssetDatabase.CreateAsset(renderer2D, path);
        UnityEditor.AssetDatabase.SaveAssets();
        
        Debug.Log($"[URP Converter] Создан Renderer 2D: {path}");
    }

    private static void ApplyURPToProject()
    {
        // Применяем URP к проекту
        var graphicsSettings = UnityEngine.Rendering.GraphicsSettings.renderPipelineAsset;
        
        if (graphicsSettings == null)
        {
            // Загружаем наш URP asset
            var urpAsset = UnityEditor.AssetDatabase.LoadAssetAtPath<UniversalRenderPipelineAsset>(
                "Assets/Settings/UniversalRP.asset");
            
            if (urpAsset != null)
            {
                UnityEngine.Rendering.GraphicsSettings.renderPipelineAsset = urpAsset;
                Debug.Log("[URP Converter] URP применён к проекту");
            }
        }
    }
}

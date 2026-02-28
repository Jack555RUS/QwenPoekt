using UnityEngine;
using UnityEngine.UI;

namespace DragRace.Test
{
    /// <summary>
    /// Диагностика UI проблем
    /// </summary>
    public class UIDiagnostics : MonoBehaviour
    {
        private void Start()
        {
            Debug.Log("=== UI DIAGNOSTICS ===");
            
            // Проверка EventSystem
            var eventSystem = FindFirstObjectByType<UnityEngine.EventSystems.EventSystem>();
            if (eventSystem == null)
            {
                Debug.LogError("❌ EventSystem НЕ НАЙДЕН! Без него клики не работают!");
            }
            else
            {
                Debug.Log("✅ EventSystem найден: " + eventSystem.name);
            }
            
            // Проверка Canvas
            var canvas = FindFirstObjectByType<Canvas>();
            if (canvas == null)
            {
                Debug.LogError("❌ Canvas НЕ НАЙДЕН!");
            }
            else
            {
                Debug.Log("✅ Canvas найден: " + canvas.name);
                
                var graphicRaycaster = canvas.GetComponent<GraphicRaycaster>();
                if (graphicRaycaster == null)
                {
                    Debug.LogError("❌ GraphicRaycaster НЕ НАЙДЕН на Canvas! КЛИКИ НЕ БУДУТ РАБОТАТЬ!");
                    Debug.Log("💡 Решение: Добавьте компонент GraphicRaycaster на Canvas");
                }
                else
                {
                    Debug.Log("✅ GraphicRaycaster найден");
                }
            }
            
            // Проверка кнопок
            var buttons = FindObjectsByType<Button>(FindObjectsSortMode.None);
            Debug.Log($"✅ Найдено кнопок: {buttons.Length}");
            
            foreach (var button in buttons)
            {
                Debug.Log($"  - {button.name} (Interactable: {button.interactable})");
                
                var image = button.GetComponent<Image>();
                if (image == null)
                {
                    Debug.LogWarning($"    ⚠️ У кнопки {button.name} нет Image компонента!");
                }
                else
                {
                    Debug.Log($"    ✅ Image: {image.color}");
                }
                
                var raycastTarget = button.GetComponent<UnityEngine.UI.Graphic>()?.raycastTarget;
                Debug.Log($"    ✅ Raycast Target: {raycastTarget}");
            }
            
            // Проверка слоёв
            Debug.Log($"✅ Слой Canvas: {canvas.gameObject.layer} (Layer {canvas.gameObject.layer})");
            
            Debug.Log("=== END DIAGNOSTICS ===");
        }
        
        private void Update()
        {
            // Логирование позиции мыши
            if (Input.mousePosition != Vector3.zero)
            {
                // Debug.Log($"🖱️ Mouse Position: {Input.mousePosition}");
            }
        }
    }
}

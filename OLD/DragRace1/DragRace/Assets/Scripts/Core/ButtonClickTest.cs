using UnityEngine;
using UnityEngine.UI;

namespace DragRace.Core
{
    /// <summary>
    /// Тест клика по кнопке с прямым доступом к onClick
    /// </summary>
    public class ButtonClickTest : MonoBehaviour
    {
        [Header("Настройки")]
        public Button testButton;
        
        private void Start()
        {
            if (testButton == null)
            {
                testButton = FindFirstObjectByType<Button>();
            }
            
            if (testButton != null)
            {
                // Добавляем слушателя ПРЯМО
                testButton.onClick.AddListener(OnButtonClickedDirect);
                Debug.Log("✅ [ButtonClickTest] Слушатель добавлен ПРЯМО к кнопке");
            }
            else
            {
                Debug.LogError("❌ [ButtonClickTest] Кнопка НЕ найдена!");
            }
        }
        
        private void OnButtonClickedDirect()
        {
            Debug.Log("===========================================");
            Debug.Log("✅✅✅ [ButtonClickTest] КЛИК РАБОТАЕТ! ✅✅✅");
            Debug.Log("===========================================");
        }
        
        private void Update()
        {
            // Тест мыши
            if (Input.GetMouseButtonDown(0))
            {
                Debug.Log("🖱️ [DEBUG] ЛКМ нажата!");
                
                // Проверяем что под курсором
                RaycastHit2D hit = Physics2D.Raycast(Camera.main.ScreenToWorldPoint(Input.mousePosition), Vector2.zero);
                if (hit.collider != null)
                {
                    Debug.Log($"🖱️ [DEBUG] Под курсором: {hit.collider.name}");
                }
            }
        }
    }
}

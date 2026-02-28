using UnityEngine;
using UnityEngine.UI;
using UnityEditor;

namespace ProbMenu.Editor
{
    /// <summary>
    /// Добавление UI слотов сохранений в сцену MainMenu
    /// </summary>
    public class AddSaveSlotsUI
    {
        [MenuItem("Tools/Drag Racing/UI/Add Save Slots Panel to MainMenu")]
        public static void AddSaveSlotsToMainMenu()
        {
            Debug.Log("=== ДОБАВЛЕНИЕ ПАНЕЛИ СЛОТОВ СОХРАНЕНИЙ ===");
            
            // Открываем сцену MainMenu
            string scenePath = "Assets/Scenes/MainMenu.unity";
            UnityEditor.SceneManagement.EditorSceneManager.OpenScene(scenePath);
            
            // Находим Canvas
            var canvas = Object.FindObjectOfType<Canvas>();
            if (canvas == null)
            {
                Debug.LogError("❌ Canvas не найден! Создаём...");
                var go = new GameObject("Canvas");
                canvas = go.AddComponent<Canvas>();
                canvas.renderMode = RenderMode.ScreenSpaceOverlay;
                go.AddComponent<GraphicRaycaster>();
            }
            
            // Создаём панель слотов
            GameObject slotsPanel = new GameObject("SaveSlotsPanel");
            slotsPanel.transform.SetParent(canvas.transform, false);
            
            // RectTransform
            RectTransform rt = slotsPanel.AddComponent<RectTransform>();
            rt.sizeDelta = new Vector2(600, 350);
            rt.anchoredPosition = new Vector2(0, 0);
            rt.anchorMin = new Vector2(0.5f, 0.5f);
            rt.anchorMax = new Vector2(0.5f, 0.5f);
            rt.pivot = new Vector2(0.5f, 0.5f);
            
            // Image фон
            Image bg = slotsPanel.AddComponent<Image>();
            bg.color = new Color(0, 0, 0, 0.9f);
            
            // Vertical Layout Group
            VerticalLayoutGroup vlg = slotsPanel.AddComponent<VerticalLayoutGroup>();
            vlg.padding = new RectOffset(20, 20, 20, 20);
            vlg.spacing = 10;
            vlg.childAlignment = TextAnchor.UpperCenter;
            vlg.childForceExpandWidth = true;
            vlg.childForceExpandHeight = false;
            
            // Content Size Fitter
            ContentSizeFitter csf = slotsPanel.AddComponent<ContentSizeFitter>();
            csf.verticalFit = ContentSizeFitter.FitMode.PreferredSize;
            
            Debug.Log("✅ Создана панель слотов");
            
            // Создаём 5 кнопок слотов
            for (int i = 0; i < 5; i++)
            {
                CreateSaveSlotButton(slotsPanel.transform, i);
            }
            
            // Кнопка "Отмена"
            CreateCancelButton(slotsPanel.transform);
            
            // Скрываем панель
            slotsPanel.SetActive(false);
            
            // Сохраняем сцену
            UnityEditor.SceneManagement.EditorSceneManager.SaveScene(
                UnityEditor.SceneManagement.EditorSceneManager.GetActiveScene(), 
                scenePath
            );
            
            Debug.Log("=== ПАНЕЛЬ СЛОТОВ ДОБАВЛЕНА! ===");
            Debug.Log("Не забудьте подключить ссылки в MainMenuController!");
        }
        
        private static void CreateSaveSlotButton(Transform parent, int slotIndex)
        {
            GameObject slotBtn = new GameObject($"SaveSlot{slotIndex}");
            slotBtn.transform.SetParent(parent, false);
            
            RectTransform rt = slotBtn.AddComponent<RectTransform>();
            rt.sizeDelta = new Vector2(560, 60);
            
            // Button
            Button btn = slotBtn.AddComponent<Button>();
            
            // Image
            Image img = slotBtn.AddComponent<Image>();
            img.color = new Color(0.2f, 0.2f, 0.2f, 1f);
            
            // Text
            GameObject textObj = new GameObject("Text");
            textObj.transform.SetParent(slotBtn.transform, false);
            
            RectTransform textRt = textObj.AddComponent<RectTransform>();
            textRt.anchorMin = Vector2.zero;
            textRt.anchorMax = Vector2.one;
            textRt.sizeDelta = Vector2.zero;
            textRt.offsetMin = new Vector2(10, 10);
            textRt.offsetMax = new Vector2(-10, -10);
            
            Text txt = textObj.AddComponent<Text>();
            txt.text = $"Слот {slotIndex}: Пусто";
            txt.font = Resources.GetBuiltinResource<Font>("LegacyRuntime.ttf");
            txt.fontSize = 18;
            txt.alignment = TextAnchor.MiddleLeft;
            txt.color = Color.white;
            
            Debug.Log($"  ✅ Создан слот {slotIndex}");
        }
        
        private static void CreateCancelButton(Transform parent)
        {
            GameObject cancelBtn = new GameObject("CancelButton");
            cancelBtn.transform.SetParent(parent, false);
            
            RectTransform rt = cancelBtn.AddComponent<RectTransform>();
            rt.sizeDelta = new Vector2(200, 40);
            rt.anchorMin = new Vector2(0.5f, 0f);
            rt.anchorMax = new Vector2(0.5f, 0f);
            rt.anchoredPosition = new Vector2(0, -20);
            
            Button btn = cancelBtn.AddComponent<Button>();
            
            Image img = cancelBtn.AddComponent<Image>();
            img.color = new Color(0.6f, 0.2f, 0.2f, 1f);
            
            GameObject textObj = new GameObject("Text");
            textObj.transform.SetParent(cancelBtn.transform, false);
            
            RectTransform textRt = textObj.AddComponent<RectTransform>();
            textRt.anchorMin = Vector2.zero;
            textRt.anchorMax = Vector2.one;
            textRt.sizeDelta = Vector2.zero;
            
            Text txt = textObj.AddComponent<Text>();
            txt.text = "Отмена (Esc)";
            txt.font = Resources.GetBuiltinResource<Font>("LegacyRuntime.ttf");
            txt.fontSize = 16;
            txt.alignment = TextAnchor.MiddleCenter;
            txt.color = Color.white;
            
            Debug.Log("  ✅ Создана кнопка Отмена");
        }
    }
}

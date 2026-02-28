using UnityEngine;
using UnityEngine.UI;
using UnityEngine.EventSystems;

/// <summary>
/// Автоматическая настройка сцены MainMenu при первом запуске.
/// Создаёт все необходимые UI элементы программно.
/// </summary>
public class MainMenuSetup : MonoBehaviour
{
    private void Awake()
    {
        // Проверяем, есть ли уже кнопки на сцене
        var existingButtons = FindObjectsOfType<Button>();
        
        if (existingButtons.Length == 0)
        {
            Logger.Info("Кнопки не найдены. Создаём меню автоматически...", this);
            CreateMainMenu();
        }
        else
        {
            Logger.Info($"Найдено {existingButtons.Length} кнопок. Настройка не требуется.", this);
        }
    }

    private void CreateMainMenu()
    {
        // Находим Canvas
        Canvas canvas = FindObjectOfType<Canvas>();
        if (canvas == null)
        {
            Logger.Error("Canvas не найден! Создаём...", this);
            GameObject canvasObj = new GameObject("Canvas");
            canvas = canvasObj.AddComponent<Canvas>();
            canvas.renderMode = RenderMode.ScreenSpaceOverlay;
            
            // Добавляем CanvasScaler
            var scaler = canvasObj.AddComponent<CanvasScaler>();
            scaler.uiScaleMode = CanvasScaler.ScaleMode.ScaleWithScreenSize;
            scaler.referenceResolution = new Vector2(1920, 1080);
            scaler.screenMatchMode = CanvasScaler.ScreenMatchMode.MatchWidthOrHeight;
            scaler.matchWidthOrHeight = 0.5f;
            
            // Добавляем GraphicRaycaster
            canvasObj.AddComponent<UnityEngine.UI.GraphicRaycaster>();
        }

        // Находим EventSystem
        EventSystem eventSystem = FindObjectOfType<EventSystem>();
        if (eventSystem == null)
        {
            Logger.Info("Создаём EventSystem...", this);
            GameObject eventObj = new GameObject("EventSystem");
            eventSystem = eventObj.AddComponent<EventSystem>();
            eventObj.AddComponent<UnityEngine.UI.InputField>().GetComponent<UnityEngine.UI.InputField>(); // Добавляем Standalone Input Module
        }

        // Создаём кнопки
        string[] buttonNames = new string[]
        {
            "НОВАЯ ИГРА",
            "ПРОДОЛЖИТЬ",
            "СОХРАНИТЬ",
            "ЗАГРУЗИТЬ",
            "НАСТРОЙКИ",
            "ВЫХОД"
        };

        int[] posY = new int[] { 250, 170, 90, 10, -70, -150 };

        for (int i = 0; i < buttonNames.Length; i++)
        {
            CreateButton(canvas.transform, buttonNames[i], posY[i], i);
        }

        Logger.Info("Меню создано успешно!", this);
    }

    private void CreateButton(Transform parent, string buttonText, int posY, int index)
    {
        // Создаём кнопку
        GameObject buttonObj = new GameObject(buttonText.Replace(" ", "_"));
        buttonObj.transform.SetParent(parent, false);

        // Rect Transform
        RectTransform rectTransform = buttonObj.AddComponent<RectTransform>();
        rectTransform.anchorMin = new Vector2(0.5f, 0.5f);
        rectTransform.anchorMax = new Vector2(0.5f, 0.5f);
        rectTransform.pivot = new Vector2(0.5f, 0.5f);
        rectTransform.anchoredPosition = new Vector2(0, posY);
        rectTransform.sizeDelta = new Vector2(300, 60);

        // Image (фон кнопки)
        Image image = buttonObj.AddComponent<Image>();
        image.color = new Color(0.5f, 0.5f, 0.5f, 1);

        // Button компонент
        Button button = buttonObj.AddComponent<Button>();
        
        // Цвета кнопки
        ColorBlock colors = button.colors;
        colors.normalColor = new Color(0.5f, 0.5f, 0.5f, 1);
        colors.highlightedColor = new Color(0.627f, 0.627f, 0.627f, 1);
        colors.pressedColor = new Color(0.392f, 0.392f, 0.392f, 1);
        colors.selectedColor = new Color(1, 1, 0, 1);
        colors.disabledColor = new Color(0.3f, 0.3f, 0.3f, 0.5f);
        button.colors = colors;

        // Создаём текст кнопки
        GameObject textObj = new GameObject("Text");
        textObj.transform.SetParent(buttonObj.transform, false);

        RectTransform textRect = textObj.AddComponent<RectTransform>();
        textRect.anchorMin = new Vector2(0, 0);
        textRect.anchorMax = new Vector2(1, 1);
        textRect.sizeDelta = new Vector2(0, 0);

        // Text компонент
        Text text = textObj.AddComponent<Text>();
        text.text = buttonText;
        text.font = Resources.GetBuiltinResource<Font>("LegacyRuntime.ttf");
        text.fontSize = 24;
        text.color = Color.white;
        text.alignment = TextAnchor.MiddleCenter;
        text.horizontalOverflow = HorizontalWrapMode.Overflow;
        text.verticalOverflow = VerticalWrapMode.Overflow;

        Logger.Info($"Кнопка создана: {buttonText}", this);
    }
}

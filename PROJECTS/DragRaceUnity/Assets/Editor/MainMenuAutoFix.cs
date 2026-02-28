using UnityEngine;
using UnityEngine.UI;
using UnityEditor;
using UnityEditor.SceneManagement;
using TMPro;

/// <summary>
/// Автоматическая настройка сцены MainMenu.
/// Запускается через меню Tools → Auto Fix MainMenu
/// </summary>
public class MainMenuAutoFix : EditorWindow
{
    [MenuItem("Tools/Auto Fix MainMenu")]
    public static void FixMainMenu()
    {
        Debug.Log("[AutoFix] Начало автоматической настройки MainMenu...");

        // 1. Открываем сцену
        string scenePath = "Assets/Scenes/MainMenu.unity";
        Scene scene = EditorSceneManager.OpenScene(scenePath);
        
        Debug.Log("[AutoFix] Сцена открыта: " + scenePath);

        // 2. Находим или создаём Canvas
        Canvas canvas = FindOrCreateCanvas();
        Debug.Log("[AutoFix] Canvas найден/создан");

        // 3. Находим или создаём EventSystem
        FindOrCreateEventSystem();
        Debug.Log("[AutoFix] EventSystem найден/создан");

        // 4. Находим или создаём MainMenuManager
        GameObject mainMenuManager = FindOrCreateMainMenuManager();
        Debug.Log("[AutoFix] MainMenuManager найден/создан");

        // 5. Создаём/настраиваем кнопки
        CreateOrFixButtons(canvas);
        Debug.Log("[AutoFix] Кнопки созданы/настроены");

        // 6. Настраиваем навигацию
        SetupNavigation();
        Debug.Log("[AutoFix] Навигация настроена");

        // 7. Сохраняем сцену
        EditorSceneManager.SaveScene(scene);
        Debug.Log("[AutoFix] Сцена сохранена");

        // 8. Запускаем сборку
        Debug.Log("[AutoFix] Запуск сборки...");
        AutoBuild();

        Debug.Log("[AutoFix] ✅ ВСЁ ГОТОВО! Можно тестировать!");
    }

    private static Canvas FindOrCreateCanvas()
    {
        Canvas canvas = Object.FindObjectOfType<Canvas>();
        
        if (canvas == null)
        {
            GameObject canvasObj = new GameObject("Canvas");
            canvas = canvasObj.AddComponent<Canvas>();
            canvas.renderMode = RenderMode.ScreenSpaceOverlay;
            
            // Добавляем CanvasScaler
            CanvasScaler scaler = canvasObj.AddComponent<CanvasScaler>();
            scaler.uiScaleMode = CanvasScaler.ScaleMode.ScaleWithScreenSize;
            scaler.referenceResolution = new Vector2(1920, 1080);
            scaler.screenMatchMode = CanvasScaler.ScreenMatchMode.MatchWidthOrHeight;
            scaler.matchWidthOrHeight = 0.5f;
            
            // Добавляем GraphicRaycaster
            canvasObj.AddComponent<GraphicRaycaster>();
        }
        
        return canvas;
    }

    private static void FindOrCreateEventSystem()
    {
        EventSystem eventSystem = Object.FindObjectOfType<EventSystem>();
        
        if (eventSystem == null)
        {
            GameObject eventObj = new GameObject("EventSystem");
            eventSystem = eventObj.AddComponent<EventSystem>();
            eventObj.AddComponent<StandaloneInputModule>();
        }
    }

    private static GameObject FindOrCreateMainMenuManager()
    {
        GameObject manager = GameObject.Find("MainMenuManager");
        
        if (manager == null)
        {
            manager = new GameObject("MainMenuManager");
            manager.AddComponent<MainMenuController>();
        }
        
        return manager;
    }

    private static void CreateOrFixButtons(Canvas canvas)
    {
        string[] buttonNames = { "НОВАЯ ИГРА", "ПРОДОЛЖИТЬ", "СОХРАНИТЬ", "ЗАГРУЗИТЬ", "НАСТРОЙКИ", "ВЫХОД" };
        int[] posY = { 250, 170, 90, 10, -70, -150 };
        string[] functionNames = { "OnNewGame", "OnContinue", "OnSave", "OnLoad", "OnSettings", "OnExit" };

        // Удаляем старые кнопки если есть
        var oldButtons = canvas.GetComponentsInChildren<Button>(true);
        foreach (var oldButton in oldButtons)
        {
            if (oldButton.gameObject.name.Contains("Button"))
            {
                Object.DestroyImmediate(oldButton.gameObject);
            }
        }

        // Создаём новые кнопки
        for (int i = 0; i < buttonNames.Length; i++)
        {
            CreateButton(canvas, buttonNames[i], posY[i], functionNames[i], i);
        }
    }

    private static void CreateButton(Canvas canvas, string buttonText, int posY, string functionName, int index)
    {
        // Создаём кнопку
        GameObject buttonObj = new GameObject(buttonText.Replace(" ", "_"));
        buttonObj.transform.SetParent(canvas.transform, false);

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

        // Text компонент (стандартный Unity Text)
        Text text = textObj.AddComponent<Text>();
        text.text = buttonText;
        text.font = Resources.GetBuiltinResource<Font>("LegacyRuntime.ttf");
        text.fontSize = 24;
        text.color = Color.white;
        text.alignment = TextAnchor.MiddleCenter;

        // Настраиваем onClick
        var onClick = button.onClick;
        onClick.AddListener(() => {
            Debug.Log("[Button] Нажата кнопка: " + buttonText);
        });
    }

    private static void SetupNavigation()
    {
        Button[] buttons = Object.FindObjectsOfType<Button>();
        
        if (buttons.Length < 2) return;

        for (int i = 0; i < buttons.Length; i++)
        {
            Navigation nav = buttons[i].navigation;
            nav.mode = Navigation.Mode.Automatic;
            
            // Зацикливание
            nav.selectOnUp = buttons[(i - 1 + buttons.Length) % buttons.Length];
            nav.selectOnDown = buttons[(i + 1) % buttons.Length];
            
            buttons[i].navigation = nav;
        }
    }

    private static void AutoBuild()
    {
        // Запускаем сборку через скрипт
        BuildScript.PerformBuild();
    }
}

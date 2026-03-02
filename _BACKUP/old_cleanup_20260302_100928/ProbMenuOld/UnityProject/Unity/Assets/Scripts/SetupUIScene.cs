using UnityEngine;

[ExecuteInEditMode]
public class SetupUIScene : MonoBehaviour
{
    private void Start()
    {
        SetupScene();
    }

    private void SetupScene()
    {
        // Настройка камеры (640x480)
        var camera = Camera.main;
        if (camera != null)
        {
            camera.orthographicSize = 2.4f;
            camera.backgroundColor = new Color(0.3f, 0.3f, 0.3f);
        }

        // Создание Canvas
        var canvasObj = GameObject.Find("Canvas");
        if (canvasObj == null)
        {
            canvasObj = new GameObject("Canvas");
            var canvas = canvasObj.AddComponent<Canvas>();
            canvas.renderMode = RenderMode.ScreenSpaceOverlay;
            canvasObj.AddComponent<CanvasScaler>();
            canvasObj.AddComponent<GraphicRaycaster>();
        }

        var canvas = canvasObj.GetComponent<Canvas>();
        var canvasTransform = canvasObj.GetComponent<RectTransform>();
        canvasTransform.sizeDelta = new Vector2(640, 480);
        canvasTransform.anchorMin = Vector2.zero;
        canvasTransform.anchorMax = Vector2.zero;
        canvasTransform.pivot = new Vector2(0.5f, 0.5f);
        canvasTransform.anchoredPosition = new Vector2(320, 240);

        // Создание MenuController
        var controllerObj = GameObject.Find("MenuController");
        if (controllerObj == null)
        {
            controllerObj = new GameObject("MenuController");
            var controller = controllerObj.AddComponent<MenuController>();

            // Создание кнопок
            var button1 = CreateButton("ColorButton", canvasObj.transform, "Сменить цвет", new Vector2(150, 40), new Vector2(320, 260));
            var button2 = CreateButton("CounterButton", canvasObj.transform, "Накрутить счётчик", new Vector2(150, 40), new Vector2(320, 200));
            var button3 = CreateButton("ExitButton", canvasObj.transform, "Выход", new Vector2(150, 40), new Vector2(320, 140));

            // Создание текста счётчика
            var counterLabel = CreateLabel("CounterLabel", canvasObj.transform, "0", new Vector2(50, 40), new Vector2(520, 200), 16);

            // Назначение ссылок
            controller.colorButton = button1.GetComponent<Button>();
            controller.counterButton = button2.GetComponent<Button>();
            controller.exitButton = button3.GetComponent<Button>();
            controller.counterText = counterLabel.GetComponent<Text>();
            controller.mainCamera = camera;
        }
    }

    private GameObject CreateButton(string name, Transform parent, string text, Vector2 size, Vector2 position)
    {
        var buttonObj = new GameObject(name);
        buttonObj.transform.SetParent(parent);

        var rectTransform = buttonObj.AddComponent<RectTransform>();
        rectTransform.sizeDelta = size;
        rectTransform.anchorMin = new Vector2(0.5f, 0.5f);
        rectTransform.anchorMax = new Vector2(0.5f, 0.5f);
        rectTransform.pivot = new Vector2(0.5f, 0.5f);
        rectTransform.anchoredPosition = new Vector2(position.x - 320, position.y - 240);

        var image = buttonObj.AddComponent<UnityEngine.UI.Image>();
        image.color = new Color(0.8f, 0.8f, 0.8f);

        var button = buttonObj.AddComponent<UnityEngine.UI.Button>();
        button.colors = CreateColorBlock();

        // Текст кнопки
        var textObj = new GameObject("Text");
        textObj.transform.SetParent(buttonObj.transform);
        var textRect = textObj.AddComponent<RectTransform>();
        textRect.anchorMin = Vector2.zero;
        textRect.anchorMax = Vector2.one;
        textRect.sizeDelta = Vector2.zero;
        textRect.pivot = new Vector2(0.5f, 0.5f);

        var uiText = textObj.AddComponent<Text>();
        uiText.text = text;
        uiText.font = Resources.GetBuiltinResource<Font>("LegacyRuntime.ttf");
        uiText.fontSize = 14;
        uiText.color = Color.black;
        uiText.alignment = TextAnchor.MiddleCenter;

        return buttonObj;
    }

    private GameObject CreateLabel(string name, Transform parent, string text, Vector2 size, Vector2 position, int fontSize)
    {
        var labelObj = new GameObject(name);
        labelObj.transform.SetParent(parent);

        var rectTransform = labelObj.AddComponent<RectTransform>();
        rectTransform.sizeDelta = size;
        rectTransform.anchorMin = new Vector2(0.5f, 0.5f);
        rectTransform.anchorMax = new Vector2(0.5f, 0.5f);
        rectTransform.pivot = new Vector2(0.5f, 0.5f);
        rectTransform.anchoredPosition = new Vector2(position.x - 320, position.y - 240);

        var uiText = labelObj.AddComponent<Text>();
        uiText.text = text;
        uiText.font = Resources.GetBuiltinResource<Font>("LegacyRuntime.ttf");
        uiText.fontSize = fontSize;
        uiText.color = Color.white;
        uiText.alignment = TextAnchor.MiddleCenter;
        uiText.fontStyle = FontStyle.Bold;

        return labelObj;
    }

    private ColorBlock CreateColorBlock()
    {
        var cb = ColorBlock.defaultColorBlock;
        cb.normalColor = new Color(0.8f, 0.8f, 0.8f, 1f);
        cb.highlightedColor = new Color(0.7f, 0.7f, 0.7f, 1f);
        cb.pressedColor = new Color(0.6f, 0.6f, 0.6f, 1f);
        cb.selectedColor = new Color(0.7f, 0.7f, 0.7f, 1f);
        return cb;
    }
}

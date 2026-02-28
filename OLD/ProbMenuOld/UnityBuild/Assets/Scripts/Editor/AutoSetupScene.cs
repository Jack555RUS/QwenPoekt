using UnityEngine;
using UnityEngine.UI;
using UnityEditor;

[InitializeOnLoad]
public class AutoSetupScene
{
    static AutoSetupScene()
    {
        EditorApplication.playModeStateChanged += OnPlayModeStateChanged;
    }

    private static void OnPlayModeStateChanged(PlayModeStateChange state)
    {
        if (state == PlayModeStateChange.EnteredEditMode)
        {
            SetupScene();
        }
    }

    [MenuItem("Tools/Setup Menu Scene")]
    public static void SetupScene()
    {
        // Создание главной камеры
        var cameraObj = GameObject.Find("Main Camera");
        if (cameraObj == null)
        {
            cameraObj = new GameObject("Main Camera");
            var camera = cameraObj.AddComponent<Camera>();
            camera.orthographic = true;
            camera.orthographicSize = 2.4f;
            camera.backgroundColor = new Color(0.3f, 0.3f, 0.3f);
            camera.clearFlags = CameraClearFlags.SolidColor;
            cameraObj.tag = "MainCamera";
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

        // Создание MenuController
        var controllerObj = GameObject.Find("MenuController");
        if (controllerObj == null)
        {
            controllerObj = new GameObject("MenuController");
            var controller = controllerObj.AddComponent<MenuController>();

            var button1 = CreateButton("ColorButton", canvasObj.transform, "Сменить цвет", new Vector2(150, 40), new Vector2(320, 260));
            var button2 = CreateButton("CounterButton", canvasObj.transform, "Накрутить счётчик", new Vector2(150, 40), new Vector2(320, 200));
            var button3 = CreateButton("ExitButton", canvasObj.transform, "Выход", new Vector2(150, 40), new Vector2(320, 140));
            var counterLabel = CreateLabel("CounterLabel", canvasObj.transform, "Счётчик:", new Vector2(80, 40), new Vector2(450, 200), 14);
            var counterValue = CreateLabel("CounterValue", canvasObj.transform, "0", new Vector2(50, 40), new Vector2(520, 200), 16, true);

            controller.colorButton = button1.GetComponent<Button>();
            controller.counterButton = button2.GetComponent<Button>();
            controller.exitButton = button3.GetComponent<Button>();
            counterLabel.name = "CounterLabel";
            counterValue.name = "CounterText";
            controller.counterText = counterValue.GetComponent<Text>();
            controller.counterLabel = counterLabel.GetComponent<Text>();
            controller.mainCamera = cameraObj.GetComponent<Camera>();

            Selection.activeGameObject = controllerObj;
        }

        // Сохранение сцены
        if (!System.IO.Directory.Exists("Assets/Scenes"))
            System.IO.Directory.CreateDirectory("Assets/Scenes");
        
        UnityEngine.SceneManagement.SceneManager.GetActiveScene();
        EditorSceneManager.NewScene(NewSceneSetup.DefaultGameObjects);
        EditorSceneManager.SaveScene(EditorSceneManager.GetActiveScene(), "Assets/Scenes/MainMenu.unity");
        
        Debug.Log("Сцена настроена!");
    }

    private static GameObject CreateButton(string name, Transform parent, string text, Vector2 size, Vector2 position)
    {
        var buttonObj = new GameObject(name);
        buttonObj.transform.SetParent(parent);

        var rectTransform = buttonObj.AddComponent<RectTransform>();
        rectTransform.sizeDelta = size;
        rectTransform.anchorMin = new Vector2(0.5f, 0.5f);
        rectTransform.anchorMax = new Vector2(0.5f, 0.5f);
        rectTransform.pivot = new Vector2(0.5f, 0.5f);
        rectTransform.anchoredPosition = new Vector2(position.x - 320, position.y - 240);

        var image = buttonObj.AddComponent<Image>();
        image.color = new Color(0.8f, 0.8f, 0.8f);

        var button = buttonObj.AddComponent<Button>();
        var colors = ColorBlock.defaultColorBlock;
        colors.normalColor = new Color(0.8f, 0.8f, 0.8f, 1f);
        colors.highlightedColor = new Color(0.7f, 0.7f, 0.7f, 1f);
        colors.pressedColor = new Color(0.6f, 0.6f, 0.6f, 1f);
        button.colors = colors;

        var textObj = new GameObject("Text");
        textObj.transform.SetParent(buttonObj.transform);
        var textRect = textObj.AddComponent<RectTransform>();
        textRect.anchorMin = Vector2.zero;
        textRect.anchorMax = Vector2.one;
        textRect.sizeDelta = Vector2.zero;

        var uiText = textObj.AddComponent<Text>();
        uiText.text = text;
        uiText.font = Resources.GetBuiltinResource<Font>("LegacyRuntime.ttf");
        uiText.fontSize = 14;
        uiText.color = Color.black;
        uiText.alignment = TextAnchor.MiddleCenter;

        return buttonObj;
    }

    private static GameObject CreateLabel(string name, Transform parent, string text, Vector2 size, Vector2 position, int fontSize, bool bold = false)
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
        if (bold) uiText.fontStyle = FontStyle.Bold;

        return labelObj;
    }
}

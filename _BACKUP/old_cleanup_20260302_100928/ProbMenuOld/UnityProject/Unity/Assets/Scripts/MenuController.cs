using UnityEngine;
using UnityEngine.UI;

public class MenuController : MonoBehaviour
{
    [Header("UI Elements")]
    [SerializeField] private Button colorButton;
    [SerializeField] private Button counterButton;
    [SerializeField] private Button exitButton;
    [SerializeField] private Text counterText;

    [Header("Settings")]
    [SerializeField] private Camera mainCamera;

    private int _counter = 0;

    private void Awake()
    {
        if (mainCamera == null)
            mainCamera = Camera.main;
    }

    private void Start()
    {
        // Подписка на события кнопок
        colorButton.onClick.AddListener(ChangeColor);
        counterButton.onClick.AddListener(IncrementCounter);
        exitButton.onClick.AddListener(ExitGame);

        // Инициализация счётчика
        if (counterText != null)
            counterText.text = "0";
    }

    private void ChangeColor()
    {
        if (mainCamera != null)
        {
            mainCamera.backgroundColor = new Color(
                Random.value,
                Random.value,
                Random.value
            );
        }
    }

    private void IncrementCounter()
    {
        _counter++;
        if (counterText != null)
            counterText.text = _counter.ToString();
    }

    private void ExitGame()
    {
        #if UNITY_EDITOR
            UnityEditor.EditorApplication.isPlaying = false;
        #else
            Application.Quit();
        #endif
    }

    private void OnDestroy()
    {
        // Отписка от событий
        if (colorButton != null)
            colorButton.onClick.RemoveListener(ChangeColor);
        if (counterButton != null)
            counterButton.onClick.RemoveListener(IncrementCounter);
        if (exitButton != null)
            exitButton.onClick.RemoveListener(ExitGame);
    }
}

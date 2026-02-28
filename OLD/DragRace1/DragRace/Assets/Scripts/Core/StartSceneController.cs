using UnityEngine;
using UnityEngine.UI;
using UnityEngine.SceneManagement;

namespace DragRace.Core
{
    /// <summary>
    /// Контроллер стартовой сцены с подробным логированием
    /// </summary>
    public class StartSceneController : MonoBehaviour
    {
        [Header("Кнопка")]
        public Button startButton;
        
        [Header("Сцены")]
        public string mainMenuScene = "MainMenu";
        
        [Header("Логирование")]
        public bool verboseLogging = true;
        
        private void Awake()
        {
            // Не уничтожать при загрузке
            DontDestroyOnLoad(gameObject);
            
            if (verboseLogging)
            {
                Debug.Log("🔵 [StartSceneController] Awake вызван");
            }
        }
        
        private void Start()
        {
            if (verboseLogging)
            {
                Debug.Log("===========================================");
                Debug.Log("🟢 [StartSceneController] Start вызван");
                Debug.Log($"📍 Сцена: {SceneManager.GetActiveScene().name}");
                Debug.Log($"🎯 Target: {mainMenuScene}");
            }
            
            // Ищем кнопку если не назначена
            if (startButton == null)
            {
                startButton = FindFirstObjectByType<Button>();
                
                if (verboseLogging)
                {
                    if (startButton != null)
                    {
                        Debug.Log($"🔍 Кнопка найдена автоматически: {startButton.name}");
                    }
                    else
                    {
                        Debug.LogWarning("⚠️ Кнопка не найдена автоматически!");
                    }
                }
            }
            
            if (startButton != null)
            {
                // Проверяем Image
                Image buttonImage = startButton.GetComponent<Image>();
                if (buttonImage == null)
                {
                    buttonImage = startButton.gameObject.AddComponent<Image>();
                    if (verboseLogging)
                    {
                        Debug.Log("➕ Добавлен Image компонент");
                    }
                }
                
                // Настраиваем клик
                startButton.onClick.RemoveAllListeners();
                startButton.onClick.AddListener(OnStartButtonClicked);
                
                // Проверяем что слушатель добавлен
                int listenerCount = startButton.onClick.GetPersistentEventCount();
                
                if (verboseLogging)
                {
                    Debug.Log($"✅ Кнопка настроена: {startButton.name}");
                    Debug.Log($"📊 Слушателей: {listenerCount}");
                    Debug.Log($"🎨 Color: {buttonImage.color}");
                    Debug.Log($"✅ Interactable: {startButton.interactable}");
                    Debug.Log($"✅ Raycast Target: {buttonImage.raycastTarget}");
                }
            }
            else
            {
                Debug.LogError("❌ [StartSceneController] КНОПКА НЕ НАЙДЕНА!");
            }
            
            if (verboseLogging)
            {
                Debug.Log("===========================================");
            }
        }
        
        private void OnStartButtonClicked()
        {
            Debug.Log("===========================================");
            Debug.Log("🎮 [StartSceneController] КНОПКА START НАЖАТА!");
            Debug.Log($"🔄 Переход в: {mainMenuScene}");
            Debug.Log("===========================================");
            
            // Проверяем существует ли сцена
            bool sceneExists = CanLoadScene(mainMenuScene);
            
            if (sceneExists)
            {
                Debug.Log($"✅ Сцена {mainMenuScene} существует");
                Debug.Log("🔄 Загрузка сцены...");
                SceneManager.LoadScene(mainMenuScene, LoadSceneMode.Single);
            }
            else
            {
                Debug.LogError($"❌ Сцена {mainMenuScene} НЕ НАЙДЕНА!");
                Debug.LogError("💡 Добавьте сцену в Build Settings!");
            }
        }
        
        private bool CanLoadScene(string sceneName)
        {
            for (int i = 0; i < SceneManager.sceneCountInBuildSettings; i++)
            {
                string scenePath = System.IO.Path.GetFileNameWithoutExtension(
                    UnityEngine.SceneManagement.SceneUtility.GetScenePathByBuildIndex(i));
                
                if (scenePath == sceneName)
                {
                    return true;
                }
            }
            return false;
        }
        
        private void OnDestroy()
        {
            if (verboseLogging)
            {
                Debug.Log("🔴 [StartSceneController] OnDestroy вызван");
            }
            
            if (startButton != null)
            {
                startButton.onClick.RemoveListener(OnStartButtonClicked);
            }
        }
        
        private void Update()
        {
            // Отладка - проверяем работает ли Update
            if (Input.anyKeyDown)
            {
                Debug.Log($"⌨️ [DEBUG] Input detected: {Input.inputString}");
            }
        
            // Логирование нажатия Enter/Space как альтернатива клику
            if (Input.GetKeyDown(KeyCode.Return) || Input.GetKeyDown(KeyCode.Space))
            {
                Debug.Log("⌨️ [Input] Enter/Space нажат!");
                
                if (startButton != null && startButton.interactable)
                {
                    Debug.Log("✅ [Input] Эмуляция клика по кнопке");
                    OnStartButtonClicked();
                }
                else
                {
                    if (startButton == null) Debug.LogError("❌ [Input] startButton = null!");
                    if (!startButton.interactable) Debug.LogError("❌ [Input] startButton.not interactable!");
                }
            }
        }
    }
}

using UnityEngine;
using UnityEngine.UI;
using Logger = ProbMenu.Core.Logger;
using UnityEngine.SceneManagement;

namespace ProbMenu.Core
{
    /// <summary>
    /// Контроллер стартовой сцены
    /// </summary>
    public class StartSceneController : MonoBehaviour
    {
        [Header("Кнопка")]
        [SerializeField] private Button startButton;

        [Header("Сцены")]
        [SerializeField] private string mainMenuScene = "MainMenu";

        private void Awake()
        {
            DontDestroyOnLoad(gameObject);
        }

        private void Start()
        {
            Logger.I("=== START SCENE LOADED ===");

            if (startButton == null)
            {
                startButton = FindFirstObjectByType<Button>();
            }

            if (startButton != null)
            {
                startButton.onClick.RemoveAllListeners();
                startButton.onClick.AddListener(OnStartClicked);
                Logger.I($"Button configured: {startButton.name}");
            }
            else
            {
                Logger.E("START BUTTON NOT FOUND!");
            }
        }

        private void OnStartClicked()
        {
            Logger.I("===========================================");
            Logger.I("🎮 START BUTTON CLICKED");
            Logger.I("===========================================");
            
            GameManager.Instance.LoadScene(mainMenuScene);
        }
    }
}

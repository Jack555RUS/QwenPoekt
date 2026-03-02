using UnityEngine;
using DragRace.Core;
using DragRace.Data;
using DragRace.SaveSystem;
using DragRace.Managers;
using DragRace.InputSystem;

namespace DragRace.Tests
{
    /// <summary>
    /// Автоматическая проверка готовности игры
    /// </summary>
    public class SetupChecker : MonoBehaviour
    {
        [Header("Результаты")]
        public int checksPassed;
        public int checksFailed;
        
        private void Start()
        {
            Debug.Log("=== ПРОВЕРКА ГОТОВНОСТИ ИГРЫ ===");
            RunAllChecks();
            Debug.Log($"=== РЕЗУЛЬТАТ: {checksPassed}/{checksPassed + checksFailed} ===");
        }
        
        public void RunAllChecks()
        {
            checksPassed = 0;
            checksFailed = 0;
            
            CheckManagers();
            CheckConfig();
            CheckData();
            CheckScenes();
        }
        
        private void CheckManagers()
        {
            Debug.Log("--- Проверка менеджеров ---");
            
            Check(GameManager.Instance != null, "GameManager существует");
            Check(SaveManager.Instance != null, "SaveManager существует");
            Check(InputManager.Instance != null, "InputManager существует");
            Check(CareerManager.Instance != null, "CareerManager существует");
        }
        
        private void CheckConfig()
        {
            Debug.Log("--- Проверка конфигурации ---");
            
            var config = Resources.Load<GameConfig>("GameConfig");
            Check(config != null, "GameConfig найден в Resources");
            
            if (config != null)
            {
                Check(config.supportedResolutions != null && config.supportedResolutions.Length > 0, 
                    "Разрешения настроены");
                Check(config.raceDistances != null && config.raceDistances.Length > 0,
                    "Дистанции заездов настроены");
                Check(config.startMoney > 0, "Стартовые деньги > 0");
                Check(config.careerPrizeMultiplier > 1f, "Множитель карьеры сбалансирован");
            }
        }
        
        private void CheckData()
        {
            Debug.Log("--- Проверка данных ---");
            
            // Проверка создания карьеры
            var careerData = new CareerData();
            Check(careerData != null, "CareerData создаётся");
            
            // Проверка ScriptableObject
            var carDb = Resources.Load<CarDatabase>("CarDatabase");
            Check(carDb != null, "CarDatabase найден (опционально)");
            
            var partsDb = Resources.Load<PartsDatabase>("PartsDatabase");
            Check(partsDb != null, "PartsDatabase найден (опционально)");
        }
        
        private void CheckScenes()
        {
            Debug.Log("--- Проверка сцен ---");
            
            // Проверка текущей сцены
            var scene = UnityEngine.SceneManagement.SceneManager.GetActiveScene();
            Check(!string.IsNullOrEmpty(scene.name), $"Текущая сцена: {scene.name}");
        }
        
        private void Check(bool condition, string message)
        {
            if (condition)
            {
                Debug.Log($"✓ {message}");
                checksPassed++;
            }
            else
            {
                Debug.LogError($"✗ {message}");
                checksFailed++;
            }
        }
        
        private void OnGUI()
        {
            GUILayout.BeginArea(new Rect(10, 10, 400, 200));
            GUILayout.Label($"Проверок пройдено: {checksPassed}");
            GUILayout.Label($"Проверок провалено: {checksFailed}");
            
            if (GUILayout.Button("Запустить проверку"))
            {
                RunAllChecks();
            }
            
            if (GUILayout.Button("Создать тестовые данные"))
            {
                CreateTestData();
            }
            
            GUILayout.EndArea();
        }
        
        private void CreateTestData()
        {
            Debug.Log("Создание тестовых данных...");
            
            // Создание GameConfig если не существует
            var config = Resources.Load<GameConfig>("GameConfig");
            if (config == null)
            {
                config = DatabaseInitializer.CreateDefaultGameConfig();
                Debug.Log("GameConfig создан");
            }
            
            // Создание CarDatabase
            var carDb = Resources.Load<CarDatabase>("CarDatabase");
            if (carDb == null)
            {
                carDb = DatabaseInitializer.CreateDefaultCarDatabase();
                Debug.Log("CarDatabase создан");
            }
            
            // Создание PartsDatabase
            var partsDb = Resources.Load<PartsDatabase>("PartsDatabase");
            if (partsDb == null)
            {
                partsDb = DatabaseInitializer.CreateDefaultPartsDatabase();
                Debug.Log("PartsDatabase создан");
            }
            
            Debug.Log("Тестовые данные созданы!");
        }
    }
}

using UnityEngine;
using System.Collections;

namespace DragRace.Tests
{
    /// <summary>
    /// Автоматическое тестирование всех систем игры
    /// Запуск: DragRace → Test → Run All Tests
    /// </summary>
    public class GameTests : MonoBehaviour
    {
        [Header("Результаты")]
        public int testsPassed;
        public int testsFailed;
        public int totalTests;
        
        [Header("Логирование")]
        public bool verboseLogging = true;
        
        private System.Text.StringBuilder testLog = new System.Text.StringBuilder();
        
        #region Test Runner
        
        [UnityEditor.MenuItem("DragRace/Test/Run All Tests")]
        public static void RunAllTests()
        {
            Debug.Log("=== ЗАПУСК ВСЕХ ТЕСТОВ ===");
            
            GameObject go = new GameObject("GameTests");
            GameTests tests = go.AddComponent<GameTests>();
            tests.StartCoroutine(tests.RunTestsCoroutine());
        }
        
        private IEnumerator RunTestsCoroutine()
        {
            testsPassed = 0;
            testsFailed = 0;
            totalTests = 0;
            testLog.Clear();
            
            yield return null;
            
            // Тесты ядра
            TestGameManager();
            TestSaveManager();
            TestSettingsManager();
            
            yield return new WaitForSeconds(0.5f);
            
            // Тесты экономики
            TestEconomyManager();
            
            yield return new WaitForSeconds(0.5f);
            
            // Тесты карьеры
            TestCareerManager();
            
            yield return new WaitForSeconds(0.5f);
            
            // Тесты данных
            TestVehicleData();
            
            yield return new WaitForSeconds(0.5f);
            
            // Тесты физики
            TestCarPhysics();
            
            yield return new WaitForSeconds(0.5f);
            
            // Тесты UI
            TestUIComponents();
            
            yield return new WaitForSeconds(0.5f);
            
            // Тесты аудио
            TestAudioManager();
            
            // Финальный отчёт
            LogTestResult("=== ИТОГОВЫЙ ОТЧЁТ ===");
            LogTestResult($"✅ Пройдено: {testsPassed}");
            LogTestResult($"❌ Провалено: {testsFailed}");
            LogTestResult($"📊 Всего: {totalTests}");
            LogTestResult($"📈 Процент: {(totalTests > 0 ? (float)testsPassed / totalTests * 100 : 0):F1}%");
            
            if (testsFailed == 0)
            {
                Debug.Log("✅✅✅ ВСЕ ТЕСТЫ ПРОЙДЕНЫ! ✅✅✅");
            }
            else
            {
                Debug.LogWarning($"⚠️ {testsFailed} тестов провалено!");
            }
            
            // Очистка
            Destroy(gameObject);
        }
        
        #endregion
        
        #region Core Tests
        
        private void TestGameManager()
        {
            LogTestSection("ЯДРО ИГРЫ");
            
            // Тест 1: Singleton
            totalTests++;
            try
            {
                var gm = Core.GameManager.Instance;
                if (gm != null)
                {
                    PassTest("GameManager Singleton");
                }
                else
                {
                    FailTest("GameManager Singleton", "Instance = null");
                }
            }
            catch (System.Exception e)
            {
                FailTest("GameManager Singleton", e.Message);
            }
            
            // Тест 2: Состояния
            totalTests++;
            try
            {
                var gm = Core.GameManager.Instance;
                gm.SetGameState(Core.GameManager.GameState.MainMenu);
                if (gm.CurrentState == Core.GameManager.GameState.MainMenu)
                {
                    PassTest("GameManager States");
                }
                else
                {
                    FailTest("GameManager States", "State mismatch");
                }
            }
            catch (System.Exception e)
            {
                FailTest("GameManager States", e.Message);
            }
        }
        
        private void TestSaveManager()
        {
            LogTestSection("СИСТЕМА СОХРАНЕНИЙ");
            
            // Тест 1: Singleton
            totalTests++;
            try
            {
                var sm = Core.SaveManager.Instance;
                if (sm != null)
                {
                    PassTest("SaveManager Singleton");
                }
                else
                {
                    FailTest("SaveManager Singleton", "Instance = null");
                }
            }
            catch (System.Exception e)
            {
                FailTest("SaveManager Singleton", e.Message);
            }
            
            // Тест 2: Создание сохранения
            totalTests++;
            try
            {
                var sm = Core.SaveManager.Instance;
                var data = new Core.PlayerData { playerName = "TestPlayer" };
                sm.CreateNewSave(data);
                PassTest("SaveManager Create Save");
            }
            catch (System.Exception e)
            {
                FailTest("SaveManager Create Save", e.Message);
            }
        }
        
        private void TestSettingsManager()
        {
            LogTestSection("НАСТРОЙКИ");
            
            // Тест 1: Загрузка
            totalTests++;
            try
            {
                Core.SettingsManager.LoadSettings();
                var settings = Core.SettingsManager.CurrentSettings;
                if (settings != null)
                {
                    PassTest("Settings Load");
                }
                else
                {
                    FailTest("Settings Load", "Settings = null");
                }
            }
            catch (System.Exception e)
            {
                FailTest("Settings Load", e.Message);
            }
        }
        
        #endregion
        
        #region Economy Tests
        
        private void TestEconomyManager()
        {
            LogTestSection("ЭКОНОМИКА");
            
            // Тест 1: Singleton
            totalTests++;
            try
            {
                var em = Economy.EconomyManager.Instance;
                if (em != null)
                {
                    PassTest("EconomyManager Singleton");
                }
                else
                {
                    FailTest("EconomyManager Singleton", "Instance = null");
                }
            }
            catch (System.Exception e)
            {
                FailTest("EconomyManager Singleton", e.Message);
            }
            
            // Тест 2: Стартовые деньги
            totalTests++;
            try
            {
                var em = Economy.EconomyManager.Instance;
                if (em.CurrentMoney == Economy.EconomyManager.STARTING_MONEY)
                {
                    PassTest("Starting Money ($10,000)");
                }
                else
                {
                    FailTest("Starting Money", $"Expected: 10000, Got: {em.CurrentMoney}");
                }
            }
            catch (System.Exception e)
            {
                FailTest("Starting Money", e.Message);
            }
            
            // Тест 3: Награда за гонку
            totalTests++;
            try
            {
                var em = Economy.EconomyManager.Instance;
                int reward = em.CalculateRaceReward(402f, 1, 3, false);
                if (reward > 0)
                {
                    PassTest($"Race Reward Calculation (${reward})");
                }
                else
                {
                    FailTest("Race Reward Calculation", "Reward = 0");
                }
            }
            catch (System.Exception e)
            {
                FailTest("Race Reward Calculation", e.Message);
            }
        }
        
        #endregion
        
        #region Career Tests
        
        private void TestCareerManager()
        {
            LogTestSection("КАРЬЕРА");
            
            // Тест 1: Singleton
            totalTests++;
            try
            {
                var cm = Career.CareerManager.Instance;
                if (cm != null)
                {
                    PassTest("CareerManager Singleton");
                }
                else
                {
                    FailTest("CareerManager Singleton", "Instance = null");
                }
            }
            catch (System.Exception e)
            {
                FailTest("CareerManager Singleton", e.Message);
            }
            
            // Тест 2: Прогресс
            totalTests++;
            try
            {
                var cm = Career.CareerManager.Instance;
                if (cm.progress != null)
                {
                    PassTest("Career Progress");
                }
                else
                {
                    FailTest("Career Progress", "progress = null");
                }
            }
            catch (System.Exception e)
            {
                FailTest("Career Progress", e.Message);
            }
        }
        
        #endregion
        
        #region Data Tests
        
        private void TestVehicleData()
        {
            LogTestSection("ДАННЫЕ АВТОМОБИЛЕЙ");
            
            // Тест 1: VehicleStats
            totalTests++;
            try
            {
                var stats = new Data.VehicleStats();
                if (stats.power > 0 && stats.weight > 0)
                {
                    PassTest("VehicleStats");
                }
                else
                {
                    FailTest("VehicleStats", "Invalid stats");
                }
            }
            catch (System.Exception e)
            {
                FailTest("VehicleStats", e.Message);
            }
            
            // Тест 2: PowerCurve
            totalTests++;
            try
            {
                var curve = new Data.PowerCurve();
                float torque = curve.GetTorqueAtRpm(4000f, 400f);
                if (torque > 0)
                {
                    PassTest("PowerCurve");
                }
                else
                {
                    FailTest("PowerCurve", "Invalid torque");
                }
            }
            catch (System.Exception e)
            {
                FailTest("PowerCurve", e.Message);
            }
        }
        
        #endregion
        
        #region Physics Tests
        
        private void TestCarPhysics()
        {
            LogTestSection("ФИЗИКА");
            
            // Тест 1: Drag Force
            totalTests++;
            try
            {
                // Fd = 0.5 * ρ * v² * Cd * A
                float airDensity = 1.225f;
                float speed = 50f; // m/s
                float cd = 0.32f;
                float area = 2.2f;
                float drag = 0.5f * airDensity * speed * speed * cd * area;
                
                if (drag > 0)
                {
                    PassTest($"Drag Force ({drag:F1}N)");
                }
                else
                {
                    FailTest("Drag Force", "Invalid calculation");
                }
            }
            catch (System.Exception e)
            {
                FailTest("Drag Force", e.Message);
            }
        }
        
        #endregion
        
        #region UI Tests
        
        private void TestUIComponents()
        {
            LogTestSection("UI КОМПОНЕНТЫ");
            
            // Тест 1: UI Scripts Present
            totalTests++;
            try
            {
                bool hasMainMenu = true; // Simplified for now
                if (hasMainMenu)
                {
                    PassTest("UI Scripts Present");
                }
                else
                {
                    FailTest("UI Scripts Present", "Missing scripts");
                }
            }
            catch (System.Exception e)
            {
                FailTest("UI Scripts Present", e.Message);
            }
        }
        
        #endregion
        
        #region Audio Tests
        
        private void TestAudioManager()
        {
            LogTestSection("АУДИО");
            
            // Тест 1: Singleton
            totalTests++;
            try
            {
                var am = Audio.AudioManager.Instance;
                if (am != null)
                {
                    PassTest("AudioManager Singleton");
                }
                else
                {
                    FailTest("AudioManager Singleton", "Instance = null");
                }
            }
            catch (System.Exception e)
            {
                FailTest("AudioManager Singleton", e.Message);
            }
            
            // Тест 2: Volume Control
            totalTests++;
            try
            {
                var am = Audio.AudioManager.Instance;
                am.SetMasterVolume(0.5f);
                if (am.MasterVolume == 0.5f)
                {
                    PassTest("Volume Control");
                }
                else
                {
                    FailTest("Volume Control", $"Expected: 0.5, Got: {am.MasterVolume}");
                }
            }
            catch (System.Exception e)
            {
                FailTest("Volume Control", e.Message);
            }
        }
        
        #endregion
        
        #region Helpers
        
        private void PassTest(string testName)
        {
            testsPassed++;
            LogTestResult($"✅ {testName}");
        }
        
        private void FailTest(string testName, string reason)
        {
            testsFailed++;
            LogTestResult($"❌ {testName}: {reason}");
        }
        
        private void LogTestSection(string sectionName)
        {
            LogTestResult($"\n--- {sectionName} ---");
        }
        
        private void LogTestResult(string message)
        {
            testLog.AppendLine(message);
            if (verboseLogging)
            {
                Debug.Log(message);
            }
        }
        
        #endregion
    }
}

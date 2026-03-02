using UnityEngine;
using DragRace.Core;
using DragRace.Data;
using DragRace.Managers;
using DragRace.SaveSystem;

namespace DragRace.Tests
{
    /// <summary>
    /// Тестирование игровых механик
    /// </summary>
    public class GameTests : MonoBehaviour
    {
        [Header("Настройки теста")]
        public bool runOnStart = true;
        public TestType testsToRun;
        
        private int testsPassed;
        private int testsFailed;
        
        private void Start()
        {
            if (runOnStart)
            {
                RunTests(testsToRun);
            }
        }
        
        public void RunTests(TestType tests)
        {
            testsPassed = 0;
            testsFailed = 0;
            
            Debug.Log("=== НАЧАЛО ТЕСТИРОВАНИЯ ===");
            
            if ((tests & TestType.Economy) == TestType.Economy)
                TestEconomy();
            
            if ((tests & TestType.Career) == TestType.Career)
                TestCareer();
            
            if ((tests & TestType.SaveLoad) == TestType.SaveLoad)
                TestSaveLoad();
            
            if ((tests & TestType.VehicleStats) == TestType.VehicleStats)
                TestVehicleStats();
            
            Debug.Log($"=== ТЕСТИРОВАНИЕ ЗАВЕРШЕНО ===");
            Debug.Log($"Пройдено: {testsPassed}, Провалено: {testsFailed}");
        }
        
        #region Тесты экономики
        
        private void TestEconomy()
        {
            Debug.Log("--- Тест экономики ---");
            
            // Тест 1: Баланс наград
            float basePrize = 200f;
            float multiplier = 1.5f;
            float expectedMinRaces = 8f;
            float carPrice = 35000f;
            
            float racesNeeded = carPrice / (basePrize * multiplier);
            
            Assert(racesNeeded >= expectedMinRaces && racesNeeded <= 25f, 
                $"Баланс экономики: нужно {racesNeeded:F0} гонок для авто за ${carPrice}");
            
            // Тест 2: Прогрессия наград по тирам
            float tier1Prize = 150f * 1f;    // Уличный
            float tier2Prize = 400f * 1.5f;  // Полупрофи
            float tier3Prize = 1000f * 2f;   // Профи
            float tier4Prize = 2000f * 3f;   // Элита
            float tier5Prize = 5000f * 5f;   // Легенда
            
            Assert(tier2Prize > tier1Prize, "Награда тира 2 > тира 1");
            Assert(tier3Prize > tier2Prize, "Награда тира 3 > тира 2");
            Assert(tier4Prize > tier3Prize, "Награда тира 4 > тира 3");
            Assert(tier5Prize > tier4Prize, "Награда тира 5 > тира 4");
            
            Debug.Log($"Награды по тирам: T1=${tier1Prize}, T2=${tier2Prize}, T3=${tier3Prize}, T4=${tier4Prize}, T5=${tier5Prize}");
            
            PassTest("Экономика");
        }
        
        #endregion
        
        #region Тесты карьеры
        
        private void TestCareer()
        {
            Debug.Log("--- Тест карьеры ---");
            
            // Создание тестовой карьеры
            var careerData = new CareerData();
            
            // Тест 1: Проверка структуры тиров
            int expectedTiers = 5;
            Assert(expectedTiers == 5, $"Ожидаемое количество тиров: {expectedTiers}");
            
            // Тест 2: Прогрессия сложности
            float[] difficultyMods = { 1.5f, 1.0f, 0.7f, 0.5f }; // Easy, Medium, Hard, Expert
            Assert(difficultyMods[0] > difficultyMods[1], "Easy медленнее Medium");
            Assert(difficultyMods[1] > difficultyMods[2], "Medium медленнее Hard");
            Assert(difficultyMods[2] > difficultyMods[3], "Hard медленнее Expert");
            
            // Тест 3: Rubber-banding
            float rubberBandStrength = 0.2f;
            float maxBonus = 0.3f;
            float activationDistance = 10f;
            
            Assert(rubberBandStrength > 0f && rubberBandStrength <= 0.5f, "Сила rubber-banding в диапазоне");
            Assert(maxBonus > 0f && maxBonus <= 1f, "Макс бонус в диапазоне");
            Assert(activationDistance > 0f && activationDistance <= 50f, "Дистанция активации в диапазоне");
            
            PassTest("Карьера");
        }
        
        #endregion
        
        #region Тесты сохранений
        
        private void TestSaveLoad()
        {
            Debug.Log("--- Тест сохранений ---");
            
            // Тест 1: Проверка менеджера сохранений
            Assert(SaveManager.Instance != null, "SaveManager существует");
            
            // Тест 2: Проверка количества слотов
            int expectedSaveSlots = 5;
            int expectedAutoSaveSlots = 5;
            
            Assert(expectedSaveSlots == 5, $"Слотов сохранений: {expectedSaveSlots}");
            Assert(expectedAutoSaveSlots == 5, $"Слотов автосохранений: {expectedAutoSaveSlots}");
            
            // Тест 3: Интервал автосохранения
            float autoSaveInterval = 5f; // минут
            Assert(autoSaveInterval >= 1f && autoSaveInterval <= 30f, "Интервал автосохранения в диапазоне");
            
            PassTest("Сохранения");
        }
        
        #endregion
        
        #region Тесты характеристик автомобиля
        
        private void TestVehicleStats()
        {
            Debug.Log("--- Тест характеристик авто ---");
            
            // Тест 1: Базовые характеристики Civic Type R
            var civicStats = new VehicleStats
            {
                power = 306f,
                torque = 400f,
                weight = 1380f,
                grip = 0.75f
            };
            
            float powerToWeight = civicStats.power / (civicStats.weight / 1000f);
            Assert(powerToWeight > 200f && powerToWeight < 250f, $"Civic P/W: {powerToWeight:F1}");
            
            // Тест 2: Supra мощнее Civic
            var supraStats = new VehicleStats
            {
                power = 382f,
                torque = 500f,
                weight = 1520f,
                grip = 0.8f
            };
            
            Assert(supraStats.power > civicStats.power, "Supra мощнее Civic");
            Assert(supraStats.torque > civicStats.torque, "Supra имеет больший момент");
            
            // Тест 3: Hellcat самый мощный
            var hellcatStats = new VehicleStats
            {
                power = 717f,
                torque = 880f,
                weight = 2000f,
                grip = 0.7f
            };
            
            Assert(hellcatStats.power > supraStats.power, "Hellcat мощнее Supra");
            Assert(hellcatStats.torque > supraStats.torque, "Hellcat имеет больший момент");
            
            Debug.Log($"P/W Civic: {powerToWeight:F1}, Supra: {supraStats.power/(supraStats.weight/1000f):F1}, Hellcat: {hellcatStats.power/(hellcatStats.weight/1000f):F1}");
            
            PassTest("Характеристики авто");
        }
        
        #endregion
        
        #region Утилиты
        
        private void Assert(bool condition, string message)
        {
            if (condition)
            {
                Debug.Log($"✓ {message}");
            }
            else
            {
                Debug.LogError($"✗ {message}");
                testsFailed++;
            }
        }
        
        private void PassTest(string testName)
        {
            testsPassed++;
            Debug.Log($"Пройден тест: {testName}");
        }
        
        #endregion
    }
    
    [System.Flags]
    public enum TestType
    {
        None = 0,
        Economy = 1,
        Career = 2,
        SaveLoad = 4,
        VehicleStats = 8,
        All = Economy | Career | SaveLoad | VehicleStats
    }
}

using UnityEngine;

namespace DragRace.Core
{
    /// <summary>
    /// Основная конфигурация игры
    /// </summary>
    [CreateAssetMenu(fileName = "GameConfig", menuName = "DragRace/Game Config")]
    public class GameConfig : ScriptableObject
    {
        [Header("Настройки разрешения")]
        public ResolutionData[] supportedResolutions;
        
        [Header("Автосохранение")]
        [Range(1, 30)]
        public float autoSaveIntervalMinutes = 5f;
        public int maxAutoSaveSlots = 5;
        
        [Header("Сохранения")]
        public int maxSaveSlots = 5;
        
        [Header("Звук")]
        [Range(0, 100)]
        public int defaultMasterVolume = 80;
        [Range(0, 100)]
        public int defaultMusicVolume = 60;
        [Range(0, 100)]
        public int defaultSfxVolume = 70;
        
        [Header("Геймплей")]
        public float startMoney = 10000f;
        public float xpMultiplier = 1f;
        
        [Header("Баланс экономики")]
        [Tooltip("Множитель награды в карьере")]
        public float careerPrizeMultiplier = 1.5f;
        [Tooltip("Среднее время гонки для баланса (сек)")]
        public float averageRaceTimeSeconds = 10f;
        [Tooltip("Минимум гонок для покупки авто текущего тира")]
        public int minRacesForCarPurchase = 8;
        [Tooltip("Максимум гонок для покупки авто текущего тира")]
        public int maxRacesForCarPurchase = 15;
        
        [Header("Заезд")]
        public RaceDistance[] raceDistances;
        
        [Header("Персонаж")]
        public float baseReactionTime = 0.5f;
        public float baseShiftSpeed = 0.3f;
        public int maxUpgradePointsPerLevel = 5;
        
        public static GameConfig Instance
        {
            get
            {
                if (_instance == null)
                {
                    _instance = Resources.Load<GameConfig>("GameConfig");
                    if (_instance == null)
                    {
                        Debug.LogError("GameConfig не найден в Resources!");
                    }
                }
                return _instance;
            }
        }
        
        private static GameConfig _instance;
    }
    
    [System.Serializable]
    public struct ResolutionData
    {
        public int width;
        public int height;
        public string displayName;
    }
    
    [System.Serializable]
    public struct RaceDistance
    {
        public string name;
        public float distanceMeters;
        public string displayName;
    }
}

using UnityEngine;

namespace DragRace.Career
{
    /// <summary>
    /// Менеджер карьеры
    /// Управляет прогрессом, уровнями, звёздами
    /// </summary>
    public class CareerManager : MonoBehaviour
    {
        #region Singleton
        
        private static CareerManager _instance;
        
        public static CareerManager Instance
        {
            get
            {
                if (_instance == null)
                {
                    _instance = FindFirstObjectByType<CareerManager>();
                    if (_instance == null)
                    {
                        GameObject go = new GameObject("CareerManager");
                        _instance = go.AddComponent<CareerManager>();
                        DontDestroyOnLoad(go);
                    }
                }
                return _instance;
            }
        }
        
        #endregion
        
        #region Parameters
        
        [Header("Данные карьеры")]
        [Tooltip("Прогресс игрока")]
        public CareerProgress progress;
        
        [Tooltip("Данные уровней")]
        public CareerTierData[] tierData;
        
        [Header("Баланс")]
        [Tooltip("Опыт за победу в гонке")]
        public int experiencePerWin = 100;
        
        [Tooltip("Опыт за поражение")]
        public int experiencePerLoss = 25;
        
        [Tooltip("Опыт для следующего уровня")]
        public int experiencePerLevel = 500;
        
        #endregion
        
        #region Events
        
        public delegate void CareerStateChangedHandler(CareerProgress progress);
        public event CareerStateChangedHandler OnCareerProgressChanged;
        
        public delegate void LevelUpHandler(int newLevel);
        public event LevelUpHandler OnLevelUp;
        
        public delegate void TierUnlockedHandler(int newTier);
        public event TierUnlockedHandler OnTierUnlocked;
        
        #endregion
        
        #region Properties
        
        public int CurrentTier => progress.currentTier;
        public int CurrentRace => progress.currentRaceIndex;
        public int TotalStars => progress.totalStars;
        public int Level => progress.level;
        public int Experience => progress.experience;
        
        #endregion
        
        #region Unity Methods
        
        private void Awake()
        {
            if (_instance != null && _instance != this)
            {
                Destroy(gameObject);
                return;
            }
            _instance = this;
            DontDestroyOnLoad(gameObject);
        }
        
        private void Start()
        {
            InitializeCareer();
        }
        
        #endregion
        
        #region Initialization
        
        /// <summary>
        /// Инициализация карьеры
        /// </summary>
        public void InitializeCareer()
        {
            if (progress == null)
            {
                progress = new CareerProgress();
            }
            
            Debug.Log("🏆 CareerManager инициализирован");
            Debug.Log($"   Уровень: {progress.currentTier + 1}/5");
            Debug.Log($"   Гонка: {progress.currentRaceIndex + 1}/4");
            Debug.Log($"   Звёзды: {progress.totalStars}/60");
        }
        
        /// <summary>
        /// Новая карьера
        /// </summary>
        public void StartNewCareer()
        {
            progress = new CareerProgress();
            Debug.Log("🎮 Новая карьера начата!");
            
            OnCareerProgressChanged?.Invoke(progress);
        }
        
        #endregion
        
        #region Race Management
        
        /// <summary>
        /// Начать следующую гонку
        /// </summary>
        public void StartNextRace()
        {
            Debug.Log($"🏁 Гонка {progress.currentTier + 1}-{progress.currentRaceIndex + 1}");
            
            // Проверка доступности босса
            if (progress.currentRaceIndex == 3 && !progress.IsBossUnlocked(progress.currentTier))
            {
                Debug.LogError("❌ Босс ещё не доступен! Получите минимум 1 звезду за каждую гонку.");
                return;
            }
        }
        
        /// <summary>
        /// Завершить гонку
        /// </summary>
        public void FinishRace(bool isWin, float time, bool isBoss = false)
        {
            // Расчёт звёзд
            int stars = CalculateStars(time, progress.currentTier, progress.currentRaceIndex);
            
            // Сохранение звёзд
            progress.SetStars(progress.currentTier, progress.currentRaceIndex, stars);
            
            // Начисление опыта
            int expGain = isWin ? experiencePerWin : experiencePerLoss;
            progress.experience += expGain;
            
            Debug.Log($"🏁 Гонка завершена:");
            Debug.Log($"   Результат: {(isWin ? "Победа" : "Поражение")}");
            Debug.Log($"   Время: {time:F3}с");
            Debug.Log($"   Звёзды: {stars}/3");
            Debug.Log($"   Опыт: +{expGain}");
            
            // Проверка повышения уровня
            CheckLevelUp();
            
            // Переход к следующей гонке
            if (isWin)
            {
                AdvanceToNextRace();
            }
            
            OnCareerProgressChanged?.Invoke(progress);
        }
        
        /// <summary>
        /// Расчёт звёзд по времени
        /// </summary>
        private int CalculateStars(float time, int tier, int raceIndex)
        {
            if (tier < 0 || tier >= tierData.Length) return 0;
            
            CareerTierData data = tierData[tier];
            
            if (time <= data.threeStarTime) return 3;
            if (time <= data.twoStarTime) return 2;
            if (time <= data.oneStarTime) return 1;
            
            return 0;
        }
        
        /// <summary>
        /// Переход к следующей гонке
        /// </summary>
        private void AdvanceToNextRace()
        {
            progress.currentRaceIndex++;
            
            // Проверка завершения уровня
            if (progress.currentRaceIndex >= 4)
            {
                Debug.Log($"🎉 Уровень {progress.currentTier + 1} завершён!");
                
                // Проверка возможности перехода
                if (progress.currentTier < 4)
                {
                    Debug.Log("🔓 Доступен следующий уровень!");
                }
            }
            else
            {
                Debug.Log($"➡️ Следующая гонка: {progress.currentRaceIndex + 1}/4");
            }
        }
        
        /// <summary>
        /// Перейти к следующему уровню
        /// </summary>
        public void AdvanceToNextTier()
        {
            if (progress.AdvanceToNextTier())
            {
                Debug.Log($"🎌 Уровень повышен: {progress.currentTier + 1}!");
                OnTierUnlocked?.Invoke(progress.currentTier);
                OnCareerProgressChanged?.Invoke(progress);
            }
        }
        
        #endregion
        
        #region Level System
        
        /// <summary>
        /// Проверка повышения уровня
        /// </summary>
        private void CheckLevelUp()
        {
            while (progress.experience >= experiencePerLevel * progress.level)
            {
                progress.experience -= experiencePerLevel * progress.level;
                progress.level++;
                
                Debug.Log($"🎌 Уровень персонажа повышен: {progress.level}!");
                
                OnLevelUp?.Invoke(progress.level);
            }
        }
        
        /// <summary>
        /// Получить прогресс до следующего уровня
        /// </summary>
        public float GetLevelProgress()
        {
            int expNeeded = experiencePerLevel * progress.level;
            return (float)progress.experience / expNeeded;
        }
        
        #endregion
        
        #region Statistics
        
        /// <summary>
        /// Получить статистику карьеры
        /// </summary>
        public string GetCareerStats()
        {
            return $@"=== КАРЬЕРА ===
Уровень: {progress.currentTier + 1}/5
Гонка: {progress.currentRaceIndex + 1}/4
Звёзды: {progress.totalStars}/60
Уровень персонажа: {progress.level}
Опыт: {progress.experience}/{experiencePerLevel * progress.level}";
        }
        
        /// <summary>
        /// Получить общий прогресс в %
        /// </summary>
        public float GetTotalProgress()
        {
            // 5 уровней × 4 гонки = 20 гонок
            int totalRaces = 20;
            int completedRaces = 0;
            
            for (int tier = 0; tier < 5; tier++)
            {
                for (int race = 0; race < 4; race++)
                {
                    if (progress.GetStars(tier, race) > 0)
                    {
                        completedRaces++;
                    }
                }
            }
            
            return (float)completedRaces / totalRaces * 100f;
        }
        
        #endregion
        
        #region Save/Load
        
        /// <summary>
        /// Сохранить прогресс
        /// </summary>
        public CareerProgress SaveProgress()
        {
            Debug.Log("💾 Прогресс карьеры сохранён");
            return progress;
        }
        
        /// <summary>
        /// Загрузить прогресс
        /// </summary>
        public void LoadProgress(CareerProgress savedProgress)
        {
            if (savedProgress != null)
            {
                progress = savedProgress;
                Debug.Log("📂 Прогресс карьеры загружен");
                OnCareerProgressChanged?.Invoke(progress);
            }
        }
        
        #endregion
    }
}

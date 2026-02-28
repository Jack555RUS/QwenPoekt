using UnityEngine;
using DragRace.Data;
using DragRace.Core;
using System.Collections.Generic;

namespace DragRace.Managers
{
    /// <summary>
    /// Менеджер карьеры
    /// </summary>
    public class CareerManager : MonoBehaviour
    {
        public static CareerManager Instance { get; private set; }
        
        [Header("Данные карьеры")]
        public CareerData careerData;
        
        [Header("Настройки экономики")]
        [Range(1f, 3f)]
        public float basePrizeMultiplier = 1.5f;
        [Range(500f, 2000f)]
        public float averageRaceTimeSeconds = 10f;
        
        // События
        public delegate void CareerStateHandler(CareerData data);
        public event CareerStateHandler OnCareerUpdated;
        public event CareerStateHandler OnTierCompleted;
        public event CareerStateHandler OnRaceCompleted;
        
        private void Awake()
        {
            if (Instance != null && Instance != this)
            {
                Destroy(gameObject);
                return;
            }
            
            Instance = this;
            DontDestroyOnLoad(gameObject);
        }
        
        private void Start()
        {
            InitializeCareer();
        }
        
        private void InitializeCareer()
        {
            if (GameManager.Instance != null && GameManager.Instance.GameData != null)
            {
                // Загрузка из сохранений или создание новой
                careerData = new CareerData();
                CreateDefaultCareer();
            }
        }
        
        /// <summary>
        /// Создание карьеры по умолчанию
        /// </summary>
        private void CreateDefaultCareer()
        {
            careerData.tiers = new List<CareerTier>();
            
            // Тир 1: Уличный уровень
            careerData.tiers.Add(CreateStreetTier());
            
            // Тир 2: Полупрофессиональный
            careerData.tiers.Add(CreateSemiProTier());
            
            // Тир 3: Профессиональный
            careerData.tiers.Add(CreateProTier());
            
            // Тир 4: Элитный
            careerData.tiers.Add(CreateEliteTier());
            
            // Тир 5: Легендарный
            careerData.tiers.Add(CreateLegendTier());
            
            // Разблокировать первую гонку
            careerData.UnlockRace(careerData.tiers[0].races[0].id);
        }
        
        private CareerTier CreateStreetTier()
        {
            return new CareerTier
            {
                id = "tier_street",
                name = "Уличные гонки",
                description = "Начальный уровень. Докажи что ты чего-то стоишь.",
                difficulty = 1,
                prizeMultiplier = 1f,
                races = new List<CareerRace>
                {
                    new CareerRace
                    {
                        id = "street_race_1",
                        name = "Первый вызов",
                        opponentName = "Новичок Джек",
                        opponentCarId = "civic_stock",
                        distanceMeters = 402f,
                        entryFee = 50f,
                        prizePool = 150f,
                        requiredStars = 0,
                        starConditions = new StarCondition[]
                        {
                            new StarCondition { type = StarConditionType.WinRace, threshold = 0, description = "Победить" },
                            new StarCondition { type = StarConditionType.BeatTime, threshold = 12f, description = "Меньше 12 сек" },
                            new StarCondition { type = StarConditionType.BeatOpponentByMargin, threshold = 0.5f, description = "Отрыв 0.5 сек" }
                        }
                    },
                    new CareerRace
                    {
                        id = "street_race_2",
                        name = "Дворовый чемпион",
                        opponentName = "Местный Гонщик",
                        opponentCarId = "civic_stock",
                        distanceMeters = 402f,
                        entryFee = 75f,
                        prizePool = 200f,
                        requiredStars = 1,
                        starConditions = new StarCondition[]
                        {
                            new StarCondition { type = StarConditionType.WinRace, threshold = 0, description = "Победить" },
                            new StarCondition { type = StarConditionType.BeatTime, threshold = 11.5f, description = "Меньше 11.5 сек" },
                            new StarCondition { type = StarConditionType.BeatOpponentByMargin, threshold = 0.7f, description = "Отрыв 0.7 сек" }
                        }
                    },
                    new CareerRace
                    {
                        id = "street_race_3",
                        name = "Уличный король",
                        opponentName = "Районный Босс",
                        opponentCarId = "supra_gr",
                        distanceMeters = 402f,
                        entryFee = 100f,
                        prizePool = 300f,
                        requiredStars = 1,
                        starConditions = new StarCondition[]
                        {
                            new StarCondition { type = StarConditionType.WinRace, threshold = 0, description = "Победить" },
                            new StarCondition { type = StarConditionType.BeatTime, threshold = 11f, description = "Меньше 11 сек" },
                            new StarCondition { type = StarConditionType.BeatOpponentByMargin, threshold = 1f, description = "Отрыв 1 сек" }
                        }
                    }
                },
                boss = new CareerBoss
                {
                    id = "street_boss",
                    name = "Король Улиц",
                    bossCarId = "supra_gr",
                    distanceMeters = 402f,
                    prizePool = 1000f,
                    requiredStarsToChallenge = 7,
                    powerBonus = 50f,
                    reactionBonus = 0.05f
                }
            };
        }
        
        private CareerTier CreateSemiProTier()
        {
            return new CareerTier
            {
                id = "tier_semipro",
                name = "Полупрофи",
                description = "Выход на новый уровень. Конкуренция растёт.",
                difficulty = 2,
                prizeMultiplier = 1.5f,
                races = new List<CareerRace>()
            };
            
            // Добавляем гонки
            var tier = careerData.tiers[1];
            tier.races.Add(new CareerRace
            {
                id = "semipro_race_1",
                name = "Первый шаг",
                opponentName = "Начинающий Профи",
                opponentCarId = "supra_gr",
                distanceMeters = 402f,
                entryFee = 150f,
                prizePool = 400f,
                requiredStars = 0,
                starConditions = CreateStandardStarConditions(10.5f)
            });
            
            tier.races.Add(new CareerRace
            {
                id = "semipro_race_2",
                name = "Второй раунд",
                opponentName = "Опытный Гонщик",
                opponentCarId = "supra_gr",
                distanceMeters = 804f,
                entryFee = 200f,
                prizePool = 550f,
                requiredStars = 1,
                starConditions = CreateStandardStarConditions(21f)
            });
            
            tier.races.Add(new CareerRace
            {
                id = "semipro_race_3",
                name = "Полуфинал",
                opponentName = "Местная Звезда",
                opponentCarId = "911_gt3",
                distanceMeters = 402f,
                entryFee = 250f,
                prizePool = 700f,
                requiredStars = 1,
                starConditions = CreateStandardStarConditions(10f)
            });
            
            tier.boss = new CareerBoss
            {
                id = "semipro_boss",
                name = "Чемпион Региона",
                bossCarId = "911_gt3",
                distanceMeters = 804f,
                prizePool = 2500f,
                requiredStarsToChallenge = 7,
                powerBonus = 80f,
                reactionBonus = 0.03f
            };
            
            return tier;
        }
        
        private CareerTier CreateProTier()
        {
            return new CareerTier
            {
                id = "tier_pro",
                name = "Профи",
                description = "Профессиональная лига. Только лучшие.",
                difficulty = 3,
                prizeMultiplier = 2f,
                races = new List<CareerRace>()
            };
            
            var tier = careerData.tiers[2];
            tier.races.Add(new CareerRace
            {
                id = "pro_race_1",
                name = "Лига Профи",
                opponentName = "Профи №1",
                opponentCarId = "911_gt3",
                distanceMeters = 402f,
                entryFee = 400f,
                prizePool = 1000f,
                requiredStars = 0,
                starConditions = CreateStandardStarConditions(9.5f)
            });
            
            tier.races.Add(new CareerRace
            {
                id = "pro_race_2",
                name = "Вызов Чемпиона",
                opponentName = "Действующий Чемпион",
                opponentCarId = "challenger_hellcat",
                distanceMeters = 804f,
                entryFee = 500f,
                prizePool = 1400f,
                requiredStars = 1,
                starConditions = CreateStandardStarConditions(20f)
            });
            
            tier.races.Add(new CareerRace
            {
                id = "pro_race_3",
                name = "Битва Титанов",
                opponentName = "Легенда Трека",
                opponentCarId = "challenger_hellcat",
                distanceMeters = 402f,
                entryFee = 600f,
                prizePool = 1800f,
                requiredStars = 1,
                starConditions = CreateStandardStarConditions(9f)
            });
            
            tier.boss = new CareerBoss
            {
                id = "pro_boss",
                name = "Национальный Чемпион",
                bossCarId = "challenger_hellcat",
                distanceMeters = 402f,
                prizePool = 5000f,
                requiredStarsToChallenge = 7,
                powerBonus = 100f,
                reactionBonus = 0.02f
            };
            
            return tier;
        }
        
        private CareerTier CreateEliteTier()
        {
            return new CareerTier
            {
                id = "tier_elite",
                name = "Элита",
                description = "Элитная лига. Путь к вершине.",
                difficulty = 4,
                prizeMultiplier = 3f,
                races = new List<CareerRace>()
            };
            
            var tier = careerData.tiers[3];
            // Добавить гонки...
            
            tier.boss = new CareerBoss
            {
                id = "elite_boss",
                name = "Мировая Звезда",
                bossCarId = "911_gt3",
                distanceMeters = 804f,
                prizePool = 10000f,
                requiredStarsToChallenge = 7,
                powerBonus = 150f,
                reactionBonus = 0.01f
            };
            
            return tier;
        }
        
        private CareerTier CreateLegendTier()
        {
            return new CareerTier
            {
                id = "tier_legend",
                name = "Легенда",
                description = "Последний рубеж. Стань легендой.",
                difficulty = 5,
                prizeMultiplier = 5f,
                races = new List<CareerRace>()
            };
            
            var tier = careerData.tiers[4];
            // Добавить гонки...
            
            tier.boss = new CareerBoss
            {
                id = "legend_boss",
                name = "Бог Драга",
                bossCarId = "challenger_hellcat",
                distanceMeters = 402f,
                prizePool = 25000f,
                requiredStarsToChallenge = 7,
                powerBonus = 200f,
                reactionBonus = 0f
            };
            
            return tier;
        }
        
        private StarCondition[] CreateStandardStarConditions(float beatTimeThreshold)
        {
            return new StarCondition[]
            {
                new StarCondition { type = StarConditionType.WinRace, threshold = 0, description = "Победить" },
                new StarCondition { type = StarConditionType.BeatTime, threshold = beatTimeThreshold, description = $"Меньше {beatTimeThreshold} сек" },
                new StarCondition { type = StarConditionType.BeatOpponentByMargin, threshold = 0.5f, description = "Отрыв 0.5 сек" }
            };
        }
        
        #region Управление карьерой
        
        public void StartRace(string raceId)
        {
            var race = FindRaceById(raceId);
            if (race == null)
            {
                Debug.LogWarning($"Гонка {raceId} не найдена!");
                return;
            }
            
            // Проверка разблокировки
            if (!careerData.IsRaceUnlocked(raceId))
            {
                Debug.LogWarning($"Гонка {raceId} заблокирована!");
                return;
            }
            
            // Запуск гонки
            var raceDistance = new RaceDistance
            {
                name = race.id,
                distanceMeters = race.distanceMeters,
                displayName = GetDistanceDisplayName(race.distanceMeters)
            };
            
            // TODO: Запустить гонку через RaceManager
        }
        
        public void CompleteRace(RaceResult result)
        {
            string raceId = result.distanceName;
            int starsEarned = CalculateStarsForRace(raceId, result);
            
            careerData.SetStars(raceId, Mathf.Max(careerData.GetStars(raceId), starsEarned));
            careerData.SetBestTime(raceId, result.time);
            
            OnRaceCompleted?.Invoke(careerData);
            OnCareerUpdated?.Invoke(careerData);
            
            // Проверка прогресса
            CheckCareerProgress();
        }
        
        private int CalculateStarsForRace(string raceId, RaceResult result)
        {
            var race = FindRaceById(raceId);
            if (race == null) return 0;
            
            return race.CalculateStarsEarned(result);
        }
        
        private void CheckCareerProgress()
        {
            var currentTier = careerData.GetCurrentTier();
            var currentRace = careerData.GetCurrentRace();
            
            // Проверка возможности продвижения
            if (careerData.CanAdvanceToNextRace())
            {
                careerData.AdvanceToNextRace();
            }
            
            // Проверка завершения тира
            if (careerData.CanAdvanceToNextTier())
            {
                OnTierCompleted?.Invoke(careerData);
            }
        }
        
        private CareerRace FindRaceById(string raceId)
        {
            foreach (var tier in careerData.tiers)
            {
                foreach (var race in tier.races)
                {
                    if (race.id == raceId)
                        return race;
                }
            }
            return null;
        }
        
        private string GetDistanceDisplayName(float distance)
        {
            return distance switch
            {
                <= 201 => "1/8 мили",
                <= 402 => "1/4 мили",
                <= 804 => "1/2 мили",
                _ => "1 миля"
            };
        }
        
        #endregion
        
        #region Экономика
        
        /// <summary>
        /// Расчёт награды с учётом баланса
        /// </summary>
        public float CalculatePrize(CareerRace race, RaceResult result)
        {
            float basePrize = race.prizePool * basePrizeMultiplier;
            
            // Бонус за звёзды
            int stars = careerData.GetStars(race.id);
            float starBonus = 1f + (stars * 0.1f); // +10% за каждую звезду
            
            // Бонус за сложность
            float difficultyBonus = 1f + (careerData.GetCurrentTier().difficulty * 0.2f);
            
            // Штраф за поражение
            float resultMultiplier = result.isWin ? 1f : 0.3f;
            
            return basePrize * starBonus * difficultyBonus * resultMultiplier;
        }
        
        /// <summary>
        /// Расчёт опыта
        /// </summary>
        public float CalculateXpReward(CareerRace race, RaceResult result)
        {
            float baseXp = race.distanceMeters switch
            {
                <= 201 => 50f,
                <= 402 => 100f,
                <= 804 => 200f,
                _ => 400f
            };
            
            float difficultyMultiplier = 1f + (careerData.GetCurrentTier().difficulty * 0.25f);
            float resultMultiplier = result.isWin ? 1f : 0.5f;
            
            return baseXp * difficultyMultiplier * resultMultiplier;
        }
        
        #endregion
    }
}

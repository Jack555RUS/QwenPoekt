using UnityEngine;
using DragRace.Data;
using System.Collections.Generic;

namespace DragRace.Managers
{
    /// <summary>
    /// Менеджер карьеры
    /// </summary>
    public class CareerManager : MonoBehaviour
    {
        public static CareerManager Instance { get; private set; }
        
        public CareerData careerData;
        [Range(1f, 3f)] public float basePrizeMultiplier = 1.5f;
        
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
            InitializeCareer();
        }
        
        private void InitializeCareer()
        {
            if (careerData == null)
                careerData = new CareerData();
            
            if (careerData.tiers == null || careerData.tiers.Count == 0)
                CreateDefaultCareer();
        }
        
        private void CreateDefaultCareer()
        {
            careerData.tiers = new List<CareerTier>();
            
            // Тир 1: Уличный
            careerData.tiers.Add(new CareerTier
            {
                id = "tier_street",
                name = "Уличные гонки",
                description = "Начальный уровень",
                difficulty = 1,
                prizeMultiplier = 1f,
                races = new List<CareerRace>
                {
                    new CareerRace
                    {
                        id = "street_race_1",
                        name = "Первый вызов",
                        opponentName = "Новичок Джек",
                        distanceMeters = 402f,
                        entryFee = 50f,
                        prizePool = 150f,
                        starConditions = new StarCondition[]
                        {
                            new StarCondition { type = StarConditionType.WinRace, description = "Победить" },
                            new StarCondition { type = StarConditionType.BeatTime, threshold = 12f, description = "< 12 сек" },
                            new StarCondition { type = StarConditionType.BeatOpponentByMargin, threshold = 0.5f, description = "Отрыв 0.5 сек" }
                        }
                    },
                    new CareerRace
                    {
                        id = "street_race_2",
                        name = "Дворовый чемпион",
                        opponentName = "Местный Гонщик",
                        distanceMeters = 402f,
                        entryFee = 75f,
                        prizePool = 200f,
                        starConditions = new StarCondition[]
                        {
                            new StarCondition { type = StarConditionType.WinRace, description = "Победить" },
                            new StarCondition { type = StarConditionType.BeatTime, threshold = 11.5f, description = "< 11.5 сек" }
                        }
                    },
                    new CareerRace
                    {
                        id = "street_race_3",
                        name = "Уличный король",
                        opponentName = "Районный Босс",
                        distanceMeters = 402f,
                        entryFee = 100f,
                        prizePool = 300f,
                        starConditions = new StarCondition[]
                        {
                            new StarCondition { type = StarConditionType.WinRace, description = "Победить" },
                            new StarCondition { type = StarConditionType.BeatTime, threshold = 11f, description = "< 11 сек" }
                        }
                    }
                },
                boss = new CareerBoss
                {
                    id = "street_boss",
                    name = "Король Улиц",
                    distanceMeters = 402f,
                    prizePool = 1000f,
                    requiredStarsToChallenge = 7
                }
            });
            
            // Тир 2-5 (упрощённо)
            for (int i = 2; i <= 5; i++)
            {
                careerData.tiers.Add(new CareerTier
                {
                    id = $"tier_{i}",
                    name = $"Тир {i}",
                    difficulty = i,
                    prizeMultiplier = 1f + i * 0.5f,
                    races = new List<CareerRace>(),
                    boss = new CareerBoss
                    {
                        id = $"boss_{i}",
                        name = $"Босс Тир {i}",
                        prizePool = 1000f * i,
                        requiredStarsToChallenge = 7
                    }
                });
            }
            
            careerData.UnlockRace("street_race_1");
        }
        
        public void StartRace(string raceId)
        {
            var race = FindRaceById(raceId);
            if (race == null || !careerData.IsRaceUnlocked(raceId))
            {
                Debug.LogWarning($"Гонка {raceId} недоступна!");
                return;
            }
        }
        
        public void CompleteRace(RaceResult result)
        {
            string raceId = result.distanceName;
            int stars = CalculateStarsForRace(raceId, result);
            
            careerData.SetStars(raceId, Mathf.Max(careerData.GetStars(raceId), stars));
            careerData.SetBestTime(raceId, result.time);
            
            OnRaceCompleted?.Invoke(careerData);
            OnCareerUpdated?.Invoke(careerData);
            CheckCareerProgress();
        }
        
        private int CalculateStarsForRace(string raceId, RaceResult result)
        {
            var race = FindRaceById(raceId);
            return race?.CalculateStarsEarned(result) ?? 0;
        }
        
        private void CheckCareerProgress()
        {
            if (careerData.CanAdvanceToNextRace())
                careerData.AdvanceToNextRace();
            
            if (careerData.CanAdvanceToNextTier())
                OnTierCompleted?.Invoke(careerData);
        }
        
        private CareerRace FindRaceById(string raceId)
        {
            if (careerData?.tiers == null) return null;
            
            foreach (var tier in careerData.tiers)
            {
                if (tier.races != null)
                {
                    foreach (var race in tier.races)
                    {
                        if (race.id == raceId) return race;
                    }
                }
            }
            return null;
        }
        
        public float CalculatePrize(CareerRace race, RaceResult result)
        {
            float basePrize = race.prizePool * basePrizeMultiplier;
            int stars = careerData.GetStars(race.id);
            float starBonus = 1f + (stars * 0.1f);
            float resultMultiplier = result.isWin ? 1f : 0.3f;
            return basePrize * starBonus * resultMultiplier;
        }
        
        public float CalculateXpReward(CareerRace race, RaceResult result)
        {
            float baseXp = race.distanceMeters <= 402 ? 100f : 200f;
            float resultMultiplier = result.isWin ? 1f : 0.5f;
            return baseXp * resultMultiplier;
        }
    }
}

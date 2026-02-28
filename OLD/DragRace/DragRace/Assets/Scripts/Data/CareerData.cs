using System;
using System.Collections.Generic;
using UnityEngine;

namespace DragRace.Data
{
    /// <summary>
    /// Система карьеры - последовательные гонки
    /// </summary>
    [Serializable]
    public class CareerData
    {
        public int currentTier;
        public int currentRaceIndex;
        public List<CareerTier> tiers;
        public Dictionary<string, bool> unlockedRaces;
        public Dictionary<string, float> bestTimes;
        public Dictionary<string, int> starsEarned;
        
        public CareerData()
        {
            currentTier = 0;
            currentRaceIndex = 0;
            tiers = new List<CareerTier>();
            unlockedRaces = new Dictionary<string, bool>();
            bestTimes = new Dictionary<string, float>();
            starsEarned = new Dictionary<string, int>();
        }
        
        public CareerTier GetCurrentTier()
        {
            if (tiers == null || tiers.Count == 0) return null;
            return tiers[Mathf.Clamp(currentTier, 0, tiers.Count - 1)];
        }
        
        public CareerRace GetCurrentRace()
        {
            var tier = GetCurrentTier();
            if (tier == null || tier.races == null || tier.races.Count == 0) return null;
            return tier.races[Mathf.Clamp(currentRaceIndex, 0, tier.races.Count - 1)];
        }
        
        public bool IsRaceUnlocked(string raceId)
        {
            return unlockedRaces.ContainsKey(raceId) && unlockedRaces[raceId];
        }
        
        public void UnlockRace(string raceId)
        {
            if (!unlockedRaces.ContainsKey(raceId))
                unlockedRaces[raceId] = true;
        }
        
        public void SetBestTime(string raceId, float time)
        {
            if (!bestTimes.ContainsKey(raceId) || time < bestTimes[raceId])
            {
                bestTimes[raceId] = time;
            }
        }
        
        public float GetBestTime(string raceId)
        {
            return bestTimes.ContainsKey(raceId) ? bestTimes[raceId] : float.MaxValue;
        }
        
        public int GetStars(string raceId)
        {
            return starsEarned.ContainsKey(raceId) ? starsEarned[raceId] : 0;
        }
        
        public void SetStars(string raceId, int stars)
        {
            starsEarned[raceId] = stars;
        }
        
        public bool CanAdvanceToNextRace()
        {
            var currentRace = GetCurrentRace();
            if (currentRace == null) return false;
            
            // Нужно получить хотя бы 1 звезду
            return GetStars(currentRace.id) >= 1;
        }
        
        public bool CanAdvanceToNextTier()
        {
            var tier = GetCurrentTier();
            if (tier == null) return false;
            
            // Проверка всех гонок в текущем тире
            int totalStars = 0;
            int maxStars = 0;
            
            foreach (var race in tier.races)
            {
                maxStars += 3;
                totalStars += GetStars(race.id);
            }
            
            // Нужно получить 70% звёзд
            return totalStars >= maxStars * 0.7f;
        }
        
        public void AdvanceToNextRace()
        {
            if (CanAdvanceToNextRace())
            {
                var tier = GetCurrentTier();
                if (currentRaceIndex < tier.races.Count - 1)
                {
                    currentRaceIndex++;
                    UnlockRace(tier.races[currentRaceIndex].id);
                }
            }
        }
        
        public void AdvanceToNextTier()
        {
            if (CanAdvanceToNextTier() && currentTier < tiers.Count - 1)
            {
                currentTier++;
                currentRaceIndex = 0;
                
                // Разблокировать первую гонку в новом тире
                var newTier = tiers[currentTier];
                if (newTier.races.Count > 0)
                {
                    UnlockRace(newTier.races[0].id);
                }
            }
        }
    }
    
    /// <summary>
    /// Тир карьеры (уровень сложности)
    /// </summary>
    [Serializable]
    public class CareerTier
    {
        public string id;
        public string name;
        public string description;
        public int difficulty; // 1-5
        public List<CareerRace> races;
        public CareerBoss boss;
        public float prizeMultiplier;
        
        public CareerTier()
        {
            races = new List<CareerRace>();
            difficulty = 1;
            prizeMultiplier = 1f;
        }
    }
    
    /// <summary>
    /// Гонка в карьере
    /// </summary>
    [Serializable]
    public class CareerRace
    {
        public string id;
        public string name;
        public string opponentName;
        public string opponentCarId;
        public float distanceMeters;
        public float entryFee;
        public float prizePool;
        public int requiredStars; // звёзд для разблокировки
        
        // Условия победы для звёзд
        public StarCondition[] starConditions;
        
        public CareerRace()
        {
            starConditions = new StarCondition[3];
        }
        
        public int CalculateStarsEarned(RaceResult result)
        {
            int stars = 0;
            
            foreach (var condition in starConditions)
            {
                if (condition == null) continue;
                
                bool met = condition.IsMet(result);
                if (met) stars++;
            }
            
            return Mathf.Clamp(stars, 0, 3);
        }
    }
    
    /// <summary>
    /// Босс тира
    /// </summary>
    [Serializable]
    public class CareerBoss
    {
        public string id;
        public string name;
        public string bossCarId;
        public float distanceMeters;
        public float prizePool;
        public int requiredStarsToChallenge;
        
        // Бонусы босса
        public float powerBonus;
        public float reactionBonus;
    }
    
    /// <summary>
    /// Условия для получения звёзд
    /// </summary>
    [Serializable]
    public class StarCondition
    {
        public StarConditionType type;
        public float threshold;
        public string description;
        
        public bool IsMet(RaceResult result)
        {
            if (!result.isWin) return false;
            
            switch (type)
            {
                case StarConditionType.WinRace:
                    return result.isWin;
                    
                case StarConditionType.BeatTime:
                    return result.time <= threshold;
                    
                case StarConditionType.BeatOpponentByMargin:
                    // Нужно реализовать сравнение с соперником
                    return result.isWin;
                    
                case StarConditionType.NoNitro:
                    // Проверка использования нитро
                    return true;
                    
                case StarConditionType.BeatDistance:
                    // Победить с отрывом
                    return result.isWin;
            }
            
            return false;
        }
    }
    
    public enum StarConditionType
    {
        WinRace,
        BeatTime,
        BeatOpponentByMargin,
        NoNitro,
        BeatDistance
    }
}

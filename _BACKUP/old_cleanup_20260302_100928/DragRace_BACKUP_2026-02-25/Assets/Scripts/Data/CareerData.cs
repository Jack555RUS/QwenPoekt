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
        
        // Используем Serializable классы вместо Dictionary
        public List<StringBoolPair> unlockedRaces;
        public List<StringFloatPair> bestTimes;
        public List<StringIntPair> starsEarned;
        
        public CareerData()
        {
            currentTier = 0;
            currentRaceIndex = 0;
            tiers = new List<CareerTier>();
            unlockedRaces = new List<StringBoolPair>();
            bestTimes = new List<StringFloatPair>();
            starsEarned = new List<StringIntPair>();
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
            var pair = unlockedRaces.Find(p => p.key == raceId);
            return pair.value;
        }
        
        public void UnlockRace(string raceId)
        {
            var pair = unlockedRaces.Find(p => p.key == raceId);
            if (pair.key == null)
            {
                unlockedRaces.Add(new StringBoolPair { key = raceId, value = true });
            }
            else
            {
                pair.value = true;
            }
        }
        
        public void SetBestTime(string raceId, float time)
        {
            var pair = bestTimes.Find(p => p.key == raceId);
            if (pair.key == null || time < pair.value)
            {
                if (pair.key == null)
                    bestTimes.Add(new StringFloatPair { key = raceId, value = time });
                else
                    pair.value = time;
            }
        }
        
        public float GetBestTime(string raceId)
        {
            var pair = bestTimes.Find(p => p.key == raceId);
            return pair.key != null ? pair.value : float.MaxValue;
        }
        
        public int GetStars(string raceId)
        {
            var pair = starsEarned.Find(p => p.key == raceId);
            return pair.key != null ? pair.value : 0;
        }
        
        public void SetStars(string raceId, int stars)
        {
            var pair = starsEarned.Find(p => p.key == raceId);
            if (pair.key == null)
            {
                starsEarned.Add(new StringIntPair { key = raceId, value = stars });
            }
            else
            {
                pair.value = Mathf.Max(pair.value, stars);
            }
        }
        
        public bool CanAdvanceToNextRace()
        {
            var currentRace = GetCurrentRace();
            if (currentRace == null) return false;
            return GetStars(currentRace.id) >= 1;
        }
        
        public bool CanAdvanceToNextTier()
        {
            var tier = GetCurrentTier();
            if (tier == null) return false;
            
            int totalStars = 0;
            int maxStars = 0;
            
            foreach (var race in tier.races)
            {
                maxStars += 3;
                totalStars += GetStars(race.id);
            }
            
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
                var newTier = tiers[currentTier];
                if (newTier.races.Count > 0)
                    UnlockRace(newTier.races[0].id);
            }
        }
    }
    
    [Serializable]
    public class StringBoolPair
    {
        public string key;
        public bool value;
    }
    
    [Serializable]
    public class StringFloatPair
    {
        public string key;
        public float value;
    }
    
    [Serializable]
    public class StringIntPair
    {
        public string key;
        public int value;
    }
    
    /// <summary>
    /// Тир карьеры
    /// </summary>
    [Serializable]
    public class CareerTier
    {
        public string id;
        public string name;
        public string description;
        public int difficulty;
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
        public int requiredStars;
        public StarCondition[] starConditions;
        
        public CareerRace()
        {
            starConditions = new StarCondition[3];
        }
        
        public int CalculateStarsEarned(RaceResult result)
        {
            int stars = 0;
            if (starConditions == null) return 0;
            
            foreach (var condition in starConditions)
            {
                if (condition != null && condition.IsMet(result))
                    stars++;
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
        public float powerBonus;
        public float reactionBonus;
    }
    
    /// <summary>
    /// Условия для звёзд
    /// </summary>
    [Serializable]
    public class StarCondition
    {
        public StarConditionType type;
        public float threshold;
        public string description;
        
        public bool IsMet(RaceResult result)
        {
            if (!result.isWin && type == StarConditionType.WinRace) return false;
            
            switch (type)
            {
                case StarConditionType.WinRace:
                    return result.isWin;
                case StarConditionType.BeatTime:
                    return result.time <= threshold;
                case StarConditionType.BeatOpponentByMargin:
                    return result.isWin;
                case StarConditionType.NoNitro:
                    return true;
                case StarConditionType.BeatDistance:
                    return result.isWin;
            }
            return false;
        }
    }
    
    [Serializable]
    public enum StarConditionType
    {
        WinRace,
        BeatTime,
        BeatOpponentByMargin,
        NoNitro,
        BeatDistance
    }
}

using UnityEngine;
using System;
using System.Collections.Generic;

namespace DragRace.Career
{
    /// <summary>
    /// Система карьеры
    /// 5 уровней, 3 гонки + босс на уровень, звёзды (0-3)
    /// </summary>
    [Serializable]
    public class CareerProgress
    {
        [Tooltip("Текущий уровень карьеры (0-4)")]
        public int currentTier = 0;
        
        [Tooltip("Текущая гонка в уровне (0-3, где 3 = босс)")]
        public int currentRaceIndex = 0;
        
        [Tooltip("Звёзды за каждую гонку [tier][raceIndex]")]
        public List<List<int>> stars = new List<List<int>>();
        
        [Tooltip("Всего звёзд")]
        public int totalStars = 0;
        
        [Tooltip("Прогресс опыта")]
        public int experience = 0;
        
        [Tooltip("Уровень персонажа")]
        public int level = 1;
        
        public CareerProgress()
        {
            InitializeStars();
        }
        
        private void InitializeStars()
        {
            stars.Clear();
            for (int tier = 0; tier < 5; tier++)
            {
                List<int> tierStars = new List<int>();
                int racesInTier = 4; // 3 гонки + босс
                for (int race = 0; race < racesInTier; race++)
                {
                    tierStars.Add(0);
                }
                stars.Add(tierStars);
            }
        }
        
        /// <summary>
        /// Получить звёзды за гонку
        /// </summary>
        public int GetStars(int tier, int raceIndex)
        {
            if (tier < 0 || tier >= stars.Count) return 0;
            if (raceIndex < 0 || raceIndex >= stars[tier].Count) return 0;
            
            return stars[tier][raceIndex];
        }
        
        /// <summary>
        /// Установить звёзды за гонку
        /// </summary>
        public void SetStars(int tier, int raceIndex, int starCount)
        {
            if (tier < 0 || tier >= stars.Count) return;
            if (raceIndex < 0 || raceIndex >= stars[tier].Count) return;
            
            int oldStars = stars[tier][raceIndex];
            stars[tier][raceIndex] = Mathf.Clamp(starCount, 0, 3);
            
            totalStars += (stars[tier][raceIndex] - oldStars);
        }
        
        /// <summary>
        /// Проверить доступность босса
        /// </summary>
        public bool IsBossUnlocked(int tier)
        {
            if (tier < 0 || tier >= stars.Count) return false;
            
            // Нужно минимум 1 звезду за каждую из 3 гонок
            for (int race = 0; race < 3; race++)
            {
                if (stars[tier][race] < 1) return false;
            }
            
            return true;
        }
        
        /// <summary>
        /// Проверить завершённость уровня
        /// </summary>
        public bool IsTierCompleted(int tier)
        {
            if (tier < 0 || tier >= stars.Count) return false;
            
            // Нужно минимум 1 звезду за босса
            return stars[tier][3] >= 1;
        }
        
        /// <summary>
        /// Перейти к следующему уровню
        /// </summary>
        public bool AdvanceToNextTier()
        {
            if (IsTierCompleted(currentTier))
            {
                currentTier = Mathf.Min(currentTier + 1, 4);
                currentRaceIndex = 0;
                Debug.Log($"🎌 Переход на уровень {currentTier + 1}!");
                return true;
            }
            
            Debug.LogWarning("❌ Уровень ещё не завершён! Победите босса.");
            return false;
        }
    }
    
    /// <summary>
    /// Данные об уровне карьеры
    /// </summary>
    [System.Serializable]
    public class CareerTierData
    {
        [Header("Основное")]
        public string tierName;
        public string description;
        
        [Header("Требования")]
        public int minPower; // Минимальная мощность (л.с.)
        public int maxPower; // Максимальная мощность (л.с.)
        
        [Header("Награды")]
        public int baseReward; // Базовая награда за гонку
        public int bossBonus;  // Бонус за победу над боссом
        
        [Header("Соперники")]
        public List<string> opponentCarIds; // ID автомобилей соперников
        public string bossCarId; // ID автомобиля босса
        
        [Header("Звёзды")]
        public float oneStarTime;   // Время для 1 звезды
        public float twoStarTime;   // Время для 2 звёзд
        public float threeStarTime; // Время для 3 звёзд
    }
}

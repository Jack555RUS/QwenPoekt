using UnityEngine;
using System;
using System.Collections.Generic;

namespace ProbMenu.Data
{
    /// <summary>
    /// Данные игрока
    /// </summary>
    [Serializable]
    public class PlayerData
    {
        [Header("Основная информация")]
        public string playerName;
        public int level;
        public int experience;
        public int money;
        public DateTime createDate;
        public DateTime lastPlayDate;
        public float totalDistance; // Общий пробег (км)

        [Header("Характеристики")]
        public PlayerStats stats;

        [Header("Гараж")]
        public List<int> ownedCars;     // ID автомобилей
        public int currentCarId;        // Текущий автомобиль
        public List<string> ownedUpgrades; // ID апгрейдов

        [Header("Прогресс")]
        public CareerProgress careerProgress;
        public List<RaceResult> raceHistory;

        [Header("Статистика")]
        public PlayerStatistics statistics;

        public PlayerData()
        {
            playerName = "Player";
            level = 1;
            experience = 0;
            money = 5000;
            createDate = DateTime.Now;
            lastPlayDate = DateTime.Now;
            totalDistance = 0f;

            stats = new PlayerStats();
            ownedCars = new List<int> { 0 }; // Стартовый автомобиль
            currentCarId = 0;
            ownedUpgrades = new List<string>();

            careerProgress = new CareerProgress();
            raceHistory = new List<RaceResult>();
            statistics = new PlayerStatistics();
        }
    }

    /// <summary>
    /// Характеристики игрока
    /// </summary>
    [Serializable]
    public class PlayerStats
    {
        [Header("Навыки")]
        [Range(0f, 1f)]
        public float reactionSpeed;      // Скорость реакции (старт)
        [Range(0f, 1f)]
        public float shiftSpeed;         // Скорость переключения
        [Range(0f, 1f)]
        public float nitroEfficiency;    // Эффективность нитро

        [Header("Прогрессия")]
        public int maxLevel;
        public int[] experienceToNextLevel;

        public PlayerStats()
        {
            reactionSpeed = 0.5f;
            shiftSpeed = 0.5f;
            nitroEfficiency = 0.5f;
            maxLevel = 50;
            experienceToNextLevel = new int[] { 100, 250, 500, 1000, 2000 };
        }

        /// <summary>
        /// Расчитать время реакции (секунды)
        /// Диапазон: 0.3с (max) - 0.7с (min)
        /// </summary>
        public float GetReactionTime()
        {
            // От 0.7с (0 skill) до 0.3с (max skill)
            float result = 0.7f - (reactionSpeed * 0.4f);
            return Mathf.Clamp(result, 0.3f, 0.7f);
        }

        /// <summary>
        /// Расчитать время переключения (секунды)
        /// Диапазон: 0.2с (max) - 0.5с (min)
        /// </summary>
        public float GetShiftTime()
        {
            // От 0.5с до 0.2с
            float result = 0.5f - (shiftSpeed * 0.3f);
            return Mathf.Clamp(result, 0.2f, 0.5f);
        }
    }

    /// <summary>
    /// Прогресс карьеры
    /// </summary>
    [Serializable]
    public class CareerProgress
    {
        public int currentChapter;
        public int completedRaces;
        public int wonRaces;
        public int bestLeague;

        public CareerProgress()
        {
            currentChapter = 1;
            completedRaces = 0;
            wonRaces = 0;
            bestLeague = 0;
        }
    }

    /// <summary>
    /// Результат заезда
    /// </summary>
    [Serializable]
    public class RaceResult
    {
        public DateTime date;
        public string trackName;
        public RaceDistance distance;
        public int position;
        public float time;
        public float maxSpeed;
        public int earnedMoney;
        public int earnedExperience;

        public RaceResult()
        {
            date = DateTime.Now;
            trackName = "Unknown";
            distance = RaceDistance.QuarterMile;
            position = 1;
            time = 0f;
            maxSpeed = 0f;
            earnedMoney = 0;
            earnedExperience = 0;
        }
    }

    /// <summary>
    /// Дистанция заезда
    /// </summary>
    public enum RaceDistance
    {
        QuarterMile,  // 402м (1/4 мили)
        HalfMile,     // 804м (1/2 мили)
        OneMile,      // 1609м (1 миля)
        TwoMile,      // 3218м (2 мили) - тест макс. скорости
        Test          // Тестовая
    }

    /// <summary>
    /// Статистика игрока
    /// </summary>
    [Serializable]
    public class PlayerStatistics
    {
        public int totalRaces;
        public int totalWins;
        public int totalLosses;
        public float bestQuarterMileTime;
        public float bestHalfMileTime;
        public float bestOneMileTime;
        public float maxSpeedReached;
        public int totalMoneyEarned;
        public int totalMoneySpent;

        public PlayerStatistics()
        {
            totalRaces = 0;
            totalWins = 0;
            totalLosses = 0;
            bestQuarterMileTime = 999f;
            bestHalfMileTime = 999f;
            bestOneMileTime = 999f;
            maxSpeedReached = 0f;
            totalMoneyEarned = 0;
            totalMoneySpent = 0;
        }

        public float GetWinRate()
        {
            if (totalRaces == 0) return 0f;
            return (float)totalWins / totalRaces;
        }
    }
}

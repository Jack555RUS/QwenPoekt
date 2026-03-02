using UnityEngine;
using ProbMenu.Core;
using ProbMenu.Data;
using Logger = ProbMenu.Core.Logger;

namespace ProbMenu.Racing
{
    /// <summary>
    /// Система карьеры и прогрессии
    /// Уровни, достижения, открытия
    /// </summary>
    public class CareerManager : MonoBehaviour
    {
        [Header("Данные игрока")]
        [SerializeField] private PlayerData playerData;

        [Header("Прогресс")]
        [SerializeField] private int currentChapter;
        [SerializeField] private int currentLeague;

        [Header("События")]
        public System.Action<int> OnLevelUp;
        public System.Action<int> OnChapterComplete;
        public System.Action<int> OnLeagueChange;

        private void Start()
        {
            Logger.I("=== CAREER MANAGER INITIALIZED ===");

            if (playerData == null)
            {
                playerData = new PlayerData();
                Logger.W("Created new PlayerData");
            }

            currentChapter = playerData.careerProgress.currentChapter;
            currentLeague = playerData.careerProgress.bestLeague;
        }

        #region Experience & Level

        public void AddExperience(int exp)
        {
            if (playerData == null) return;

            playerData.experience += exp;
            Logger.I($"XP +{exp} (Total: {playerData.experience})");

            CheckLevelUp();
        }

        private void CheckLevelUp()
        {
            if (playerData == null) return;

            int requiredExp = GetRequiredExperience(playerData.level);

            if (playerData.experience >= requiredExp)
            {
                LevelUp();
            }
        }

        private void LevelUp()
        {
            playerData.level++;
            playerData.experience -= GetRequiredExperience(playerData.level - 1);

            Logger.I($"🎉 LEVEL UP! Now level {playerData.level}");
            OnLevelUp?.Invoke(playerData.level);

            // Бонус за уровень
            int moneyBonus = playerData.level * 100;
            AddMoney(moneyBonus);

            // Улучшение характеристик
            ImproveStats();
        }

        private int GetRequiredExperience(int level)
        {
            // Простая формула: 100 * level^1.5
            return Mathf.CeilToInt(100 * Mathf.Pow(level, 1.5f));
        }

        private void ImproveStats()
        {
            if (playerData == null) return;

            // Небольшое улучшение навыков каждый уровень
            float improvement = 0.01f;

            playerData.stats.reactionSpeed = Mathf.Min(1f, 
                playerData.stats.reactionSpeed + improvement);
            playerData.stats.shiftSpeed = Mathf.Min(1f, 
                playerData.stats.shiftSpeed + improvement);
            playerData.stats.nitroEfficiency = Mathf.Min(1f, 
                playerData.stats.nitroEfficiency + improvement);

            Logger.I("Stats improved!");
        }

        #endregion

        #region Money

        public void AddMoney(int amount)
        {
            if (playerData == null) return;

            playerData.money += amount;
            playerData.statistics.totalMoneyEarned += amount;

            Logger.I($"💰 Money +${amount} (Total: ${playerData.money})");
        }

        public bool SpendMoney(int amount)
        {
            if (playerData == null) return false;

            if (playerData.money >= amount)
            {
                playerData.money -= amount;
                playerData.statistics.totalMoneySpent += amount;
                Logger.I($"💸 Spent ${amount}");
                return true;
            }

            Logger.W($"Not enough money! Need ${amount}, have ${playerData.money}");
            return false;
        }

        #endregion

        #region Career Progress

        public void CompleteRace(RaceResult result)
        {
            if (playerData == null) return;

            playerData.raceHistory.Add(result);
            playerData.careerProgress.completedRaces++;

            if (result.position == 1)
            {
                playerData.careerProgress.wonRaces++;
                playerData.statistics.totalWins++;
            }
            else
            {
                playerData.statistics.totalLosses++;
            }

            playerData.statistics.totalRaces++;

            // Обновление рекордов
            UpdateRecords(result);

            // Награда
            int moneyReward = CalculateReward(result);
            int expReward = CalculateExpReward(result);

            AddMoney(moneyReward);
            AddExperience(expReward);

            Logger.I($"Race completed: P{result.position} in {result.time:F3}s");
        }

        private void UpdateRecords(RaceResult result)
        {
            switch (result.distance)
            {
                case RaceDistance.QuarterMile:
                    if (result.time < playerData.statistics.bestQuarterMileTime)
                        playerData.statistics.bestQuarterMileTime = result.time;
                    break;
                case RaceDistance.HalfMile:
                    if (result.time < playerData.statistics.bestHalfMileTime)
                        playerData.statistics.bestHalfMileTime = result.time;
                    break;
                case RaceDistance.OneMile:
                    if (result.time < playerData.statistics.bestOneMileTime)
                        playerData.statistics.bestOneMileTime = result.time;
                    break;
            }

            if (result.maxSpeed > playerData.statistics.maxSpeedReached)
                playerData.statistics.maxSpeedReached = result.maxSpeed;
        }

        private int CalculateReward(RaceResult result)
        {
            int baseReward = 200;

            // Множитель от позиции
            float positionMultiplier = result.position == 1 ? 2f : 1f;

            // Бонус за рекорд
            bool isRecord = false;
            switch (result.distance)
            {
                case RaceDistance.QuarterMile:
                    isRecord = result.time < playerData.statistics.bestQuarterMileTime;
                    break;
                case RaceDistance.HalfMile:
                    isRecord = result.time < playerData.statistics.bestHalfMileTime;
                    break;
                case RaceDistance.OneMile:
                    isRecord = result.time < playerData.statistics.bestOneMileTime;
                    break;
            }

            if (isRecord) positionMultiplier += 0.5f;

            return Mathf.CeilToInt(baseReward * positionMultiplier);
        }

        private int CalculateExpReward(RaceResult result)
        {
            int baseExp = 50;

            // Бонус за победу
            if (result.position == 1)
                baseExp *= 2;

            // Бонус за время (быстрее = больше XP)
            float timeBonus = 0f;
            switch (result.distance)
            {
                case RaceDistance.QuarterMile:
                    if (result.time < 10f) timeBonus = 0.5f;
                    break;
                case RaceDistance.HalfMile:
                    if (result.time < 20f) timeBonus = 0.5f;
                    break;
                case RaceDistance.OneMile:
                    if (result.time < 40f) timeBonus = 0.5f;
                    break;
            }

            return Mathf.CeilToInt(baseExp * (1 + timeBonus));
        }

        #endregion

        #region Getters

        public PlayerData GetPlayerData() => playerData;

        public int GetLevel() => playerData?.level ?? 1;
        public int GetMoney() => playerData?.money ?? 0;
        public int GetExperience() => playerData?.experience ?? 0;

        public float GetReactionTime() => playerData?.stats.GetReactionTime() ?? 0.5f;
        public float GetShiftTime() => playerData?.stats.GetShiftTime() ?? 0.3f;

        public int GetRequiredExperience() => GetRequiredExperience(playerData?.level ?? 1);

        public float GetExpProgress()
        {
            if (playerData == null) return 0f;

            int currentLevelExp = GetRequiredExperience(playerData.level - 1);
            int nextLevelExp = GetRequiredExperience(playerData.level);
            int expInLevel = playerData.experience;

            return Mathf.InverseLerp(currentLevelExp, nextLevelExp, expInLevel);
        }

        #endregion

        #region Debug

        private void OnGUI()
        {
            if (!Application.isEditor) return;

            GUILayout.BeginArea(new Rect(320, 10, 300, 200));
            GUILayout.Label("=== CAREER ===");
            GUILayout.Label($"Level: {GetLevel()}");
            GUILayout.Label($"XP: {GetExperience()} / {GetRequiredExperience()}");
            GUILayout.Label($"Money: ${GetMoney()}");
            GUILayout.Label($"Reaction: {GetReactionTime():F2}s");
            GUILayout.Label($"Shift: {GetShiftTime():F2}s");

            // Прогресс до следующего уровня
            GUILayout.Label($"Progress: {GetExpProgress() * 100:F1}%");

            GUILayout.EndArea();
        }

        #endregion
    }
}

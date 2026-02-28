using UnityEngine;
using UnityEngine.UI;
using DragRace.Core;
using DragRace.Data;

namespace DragRace.UI
{
    /// <summary>
    /// Экран персонажа и прокачки
    /// </summary>
    public class CharacterScreenUI : MonoBehaviour
    {
        [Header("Информация о персонаже")]
        public Text playerNameText;
        public Text playerLevelText;
        public Text experienceText;
        public Text moneyText;
        public Text ageText;
        public Text totalDistanceText;
        public Text totalRacesText;
        public Text totalWinsText;
        
        [Header("Характеристики")]
        public StatWithUpgrade reactionStat;
        public StatWithUpgrade shiftSpeedStat;
        
        [Header("Прогресс бар уровня")]
        public Slider experienceSlider;
        public Text xpToNextLevelText;
        
        [Header("Очки улучшения")]
        public Text upgradePointsText;
        
        [Header("Кнопки")]
        public Button upgradeReactionButton;
        public Button upgradeShiftSpeedButton;
        public Button backButton;
        
        private PlayerData playerData;
        
        private void Start()
        {
            playerData = GameManager.Instance.GameData.playerData;
            
            SubscribeToEvents();
            UpdateDisplay();
        }
        
        private void OnDestroy()
        {
            UnsubscribeFromEvents();
        }
        
        private void SubscribeToEvents()
        {
            if (upgradeReactionButton != null)
                upgradeReactionButton.onClick.AddListener(() => UpgradeStat(StatType.Reaction));
            
            if (upgradeShiftSpeedButton != null)
                upgradeShiftSpeedButton.onClick.AddListener(() => UpgradeStat(StatType.ShiftSpeed));
            
            if (backButton != null)
                backButton.onClick.AddListener(OnBackClicked);
        }
        
        private void UnsubscribeFromEvents()
        {
            if (upgradeReactionButton != null)
                upgradeReactionButton.onClick.RemoveListener(() => UpgradeStat(StatType.Reaction));
            
            if (upgradeShiftSpeedButton != null)
                upgradeShiftSpeedButton.onClick.RemoveListener(() => UpgradeStat(StatType.ShiftSpeed));
            
            if (backButton != null)
                backButton.onClick.RemoveListener(OnBackClicked);
        }
        
        #region Отображение
        
        public void UpdateDisplay()
        {
            if (playerNameText != null)
                playerNameText.text = playerData.playerName;
            
            if (playerLevelText != null)
                playerLevelText.text = $"Уровень {playerData.level}";
            
            if (experienceText != null)
                experienceText.text = $"{playerData.experience:F0} / {playerData.experienceToNextLevel:F0}";
            
            if (moneyText != null)
                moneyText.text = $"{playerData.money:F0} $";
            
            if (totalDistanceText != null)
                totalDistanceText.text = $"{playerData.totalDistanceKm:F2} км";
            
            if (totalRacesText != null)
                totalRacesText.text = $"{playerData.totalRaces}";
            
            if (totalWinsText != null)
                totalWinsText.text = $"{playerData.totalWins} ({GetWinRate():F1}%)";
            
            if (upgradePointsText != null)
                upgradePointsText.text = $"Очков: {playerData.upgradePoints}";
            
            // Прогресс бар
            if (experienceSlider != null)
            {
                experienceSlider.value = playerData.experience / playerData.experienceToNextLevel;
            }
            
            if (xpToNextLevelText != null)
            {
                float xpNeeded = playerData.experienceToNextLevel - playerData.experience;
                xpToNextLevelText.text = $"{xpNeeded:F0} XP до уровня";
            }
            
            // Характеристики
            if (reactionStat != null)
                reactionStat.SetValue(playerData.reactionTime, 0.1f, 0.5f);
            
            if (shiftSpeedStat != null)
                shiftSpeedStat.SetValue(playerData.shiftSpeed, 0.1f, 0.5f);
        }
        
        private float GetWinRate()
        {
            if (playerData.totalRaces == 0) return 0f;
            return (playerData.totalWins / (float)playerData.totalRaces) * 100f;
        }
        
        #endregion
        
        #region Улучшения
        
        private void UpgradeStat(StatType statType)
        {
            if (playerData.upgradePoints <= 0)
            {
                Debug.LogWarning("Нет очков улучшения!");
                return;
            }
            
            float upgradeCost = GetUpgradeCost(statType);
            
            switch (statType)
            {
                case StatType.Reaction:
                    if (playerData.reactionTime <= 0.1f)
                    {
                        Debug.LogWarning("Характерстика на максимуме!");
                        return;
                    }
                    playerData.reactionTime -= 0.01f;
                    break;
                    
                case StatType.ShiftSpeed:
                    if (playerData.shiftSpeed <= 0.1f)
                    {
                        Debug.LogWarning("Характерстика на максимуме!");
                        return;
                    }
                    playerData.shiftSpeed -= 0.01f;
                    break;
            }
            
            playerData.upgradePoints--;
            UpdateDisplay();
        }
        
        private float GetUpgradeCost(StatType statType)
        {
            // Базовая стоимость + бонус за каждый уровень
            return 1f; // 1 очко за улучшение
        }
        
        #endregion
        
        #region Навигация
        
        private void OnBackClicked()
        {
            GameManager.Instance.ChangeState(GameState.GameMenu);
        }
        
        #endregion
    }
    
    /// <summary>
    /// Характеристика с кнопкой улучшения
    /// </summary>
    public class StatWithUpgrade : MonoBehaviour
    {
        public Text statNameText;
        public Text statValueText;
        public Slider statSlider;
        public Button upgradeButton;
        public Text upgradeCostText;
        
        private float currentValue;
        private float minValue;
        private float maxValue;
        
        public void SetValue(float value, float min, float max)
        {
            currentValue = value;
            minValue = min;
            maxValue = max;
            
            if (statValueText != null)
                statValueText.text = value.ToString("F2");
            
            if (statSlider != null)
            {
                // Инвертируем: меньше = лучше
                float normalized = 1 - ((value - min) / (max - min));
                statSlider.value = Mathf.Clamp01(normalized);
            }
        }
    }
    
    public enum StatType
    {
        Reaction,
        ShiftSpeed
    }
}

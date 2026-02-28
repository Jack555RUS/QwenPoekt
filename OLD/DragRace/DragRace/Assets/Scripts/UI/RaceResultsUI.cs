using UnityEngine;
using UnityEngine.UI;
using DragRace.Core;
using DragRace.Data;
using DragRace.Racing;

namespace DragRace.UI
{
    /// <summary>
    /// Экран результатов заезда
    /// </summary>
    public class RaceResultsUI : MonoBehaviour
    {
        [Header("Основная информация")]
        public Text resultTitleText;
        public Image resultTitleImage;
        
        [Header("Время и скорость")]
        public Text timeText;
        public Text topSpeedText;
        public Text distanceText;
        
        [Header("Награды")]
        public Text moneyEarnedText;
        public Text xpEarnedText;
        
        [Header("Автомобиль")]
        public Text carNameText;
        public Text carStatsText;
        
        [Header("Сравнение с соперником")]
        public Text opponentNameText;
        public Text opponentTimeText;
        public Text timeDifferenceText;
        
        [Header("Кнопки")]
        public Button continueButton;
        public Button raceAgainButton;
        public Button menuButton;
        
        private RaceResult lastResult;
        
        private void Start()
        {
            SubscribeToEvents();
            
            if (RaceManager.Instance != null)
            {
                DisplayResults(RaceManager.Instance.currentRaceResult);
            }
        }
        
        private void OnDestroy()
        {
            UnsubscribeFromEvents();
        }
        
        private void SubscribeToEvents()
        {
            if (continueButton != null)
                continueButton.onClick.AddListener(OnContinueClicked);
            
            if (raceAgainButton != null)
                raceAgainButton.onClick.AddListener(OnRaceAgainClicked);
            
            if (menuButton != null)
                menuButton.onClick.AddListener(OnMenuClicked);
        }
        
        private void UnsubscribeFromEvents()
        {
            if (continueButton != null)
                continueButton.onClick.RemoveListener(OnContinueClicked);
            
            if (raceAgainButton != null)
                raceAgainButton.onClick.RemoveListener(OnRaceAgainClicked);
            
            if (menuButton != null)
                menuButton.onClick.RemoveListener(OnMenuClicked);
        }
        
        #region Отображение результатов
        
        public void DisplayResults(RaceResult result)
        {
            lastResult = result;
            
            if (result == null) return;
            
            // Заголовок
            if (resultTitleText != null)
            {
                resultTitleText.text = result.isWin ? "ПОБЕДА!" : "ПОРАЖЕНИЕ";
            }
            
            if (resultTitleImage != null)
            {
                resultTitleImage.color = result.isWin ? Color.green : Color.red;
            }
            
            // Время и скорость
            if (timeText != null)
                timeText.text = $"{result.time:F3} с";
            
            if (topSpeedText != null)
                topSpeedText.text = $"{result.topSpeed:F1} км/ч";
            
            if (distanceText != null)
                distanceText.text = $"{result.distanceMeters:F0} м";
            
            // Награды
            if (moneyEarnedText != null)
                moneyEarnedText.text = $"+{result.earnedMoney:F0} $";
            
            if (xpEarnedText != null)
                xpEarnedText.text = $"+{result.earnedXp:F0} XP";
            
            // Автомобиль
            if (result.usedVehicle != null)
            {
                if (carNameText != null)
                    carNameText.text = result.usedVehicle.vehicleName;
                
                if (carStatsText != null)
                {
                    carStatsText.text = $@"
Мощность: {result.usedVehicle.currentStats.power:F0} л.с.
Вес: {result.usedVehicle.currentStats.weight:F0} кг
                    ";
                }
            }
            
            // Соперник
            if (opponentNameText != null)
                opponentNameText.text = result.opponentName;
        }
        
        #endregion
        
        #region Кнопки
        
        private void OnContinueClicked()
        {
            GameManager.Instance.ChangeState(GameState.GameMenu);
        }
        
        private void OnRaceAgainClicked()
        {
            if (lastResult != null)
            {
                // Повторный заезд на той же дистанции
                var raceDistance = new RaceDistance
                {
                    name = lastResult.distanceName,
                    distanceMeters = lastResult.distanceMeters,
                    displayName = GetDistanceDisplayName(lastResult.distanceMeters)
                };
                
                GameManager.Instance.ChangeState(GameState.Racing);
                // TODO: Запустить заезд
            }
        }
        
        private void OnMenuClicked()
        {
            GameManager.Instance.ChangeState(GameState.MainMenu);
        }
        
        #endregion
        
        private string GetDistanceDisplayName(float distance)
        {
            return distance switch
            {
                <= 402 => "1/4 мили",
                <= 804 => "1/2 мили",
                _ => "1 миля"
            };
        }
    }
}

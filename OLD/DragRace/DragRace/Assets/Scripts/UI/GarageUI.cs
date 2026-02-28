using UnityEngine;
using UnityEngine.UI;
using DragRace.Core;
using DragRace.Data;
using System.Collections.Generic;

namespace DragRace.UI
{
    /// <summary>
    /// Гараж - выбор и просмотр автомобилей
    /// </summary>
    public class GarageUI : MonoBehaviour
    {
        [Header("Список автомобилей")]
        public Transform carListContainer;
        public GameObject carListItemPrefab;
        
        [Header="Отображение автомобиля"]
        public Image carImage;
        public Text carNameText;
        public Text carManufacturerText;
        public Text carYearText;
        
        [Header("Характеристики")]
        public StatBar powerBar;
        public StatBar torqueBar;
        public StatBar weightBar;
        public StatBar gripBar;
        public StatBar aeroBar;
        
        [Header("Кнопки")]
        public Button selectButton;
        public Button upgradeButton;
        public Button sellButton;
        public Button backButton;
        
        [Header("Информация")]
        public Text currentValueText;
        public Text conditionText;
        
        private List<VehicleData> playerVehicles;
        private int selectedIndex;
        
        private void Start()
        {
            playerVehicles = GameManager.Instance.GameData.playerVehicles;
            selectedIndex = GameManager.Instance.GameData.currentVehicleIndex;
            
            SubscribeToEvents();
            UpdateCarList();
            DisplaySelectedCar();
        }
        
        private void OnDestroy()
        {
            UnsubscribeFromEvents();
        }
        
        private void SubscribeToEvents()
        {
            if (selectButton != null)
                selectButton.onClick.AddListener(OnSelectCar);
            
            if (upgradeButton != null)
                upgradeButton.onClick.AddListener(OnUpgradeClicked);
            
            if (sellButton != null)
                sellButton.onClick.AddListener(OnSellClicked);
            
            if (backButton != null)
                backButton.onClick.AddListener(OnBackClicked);
        }
        
        private void UnsubscribeFromEvents()
        {
            if (selectButton != null)
                selectButton.onClick.RemoveListener(OnSelectCar);
            
            if (upgradeButton != null)
                upgradeButton.onClick.RemoveListener(OnUpgradeClicked);
            
            if (sellButton != null)
                sellButton.onClick.RemoveListener(OnSellClicked);
            
            if (backButton != null)
                backButton.onClick.RemoveListener(OnBackClicked);
        }
        
        #region Список автомобилей
        
        private void UpdateCarList()
        {
            if (carListContainer == null || carListItemPrefab == null)
                return;
            
            // Очистка
            foreach (Transform child in carListContainer)
                Destroy(child.gameObject);
            
            // Создание элементов
            for (int i = 0; i < playerVehicles.Count; i++)
            {
                var car = playerVehicles[i];
                GameObject item = Instantiate(carListItemPrefab, carListContainer);
                
                var listItem = item.GetComponent<GarageCarListItem>();
                if (listItem != null)
                {
                    listItem.Initialize(car, i == selectedIndex);
                    listItem.OnClicked += () => OnCarItemSelected(i);
                }
            }
        }
        
        private void OnCarItemSelected(int index)
        {
            selectedIndex = index;
            UpdateCarList();
            DisplaySelectedCar();
        }
        
        #endregion
        
        #region Отображение
        
        private void DisplaySelectedCar()
        {
            if (selectedIndex < 0 || selectedIndex >= playerVehicles.Count)
                return;
            
            var car = playerVehicles[selectedIndex];
            
            if (carNameText != null)
                carNameText.text = car.vehicleName;
            
            if (carManufacturerText != null)
                carManufacturerText.text = car.manufacturer;
            
            if (carYearText != null)
                carYearText.text = $"{car.year}";
            
            if (currentValueText != null)
                currentValueText.text = $"{car.currentValue:F0} $";
            
            if (conditionText != null)
                conditionText.text = $"Состояние: {car.condition:F0}%";
            
            // Характеристики
            if (powerBar != null)
                powerBar.SetValue(car.currentStats.power, 0, 1000);
            
            if (torqueBar != null)
                torqueBar.SetValue(car.currentStats.torque, 0, 1000);
            
            if (weightBar != null)
                weightBar.SetValue(car.currentStats.weight, 500, 2500, true);
            
            if (gripBar != null)
                gripBar.SetValue(car.currentStats.grip, 0, 1);
            
            if (aeroBar != null)
                aeroBar.SetValue(car.currentStats.aerodynamics, 0, 1);
        }
        
        #endregion
        
        #region Действия
        
        private void OnSelectCar()
        {
            GameManager.Instance.SetCurrentVehicle(selectedIndex);
            DisplaySelectedCar();
        }
        
        private void OnUpgradeClicked()
        {
            // Переход в тюнинг
            GameManager.Instance.ChangeState(GameState.Tuning);
        }
        
        private void OnSellClicked()
        {
            if (playerVehicles.Count <= 1)
            {
                Debug.LogWarning("Нельзя продать последний автомобиль!");
                return;
            }
            
            var car = playerVehicles[selectedIndex];
            float sellPrice = car.currentValue * 0.7f; // 70% от стоимости
            
            // Подтверждение продажи
            bool confirmed = true; // TODO: Диалог подтверждения
            
            if (confirmed)
            {
                GameManager.Instance.AddMoney(sellPrice);
                playerVehicles.RemoveAt(selectedIndex);
                
                if (selectedIndex >= playerVehicles.Count)
                    selectedIndex = playerVehicles.Count - 1;
                
                GameManager.Instance.GameData.currentVehicleIndex = selectedIndex;
                
                UpdateCarList();
                DisplaySelectedCar();
            }
        }
        
        private void OnBackClicked()
        {
            GameManager.Instance.ChangeState(GameState.GameMenu);
        }
        
        #endregion
    }
    
    /// <summary>
    /// Элемент списка автомобилей
    /// </summary>
    public class GarageCarListItem : MonoBehaviour
    {
        public Text carNameText;
        public Text carStatsText;
        public Image selectedIndicator;
        public Button selectButton;
        
        public System.Action OnClicked;
        
        public void Initialize(VehicleData car, bool isSelected)
        {
            if (carNameText != null)
                carNameText.text = car.vehicleName;
            
            if (carStatsText != null)
                carStatsText.text = $"{car.currentStats.power:F0} л.с.";
            
            if (selectedIndicator != null)
                selectedIndicator.gameObject.SetActive(isSelected);
            
            if (selectButton != null)
                selectButton.onClick.AddListener(OnClicked);
        }
    }
    
    /// <summary>
    /// Полоска характеристики
    /// </summary>
    public class StatBar : MonoBehaviour
    {
        public Image fillBar;
        public Text valueText;
        public Text labelText;
        
        public void SetValue(float value, float min, float max, bool invert = false)
        {
            float normalized = (value - min) / (max - min);
            normalized = Mathf.Clamp01(normalized);
            
            if (invert)
                normalized = 1 - normalized;
            
            if (fillBar != null)
                fillBar.fillAmount = normalized;
            
            if (valueText != null)
                valueText.text = value.ToString("F1");
        }
    }
}

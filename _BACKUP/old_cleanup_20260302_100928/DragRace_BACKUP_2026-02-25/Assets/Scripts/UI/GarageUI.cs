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
        [SerializeField] private Transform carListContainer;
        [SerializeField] private GameObject carListItemPrefab;

        [Header("Отображение автомобиля")]
        [SerializeField] private Image carImage;
        [SerializeField] private Text carNameText;
        [SerializeField] private Text carManufacturerText;
        [SerializeField] private Text carYearText;

        [Header("Характеристики")]
        [SerializeField] private StatBar powerBar;
        [SerializeField] private StatBar torqueBar;
        [SerializeField] private StatBar weightBar;
        [SerializeField] private StatBar gripBar;
        [SerializeField] private StatBar aeroBar;

        [Header("Кнопки")]
        [SerializeField] private Button selectButton;
        [SerializeField] private Button upgradeButton;
        [SerializeField] private Button sellButton;
        [SerializeField] private Button backButton;

        [Header("Информация")]
        [SerializeField] private Text currentValueText;
        [SerializeField] private Text conditionText;

        private List<VehicleData> playerVehicles;
        private int selectedIndex;
        
        private void Start()
        {
            playerVehicles = GameManager.Instance.GameData.playerVehicles;
            selectedIndex = GameManager.Instance.GameData.currentVehicleIndex;
            
            UpdateCarList();
            DisplaySelectedCar();
        }
        
        #region Список автомобилей
        
        private void UpdateCarList()
        {
            if (carListContainer == null || carListItemPrefab == null)
                return;
            
            foreach (Transform child in carListContainer)
                Destroy(child.gameObject);
            
            for (int i = 0; i < playerVehicles.Count; i++)
            {
                var car = playerVehicles[i];
                GameObject item = Instantiate(carListItemPrefab, carListContainer);
                
                var listItem = item.GetComponent<GarageCarListItem>();
                if (listItem != null)
                {
                    listItem.Initialize(car, i == selectedIndex);
                    int index = i;
                    listItem.selectButton.onClick.AddListener(() => OnCarItemSelected(index));
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
            
            carNameText.text = car.vehicleName;
            carManufacturerText.text = car.manufacturer;
            carYearText.text = car.year.ToString();
            currentValueText.text = $"{car.currentValue:F0} $";
            conditionText.text = $"Состояние: {car.condition:F0}%";
            
            powerBar.SetValue(car.currentStats.power, 0, 1000);
            torqueBar.SetValue(car.currentStats.torque, 0, 1000);
            weightBar.SetValue(car.currentStats.weight, 500, 2500, true);
            gripBar.SetValue(car.currentStats.grip, 0, 1);
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
            float sellPrice = car.currentValue * 0.7f;
            
            GameManager.Instance.AddMoney(sellPrice);
            playerVehicles.RemoveAt(selectedIndex);
            
            if (selectedIndex >= playerVehicles.Count)
                selectedIndex = playerVehicles.Count - 1;
            
            GameManager.Instance.GameData.currentVehicleIndex = selectedIndex;
            
            UpdateCarList();
            DisplaySelectedCar();
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
        
        public void Initialize(VehicleData car, bool isSelected)
        {
            if (carNameText != null)
                carNameText.text = car.vehicleName;
            
            if (carStatsText != null)
                carStatsText.text = $"{car.currentStats.power:F0} л.с.";

            if (selectedIndicator != null)
                selectedIndicator.gameObject.SetActive(isSelected);
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

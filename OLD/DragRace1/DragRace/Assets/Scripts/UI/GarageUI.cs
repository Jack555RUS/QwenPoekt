using UnityEngine;
using UnityEngine.UI;
using System.Collections.Generic;
using DragRace.Core;
using DragRace.Economy;
using DragRace.Data;

namespace DragRace.UI
{
    /// <summary>
    /// UI Гаража - выбор и просмотр автомобилей
    /// </summary>
    public class GarageUI : MonoBehaviour
    {
        [Header("Панели")]
        [Tooltip("Основная панель гаража")]
        public GameObject garagePanel;
        
        [Tooltip("Панель выбора авто")]
        public GameObject carSelectionPanel;
        
        [Tooltip("Панель информации об авто")]
        public GameObject carInfoPanel;
        
        [Header("Элементы списка")]
        [Tooltip("Контейнер для списка авто")]
        public Transform carListContent;
        
        [Tooltip("Префаб элемента списка")]
        public GameObject carListItemPrefab;
        
        [Header("Информация об авто")]
        [Tooltip("Изображение авто")]
        public Image carImage;
        
        [Tooltip("Название авто")]
        public Text carNameText;
        
        [Tooltip("Производитель")]
        public Text manufacturerText;
        
        [Tooltip("Класс авто")]
        public Text carClassText;
        
        [Header("Характеристики")]
        [Tooltip("Текст мощности")]
        public Text powerText;
        
        [Tooltip("Текст крутящего момента")]
        public Text torqueText;
        
        [Tooltip("Текст веса")]
        public Text weightText;
        
        [Tooltip("Текст сцепления")]
        public Text gripText;
        
        [Tooltip("Текст цены")]
        public Text priceText;
        
        [Header("Кнопки")]
        [Tooltip("Кнопка выбора авто")]
        public Button selectCarButton;
        
        [Tooltip("Кнопка продажи авто")]
        public Button sellCarButton;
        
        [Tooltip("Кнопка назад")]
        public Button backButton;
        
        [Header("Данные")]
        [Tooltip("База данных автомобилей")]
        public Data.CarDatabase carDatabase;
        
        // Состояние
        private List<Data.VehicleData> playerCars = new List<Data.VehicleData>();
        private Data.VehicleData selectedCar;
        private Data.VehicleData currentCar;
        
        private void Awake()
        {
            InitializeGarage();
        }
        
        private void InitializeGarage()
        {
            Debug.Log("🏠 GarageUI инициализирован");
            
            // Загрузка автомобилей игрока
            LoadPlayerCars();
            
            // Подписка на кнопки
            selectCarButton?.onClick.AddListener(OnSelectCarClicked);
            sellCarButton?.onClick.AddListener(OnSellCarClicked);
            backButton?.onClick.AddListener(OnBackClicked);
        }
        
        private void OnCarSelected(Data.VehicleData car)
        {
            SelectCar(car);
        }
        
        /// <summary>
        /// Загрузка автомобилей игрока
        /// </summary>
        private void LoadPlayerCars()
        {
            playerCars.Clear();
            
            // Получаем данные о владельстве из SaveManager
            var saveData = Core.SaveManager.Instance?.GetCurrentData();
            if (saveData != null && saveData.ownedCars != null)
            {
                foreach (string carId in saveData.ownedCars)
                {
                    Data.VehicleData car = carDatabase.GetCarById(carId);
                    if (car != null)
                    {
                        playerCars.Add(car);
                    }
                }
            }
            
            // Если нет машин, добавляем стартовую
            if (playerCars.Count == 0 && carDatabase != null)
            {
                Data.VehicleData starterCar = carDatabase.GetStarterCar();
                if (starterCar != null)
                {
                    playerCars.Add(starterCar);
                    currentCar = starterCar;
                }
            }
            
            Debug.Log($"🚗 Загружено {playerCars.Count} автомобилей");
            
            UpdateCarList();
        }
        
        /// <summary>
        /// Обновление списка автомобилей
        /// </summary>
        private void UpdateCarList()
        {
            // Очистка списка
            foreach (Transform child in carListContent)
            {
                Destroy(child.gameObject);
            }
            
            // Создание элементов
            foreach (var car in playerCars)
            {
                GameObject item = Instantiate(carListItemPrefab, carListContent);
                
                CarListItem listItem = item.GetComponent<CarListItem>();
                if (listItem == null)
                {
                    listItem = item.AddComponent<CarListItem>();
                }
                
                listItem.Initialize(car, car == currentCar, OnCarSelected);
            }
            
            // Выбор первого авто
            if (playerCars.Count > 0 && selectedCar == null)
            {
                SelectCar(playerCars[0]);
            }
        }
        
        /// <summary>
        /// Выбор автомобиля
        /// </summary>
        private void SelectCar(Data.VehicleData car)
        {
            selectedCar = car;
            
            // Обновление UI
            UpdateCarInfo();
            
            // Обновление выделения в списке
            foreach (Transform child in carListContent)
            {
                CarListItem listItem = child.GetComponent<CarListItem>();
                if (listItem != null)
                {
                    listItem.SetSelected(listItem.Car == car);
                }
            }
        }
        
        /// <summary>
        /// Обновление информации об авто
        /// </summary>
        private void UpdateCarInfo()
        {
            if (selectedCar == null) return;
            
            carNameText.text = selectedCar.vehicleName;
            manufacturerText.text = selectedCar.manufacturer;
            carClassText.text = $"Class: {selectedCar.vehicleClass}";
            
            powerText.text = $"{selectedCar.baseStats.power:F0} HP";
            torqueText.text = $"{selectedCar.baseStats.torque:F0} Nm";
            weightText.text = $"{selectedCar.baseStats.weight:F0} kg";
            gripText.text = $"{selectedCar.baseStats.grip:F2}";
            
            int price = EconomyManager.Instance?.CalculateCarPrice(selectedCar) ?? selectedCar.basePrice;
            priceText.text = $"${price:N0}";
            
            // Изображение
            if (carImage != null && selectedCar.carSprite != null)
            {
                carImage.sprite = selectedCar.carSprite;
                carImage.color = selectedCar.carColor;
            }
            
            Debug.Log($"🚗 Выбран: {selectedCar.manufacturer} {selectedCar.vehicleName}");
        }
        
        #region Button Handlers
        
        private void OnSelectCarClicked()
        {
            if (selectedCar != null && selectedCar != currentCar)
            {
                // Смена текущего авто
                currentCar = selectedCar;
                
                // Сохранение выбора
                var saveData = Core.SaveManager.Instance?.GetCurrentData();
                if (saveData != null)
                {
                    saveData.currentCarId = selectedCar.vehicleId;
                }
                
                Debug.Log($"✅ Выбран автомобиль: {selectedCar.vehicleName}");
                
                // Закрытие гаража
                gameObject.SetActive(false);
            }
        }
        
        private void OnSellCarClicked()
        {
            if (selectedCar != null && selectedCar != currentCar)
            {
                var economy = EconomyManager.Instance;
                if (economy != null)
                {
                    int sellPrice = economy.SellCar(selectedCar, 0.7f);
                    
                    // Удаление из списка
                    playerCars.Remove(selectedCar);
                    UpdateCarList();
                    
                    Debug.Log($"💰 Продан {selectedCar.vehicleName} за ${sellPrice}");
                }
            }
        }
        
        private void OnBackClicked()
        {
            gameObject.SetActive(false);
        }
        
        #endregion
        
        #region Public Methods
        
        /// <summary>
        /// Показать гараж
        /// </summary>
        public void ShowGarage()
        {
            gameObject.SetActive(true);
            LoadPlayerCars();
        }
        
        /// <summary>
        /// Добавить автомобиль в гараж
        /// </summary>
        public void AddCar(Data.VehicleData car)
        {
            if (!playerCars.Contains(car))
            {
                playerCars.Add(car);
                UpdateCarList();
                Debug.Log($"🎉 Добавлен автомобиль: {car.vehicleName}");
            }
        }
        
        #endregion
    }
    
    /// <summary>
    /// Элемент списка автомобилей
    /// </summary>
    public class CarListItem : MonoBehaviour
    {
        public Text carNameText;
        public Text carClassText;
        public Image backgroundImage;
        
        public Data.VehicleData Car { get; private set; }
        private System.Action<Data.VehicleData> onSelect;
        
        public void Initialize(Data.VehicleData car, bool isSelected, System.Action<Data.VehicleData> onSelectCallback)
        {
            Car = car;
            onSelect = onSelectCallback;
            
            if (carNameText != null)
                carNameText.text = car.vehicleName;
            
            if (carClassText != null)
                carClassText.text = car.vehicleClass.ToString();
            
            SetSelected(isSelected);
            
            // Кнопка
            Button button = GetComponent<Button>();
            if (button != null)
            {
                button.onClick.AddListener(() => {
                    if (onSelect != null)
                        onSelect(Car);
                });
            }
        }
        
        public void SetSelected(bool selected)
        {
            if (backgroundImage != null)
            {
                backgroundImage.color = selected ? 
                    new Color(0.2f, 0.6f, 0.2f, 1f) : 
                    new Color(0.3f, 0.3f, 0.3f, 0.5f);
            }
        }
    }
}

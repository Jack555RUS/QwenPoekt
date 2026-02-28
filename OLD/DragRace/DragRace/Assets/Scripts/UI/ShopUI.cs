using UnityEngine;
using UnityEngine.UI;
using DragRace.Core;
using DragRace.Data;
using System.Collections.Generic;

namespace DragRace.UI
{
    /// <summary>
    /// Магазин - покупка автомобилей и запчастей
    /// </summary>
    public class ShopUI : MonoBehaviour
    {
        [Header("Вкладки")]
        public Button carsTab;
        public Button partsTab;
        
        [Header("Панели")]
        public GameObject carsPanel;
        public GameObject partsPanel;
        
        [Header("Список автомобилей")]
        public Transform carsListContainer;
        public GameObject carListItemPrefab;
        
        [Header("Список запчастей")]
        public Transform partsListContainer;
        public GameObject partListItemPrefab;
        
        [Header("Детали автомобиля")]
        public Image carImage;
        public Text carNameText;
        public Text carManufacturerText;
        public Text carPriceText;
        public Text carStatsText;
        
        [Header("Кнопки")]
        public Button buyButton;
        public Button backButton;
        
        [Header("Фильтры")]
        public Dropdown manufacturerFilter;
        public Dropdown priceRangeFilter;
        
        private bool showingCars = true;
        private CarModel selectedCar;
        private VehiclePart selectedPart;
        
        private List<CarModel> availableCars;
        private List<VehiclePart> availableParts;
        
        private void Start()
        {
            SubscribeToEvents();
            LoadCars();
            LoadParts();
            UpdateFilters();
        }
        
        private void OnDestroy()
        {
            UnsubscribeFromEvents();
        }
        
        private void SubscribeToEvents()
        {
            if (carsTab != null)
                carsTab.onClick.AddListener(() => SwitchTab(true));
            
            if (partsTab != null)
                partsTab.onClick.AddListener(() => SwitchTab(false));
            
            if (buyButton != null)
                buyButton.onClick.AddListener(OnBuyClicked);
            
            if (backButton != null)
                backButton.onClick.AddListener(OnBackClicked);
            
            if (manufacturerFilter != null)
                manufacturerFilter.onValueChanged.AddListener(OnFilterChanged);
            
            if (priceRangeFilter != null)
                priceRangeFilter.onValueChanged.AddListener(OnFilterChanged);
        }
        
        private void UnsubscribeFromEvents()
        {
            if (carsTab != null)
                carsTab.onClick.RemoveListener(() => SwitchTab(true));
            
            if (partsTab != null)
                partsTab.onClick.RemoveListener(() => SwitchTab(false));
            
            if (buyButton != null)
                buyButton.onClick.RemoveListener(OnBuyClicked);
            
            if (backButton != null)
                backButton.onClick.RemoveListener(OnBackClicked);
            
            if (manufacturerFilter != null)
                manufacturerFilter.onValueChanged.RemoveListener(OnFilterChanged);
            
            if (priceRangeFilter != null)
                priceRangeFilter.onValueChanged.RemoveListener(OnFilterChanged);
        }
        
        #region Вкладки
        
        private void SwitchTab(bool showCars)
        {
            showingCars = showCars;
            carsPanel.SetActive(showCars);
            partsPanel.SetActive(!showCars);
        }
        
        #endregion
        
        #region Загрузка автомобилей
        
        private void LoadCars()
        {
            availableCars = GameManager.Instance.carDatabase?.carModels;
            
            if (carsListContainer == null || carListItemPrefab == null)
                return;
            
            // Очистка
            foreach (Transform child in carsListContainer)
                Destroy(child.gameObject);
            
            // Создание элементов
            if (availableCars == null) return;
            
            foreach (var car in availableCars)
            {
                // Проверка: не куплен ли уже
                if (IsCarOwned(car.id))
                    continue;
                
                GameObject item = Instantiate(carListItemPrefab, carsListContainer);
                
                var listItem = item.GetComponent<ShopCarListItem>();
                if (listItem != null)
                {
                    listItem.Initialize(car);
                    listItem.OnClicked += () => OnCarSelected(car);
                }
            }
        }
        
        private bool IsCarOwned(string carId)
        {
            var vehicles = GameManager.Instance.GameData.playerVehicles;
            return vehicles.Exists(v => v.modelName == carId);
        }
        
        #endregion
        
        #region Загрузка запчастей
        
        private void LoadParts()
        {
            availableParts = new List<VehiclePart>();
            
            var partsDb = GameManager.Instance.partsDatabase;
            if (partsDb == null) return;
            
            availableParts.AddRange(partsDb.engines.ConvertAll(e => e as VehiclePart));
            availableParts.AddRange(partsDb.transmissions.ConvertAll(t => t as VehiclePart));
            availableParts.AddRange(partsDb.tires.ConvertAll(t => t as VehiclePart));
            availableParts.AddRange(partsDb.nitroSystems.ConvertAll(n => n as VehiclePart));
            
            if (partsListContainer == null || partListItemPrefab == null)
                return;
            
            // Очистка
            foreach (Transform child in partsListContainer)
                Destroy(child.gameObject);
            
            // Создание элементов
            foreach (var part in availableParts)
            {
                GameObject item = Instantiate(partListItemPrefab, partsListContainer);
                
                var listItem = item.GetComponent<ShopPartListItem>();
                if (listItem != null)
                {
                    listItem.Initialize(part);
                    listItem.OnClicked += () => OnPartSelected(part);
                }
            }
        }
        
        #endregion
        
        #region Выбор
        
        private void OnCarSelected(CarModel car)
        {
            selectedCar = car;
            DisplayCarInfo(car);
        }
        
        private void OnPartSelected(VehiclePart part)
        {
            selectedPart = part;
            // TODO: Показать информацию о запчасти
        }
        
        private void DisplayCarInfo(CarModel car)
        {
            if (carImage != null)
                carImage.sprite = car.sideView;
            
            if (carNameText != null)
                carNameText.text = car.displayName;
            
            if (carManufacturerText != null)
                carManufacturerText.text = car.manufacturer;
            
            if (carPriceText != null)
                carPriceText.text = $"{car.basePrice:F0} $";
            
            if (carStatsText != null)
            {
                carStatsText.text = $@"
Мощность: {car.baseStats.power:F0} л.с.
Крутящий момент: {car.baseStats.torque:F0} Нм
Вес: {car.baseStats.weight:F0} кг
Сцепление: {car.baseStats.grip:F2}
                ";
            }
        }
        
        #endregion
        
        #region Покупка
        
        private void OnBuyClicked()
        {
            if (showingCars)
            {
                BuyCar();
            }
            else
            {
                BuyPart();
            }
        }
        
        private void BuyCar()
        {
            if (selectedCar == null) return;
            
            if (!GameManager.Instance.HasMoney(selectedCar.basePrice))
            {
                Debug.LogWarning("Недостаточно денег!");
                return;
            }
            
            GameManager.Instance.SpendMoney(selectedCar.basePrice);
            
            // Добавление автомобиля в гараж
            var vehicleData = new VehicleData
            {
                vehicleId = System.Guid.NewGuid().ToString(),
                vehicleName = selectedCar.displayName,
                modelName = selectedCar.id,
                manufacturer = selectedCar.manufacturer,
                year = selectedCar.year,
                baseStats = selectedCar.baseStats,
                currentStats = selectedCar.baseStats,
                isOwned = true,
                purchasePrice = selectedCar.basePrice,
                currentValue = selectedCar.basePrice
            };
            
            GameManager.Instance.GameData.playerVehicles.Add(vehicleData);
            
            Debug.Log($"Куплен автомобиль: {selectedCar.displayName}");
            
            // Обновление списка
            LoadCars();
            selectedCar = null;
        }
        
        private void BuyPart()
        {
            if (selectedPart == null) return;
            
            if (!GameManager.Instance.HasMoney(selectedPart.buyPrice))
            {
                Debug.LogWarning("Недостаточно денег!");
                return;
            }
            
            GameManager.Instance.SpendMoney(selectedPart.buyPrice);
            
            // Добавление в инвентарь
            var partData = new VehiclePartData
            {
                partId = selectedPart.partId,
                partName = selectedPart.partName,
                partType = selectedPart.partType,
                rarity = selectedPart.rarity,
                buyPrice = selectedPart.buyPrice,
                sellPrice = selectedPart.sellPrice,
                isInstalled = false,
                isUsed = false
            };
            
            GameManager.Instance.GameData.inventory.Add(partData);
            
            Debug.Log($"Куплена запчасть: {selectedPart.partName}");
        }
        
        #endregion
        
        #region Фильтры
        
        private void UpdateFilters()
        {
            if (manufacturerFilter == null) return;
            
            var manufacturers = new List<string> { "Все" };
            
            if (availableCars != null)
            {
                var uniqueManufacturers = new HashSet<string>();
                foreach (var car in availableCars)
                {
                    if (uniqueManufacturers.Add(car.manufacturer))
                        manufacturers.Add(car.manufacturer);
                }
            }
            
            manufacturerFilter.ClearOptions();
            manufacturerFilter.AddOptions(manufacturers);
        }
        
        private void OnFilterChanged(int index)
        {
            // Применение фильтров
            // TODO: Фильтрация списка автомобилей
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
    /// Элемент списка автомобилей в магазине
    /// </summary>
    public class ShopCarListItem : MonoBehaviour
    {
        public Text carNameText;
        public Text carPriceText;
        public Image carImage;
        public Button buyButton;
        
        public System.Action OnClicked;
        
        public void Initialize(CarModel car)
        {
            if (carNameText != null)
                carNameText.text = car.displayName;
            
            if (carPriceText != null)
                carPriceText.text = $"{car.basePrice:F0} $";
            
            if (carImage != null)
                carImage.sprite = car.sideView;
            
            if (buyButton != null)
                buyButton.onClick.AddListener(() => OnClicked?.Invoke());
        }
    }
    
    /// <summary>
    /// Элемент списка запчастей в магазине
    /// </summary>
    public class ShopPartListItem : MonoBehaviour
    {
        public Text partNameText;
        public Text partPriceText;
        public Text partTypeText;
        public Image rarityBackground;
        public Button buyButton;
        
        public System.Action OnClicked;
        
        public void Initialize(VehiclePart part)
        {
            if (partNameText != null)
                partNameText.text = part.partName;
            
            if (partPriceText != null)
                partPriceText.text = $"{part.buyPrice:F0} $";
            
            if (partTypeText != null)
                partTypeText.text = part.partType.ToString();
            
            if (buyButton != null)
                buyButton.onClick.AddListener(() => OnClicked?.Invoke());
        }
    }
}

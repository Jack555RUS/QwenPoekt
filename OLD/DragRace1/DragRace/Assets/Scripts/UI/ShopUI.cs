using UnityEngine;
using UnityEngine.UI;
using System.Collections.Generic;
using DragRace.Core;
using DragRace.Career;
using DragRace.Economy;
using DragRace.Data;

namespace DragRace.UI
{
    /// <summary>
    /// UI Магазина - покупка/продажа автомобилей и запчастей
    /// </summary>
    public class ShopUI : MonoBehaviour
    {
        [Header("Панели")]
        [Tooltip("Основная панель магазина")]
        public GameObject shopPanel;
        
        [Tooltip("Панель автомобилей")]
        public GameObject carsPanel;
        
        [Tooltip("Панель запчастей")]
        public GameObject partsPanel;
        
        [Header("Вкладки")]
        [Tooltip("Кнопка автомобилей")]
        public Button carsTabButton;
        
        [Tooltip("Кнопка запчастей")]
        public Button partsTabButton;
        
        [Header("Список автомобилей")]
        [Tooltip("Контейнер для списка авто")]
        public Transform carsListContent;
        
        [Tooltip("Префаб элемента авто")]
        public GameObject carListItemPrefab;
        
        [Header("Список запчастей")]
        [Tooltip("Контейнер для списка запчастей")]
        public Transform partsListContent;
        
        [Tooltip("Префаб элемента запчасти")]
        public GameObject partListItemPrefab;
        
        [Header("Информация")]
        [Tooltip("Текст денег")]
        public Text moneyText;
        
        [Header("Данные")]
        [Tooltip("База данных автомобилей")]
        public Data.CarDatabase carDatabase;
        
        [Tooltip("База запчастей")]
        public List<Data.VehicleUpgrade> availableParts = new List<Data.VehicleUpgrade>();
        
        // Состояние
        
        private void Awake()
        {
            InitializeShop();
        }
        
        private void InitializeShop()
        {
            Debug.Log("🏪 ShopUI инициализирован");
            
            // Подписка на вкладки
            carsTabButton?.onClick.AddListener(() => ShowCarsTab());
            partsTabButton?.onClick.AddListener(() => ShowPartsTab());
            
            // Обновление денег
            UpdateMoneyDisplay();
            
            // Подписка на событие изменения денег
            var economy = EconomyManager.Instance;
            if (economy != null)
            {
                economy.OnMoneyChanged += (amount, change) => UpdateMoneyDisplay();
            }
        }
        
        #region Tab Management
        
        private void ShowCarsTab()
        {
            carsPanel.SetActive(true);
            partsPanel.SetActive(false);

            UpdateCarsList();
        }

        private void ShowPartsTab()
        {
            carsPanel.SetActive(false);
            partsPanel.SetActive(true);
            
            UpdatePartsList();
        }
        
        #endregion
        
        #region Money Display
        
        private void UpdateMoneyDisplay()
        {
            var economy = EconomyManager.Instance;
            if (economy != null && moneyText != null)
            {
                moneyText.text = $"${economy.CurrentMoney:N0}";
            }
        }
        
        #endregion
        
        #region Cars List
        
        private void UpdateCarsList()
        {
            // Очистка
            foreach (Transform child in carsListContent)
            {
                Destroy(child.gameObject);
            }
            
            // Получение доступных авто для текущего уровня
            var career = CareerManager.Instance;
            int currentTier = career != null ? career.CurrentTier : 0;
            
            if (carDatabase == null) return;
            
            List<Data.VehicleData> availableCars = carDatabase.GetCarsForTier(currentTier);
            
            // Получение уже купленных авто
            var saveData = Core.SaveManager.Instance?.GetCurrentData();
            List<string> ownedCarIds = saveData?.ownedCars ?? new List<string>();
            
            // Создание элементов
            foreach (var car in availableCars)
            {
                GameObject item = Instantiate(carListItemPrefab, carsListContent);
                
                ShopCarListItem listItem = item.GetComponent<ShopCarListItem>();
                if (listItem == null)
                {
                    listItem = item.AddComponent<ShopCarListItem>();
                }
                
                bool isOwned = ownedCarIds.Contains(car.vehicleId);
                int price = EconomyManager.Instance?.CalculateCarPrice(car) ?? car.basePrice;
                
                listItem.Initialize(car, price, isOwned, OnCarBuyClicked, OnCarViewClicked);
            }
        }
        
        private void OnCarBuyClicked(Data.VehicleData car, int price)
        {
            var economy = EconomyManager.Instance;
            if (economy != null)
            {
                if (economy.BuyCar(car))
                {
                    // Добавление в гараж
                    var saveData = Core.SaveManager.Instance?.GetCurrentData();
                    if (saveData != null && !saveData.ownedCars.Contains(car.vehicleId))
                    {
                        saveData.ownedCars.Add(car.vehicleId);
                    }
                    
                    Debug.Log($"✅ Куплен {car.manufacturer} {car.vehicleName}");
                    UpdateCarsList();
                }
            }
        }
        
        private void OnCarViewClicked(Data.VehicleData car)
        {
            Debug.Log($"👁️ Просмотр: {car.manufacturer} {car.vehicleName}");
            // TODO: Открыть детальную информацию
        }
        
        #endregion
        
        #region Parts List
        
        private void UpdatePartsList()
        {
            // Очистка
            foreach (Transform child in partsListContent)
            {
                Destroy(child.gameObject);
            }
            
            // Создание элементов
            foreach (var part in availableParts)
            {
                GameObject item = Instantiate(partListItemPrefab, partsListContent);
                
                ShopPartListItem listItem = item.GetComponent<ShopPartListItem>();
                if (listItem == null)
                {
                    listItem = item.AddComponent<ShopPartListItem>();
                }
                
                var economy = EconomyManager.Instance;
                int price = economy != null ? economy.CalculatePartPrice(part, false) : part.price;
                
                listItem.Initialize(part, price, OnPartBuyClicked);
            }
        }
        
        private void OnPartBuyClicked(Data.VehicleUpgrade part, int price)
        {
            var economy = EconomyManager.Instance;
            if (economy != null)
            {
                if (economy.BuyPart(part, false))
                {
                    // Добавление в инвентарь
                    var saveData = Core.SaveManager.Instance?.GetCurrentData();
                    if (saveData != null)
                    {
                        if (!saveData.inventory.ContainsKey(part.partId))
                        {
                            saveData.inventory[part.partId] = 0;
                        }
                        saveData.inventory[part.partId]++;
                    }
                    
                    Debug.Log($"✅ Куплена запчасть: {part.partName}");
                    UpdatePartsList();
                }
            }
        }
        
        #endregion
        
        #region Public Methods
        
        /// <summary>
        /// Показать магазин
        /// </summary>
        public void ShowShop()
        {
            gameObject.SetActive(true);
            ShowCarsTab();
            UpdateMoneyDisplay();
        }
        
        #endregion
    }
    
    /// <summary>
    /// Элемент списка автомобилей в магазине
    /// </summary>
    public class ShopCarListItem : MonoBehaviour
    {
        public Text carNameText;
        public Text carClassText;
        public Text priceText;
        public Button buyButton;
        public Button viewButton;
        public Text ownedText;
        
        private Data.VehicleData car;
        
        public void Initialize(Data.VehicleData carData, int price, bool isOwned, 
            System.Action<Data.VehicleData, int> onBuy, 
            System.Action<Data.VehicleData> onView)
        {
            car = carData;
            
            if (carNameText != null)
                carNameText.text = $"{carData.manufacturer} {carData.vehicleName}";
            
            if (carClassText != null)
                carClassText.text = carData.vehicleClass.ToString();
            
            if (priceText != null)
                priceText.text = $"${price:N0}";
            
            if (ownedText != null)
                ownedText.gameObject.SetActive(isOwned);
            
            if (buyButton != null)
            {
                buyButton.interactable = !isOwned;
                buyButton.onClick.AddListener(() => {
                    if (onBuy != null) onBuy(carData, price);
                });
            }
            
            if (viewButton != null)
            {
                viewButton.onClick.AddListener(() => {
                    if (onView != null) onView(carData);
                });
            }
        }
    }
    
    /// <summary>
    /// Элемент списка запчастей в магазине
    /// </summary>
    public class ShopPartListItem : MonoBehaviour
    {
        public Text partNameText;
        public Text partTypeText;
        public Text rarityText;
        public Text priceText;
        public Button buyButton;
        
        public void Initialize(Data.VehicleUpgrade part, int price, System.Action<Data.VehicleUpgrade, int> onBuy)
        {
            if (partNameText != null)
                partNameText.text = part.partName;
            
            if (partTypeText != null)
                partTypeText.text = part.partType.ToString();
            
            if (rarityText != null)
                rarityText.text = part.rarity.ToString();
            
            if (priceText != null)
                priceText.text = $"${price:N0}";
            
            if (buyButton != null)
            {
                buyButton.onClick.AddListener(() => {
                    if (onBuy != null) onBuy(part, price);
                });
            }
        }
    }
}

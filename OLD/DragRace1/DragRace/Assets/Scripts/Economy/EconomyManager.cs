using UnityEngine;

namespace DragRace.Economy
{
    /// <summary>
    /// Менеджер экономики игры
    /// Управляет деньгами, наградами, ценами на авто и запчасти
    /// Баланс из Plan.txt: 8-15 гонок на покупку авто
    /// </summary>
    public class EconomyManager : MonoBehaviour
    {
        #region Singleton
        
        private static EconomyManager _instance;
        
        public static EconomyManager Instance
        {
            get
            {
                if (_instance == null)
                {
                    _instance = FindFirstObjectByType<EconomyManager>();
                    if (_instance == null)
                    {
                        GameObject go = new GameObject("EconomyManager");
                        _instance = go.AddComponent<EconomyManager>();
                        DontDestroyOnLoad(go);
                    }
                }
                return _instance;
            }
        }
        
        #endregion
        
        #region Constants (из Plan.txt)
        
        /// <summary> Стартовые деньги ($) </summary>
        public const int STARTING_MONEY = 10000;
        
        /// <summary> Базовая награда за 1/4 мили ($) </summary>
        public const int BASE_REWARD_QUARTER_MILE = 200;
        
        /// <summary> Минимальная цена авто ($) </summary>
        public const int MIN_CAR_PRICE = 35000;
        
        /// <summary> Максимальная цена авто ($) </summary>
        public const int MAX_CAR_PRICE = 160000;
        
        /// <summary> Скидка на б/у запчасти (%) </summary>
        public const float USED_PART_DISCOUNT = 0.3f;
        
        #endregion
        
        #region Configuration
        
        [Header("Множители наград")]
        [Tooltip("Множитель за дистанцию 1/8 мили")]
        public float eighthMileMultiplier = 0.6f;
        
        [Tooltip("Множитель за дистанцию 1/4 мили")]
        public float quarterMileMultiplier = 1.0f;
        
        [Tooltip("Множитель за дистанцию 1/2 мили")]
        public float halfMileMultiplier = 1.8f;
        
        [Tooltip("Множитель за дистанцию 1 миля")]
        public float fullMileMultiplier = 3.0f;
        
        [Header("Множители сложности")]
        [Tooltip("Множитель за уровень карьеры (Tier)")]
        public float tierMultiplier = 1.5f;
        
        [Tooltip("Множитель за звезду (0-3)")]
        public float starBonusMultiplier = 0.2f;
        
        [Header("Цены")]
        [Tooltip("Базовая стоимость улучшения ($)")]
        public int baseUpgradeCost = 5000;
        
        [Tooltip("Множитель цены от мощности")]
        public float powerPriceMultiplier = 100f;
        
        #endregion
        
        #region State
        
        private int currentMoney = STARTING_MONEY;
        private int totalEarned = 0;
        private int totalSpent = 0;
        private int racesCompleted = 0;
        
        #endregion
        
        #region Events
        
        public delegate void MoneyChangedHandler(int newAmount, int change);
        public event MoneyChangedHandler OnMoneyChanged;
        
        public delegate void RaceRewardHandler(int baseReward, int finalReward, int stars);
        public event RaceRewardHandler OnRaceRewardCalculated;
        
        #endregion
        
        #region Properties
        
        public int CurrentMoney => currentMoney;
        public int TotalEarned => totalEarned;
        public int TotalSpent => totalSpent;
        public int RacesCompleted => racesCompleted;
        
        #endregion
        
        #region Unity Methods
        
        private void Awake()
        {
            if (_instance != null && _instance != this)
            {
                Destroy(gameObject);
                return;
            }
            _instance = this;
            DontDestroyOnLoad(gameObject);
            
            Debug.Log("💰 EconomyManager инициализирован");
            Debug.Log($"   Стартовые деньги: ${STARTING_MONEY}");
        }
        
        #endregion
        
        #region Money Operations
        
        /// <summary>
        /// Добавить деньги
        /// </summary>
        public void AddMoney(int amount, string source = "Unknown")
        {
            int oldAmount = currentMoney;
            currentMoney += amount;
            totalEarned += amount;
            
            Debug.Log($"💵 +${amount} от {source} (было: ${oldAmount}, стало: ${currentMoney})");
            
            OnMoneyChanged?.Invoke(currentMoney, amount);
        }
        
        /// <summary>
        /// Убрать деньги
        /// </summary>
        public bool RemoveMoney(int amount, string source = "Unknown")
        {
            if (currentMoney < amount)
            {
                Debug.LogWarning($"❌ Недостаточно денег! Нужно: ${amount}, Есть: ${currentMoney}");
                return false;
            }
            
            int oldAmount = currentMoney;
            currentMoney -= amount;
            totalSpent += amount;
            
            Debug.Log($"💸 -${amount} на {source} (было: ${oldAmount}, стало: ${currentMoney})");
            
            OnMoneyChanged?.Invoke(currentMoney, -amount);
            return true;
        }
        
        /// <summary>
        /// Проверить наличие денег
        /// </summary>
        public bool HasMoney(int amount)
        {
            return currentMoney >= amount;
        }
        
        /// <summary>
        /// Сброс экономики
        /// </summary>
        public void ResetEconomy()
        {
            currentMoney = STARTING_MONEY;
            totalEarned = 0;
            totalSpent = 0;
            racesCompleted = 0;
            
            Debug.Log("🔄 Экономика сброшена");
        }
        
        #endregion
        
        #region Race Rewards
        
        /// <summary>
        /// Рассчитать награду за гонку
        /// </summary>
        public int CalculateRaceReward(float distance, int tier, int stars, bool isTestRun = false)
        {
            if (isTestRun)
            {
                Debug.Log("🧪 Тестовый заезд - награда не начисляется");
                return 0;
            }
            
            // Базовая награда
            int baseReward = BASE_REWARD_QUARTER_MILE;
            
            // Множитель дистанции
            float distanceMultiplier = GetDistanceMultiplier(distance);
            
            // Множитель уровня карьеры
            float tierMultiplier = Mathf.Pow(this.tierMultiplier, tier);
            
            // Бонус за звёзды
            float starBonus = 1f + (stars * starBonusMultiplier);
            
            // Финальная награда
            int finalReward = Mathf.FloorToInt(
                baseReward * 
                distanceMultiplier * 
                tierMultiplier * 
                starBonus
            );
            
            Debug.Log($"🏆 Награда за гонку:");
            Debug.Log($"   База: ${baseReward}");
            Debug.Log($"   Дистанция: x{distanceMultiplier:F2}");
            Debug.Log($"   Уровень: x{tierMultiplier:F2}");
            Debug.Log($"   Звёзды: x{starBonus:F2} ({stars}/3)");
            Debug.Log($"   Итого: ${finalReward}");
            
            OnRaceRewardCalculated?.Invoke(baseReward, finalReward, stars);
            
            return finalReward;
        }
        
        /// <summary>
        /// Получить множитель дистанции
        /// </summary>
        public float GetDistanceMultiplier(float distanceMeters)
        {
            // 1/8 мили = 201м
            if (distanceMeters <= 201f) return eighthMileMultiplier;
            
            // 1/4 мили = 402м
            if (distanceMeters <= 402f) return quarterMileMultiplier;
            
            // 1/2 мили = 804м
            if (distanceMeters <= 804f) return halfMileMultiplier;
            
            // 1 миля = 1609м
            return fullMileMultiplier;
        }
        
        /// <summary>
        /// Начислить награду за гонку
        /// </summary>
        public void AwardRaceReward(float distance, int tier, int stars, bool isTestRun = false)
        {
            int reward = CalculateRaceReward(distance, tier, stars, isTestRun);
            
            if (reward > 0)
            {
                AddMoney(reward, "Гонка");
                racesCompleted++;
            }
        }
        
        #endregion
        
        #region Car Prices
        
        /// <summary>
        /// Рассчитать цену автомобиля
        /// </summary>
        public int CalculateCarPrice(Data.VehicleData vehicle)
        {
            if (vehicle == null)
            {
                Debug.LogError("❌ VehicleData не назначен!");
                return 0;
            }
            
            // Базовая цена из данных
            int basePrice = vehicle.basePrice;
            
            // Коррекция от мощности
            float powerFactor = vehicle.baseStats.power / 300f;
            
            // Коррекция от сцепления
            float gripFactor = vehicle.baseStats.grip / 0.8f;
            
            // Коррекция от веса (лёгкие дороже)
            float weightFactor = 1500f / vehicle.baseStats.weight;
            
            // Финальная цена
            int finalPrice = Mathf.FloorToInt(
                basePrice * 
                powerFactor * 
                gripFactor * 
                weightFactor
            );
            
            // Ограничения
            finalPrice = Mathf.Clamp(finalPrice, MIN_CAR_PRICE, MAX_CAR_PRICE);
            
            Debug.Log($"🚗 Цена {vehicle.manufacturer} {vehicle.vehicleName}:");
            Debug.Log($"   База: ${basePrice}");
            Debug.Log($"   Мощность: x{powerFactor:F2}");
            Debug.Log($"   Сцепление: x{gripFactor:F2}");
            Debug.Log($"   Вес: x{weightFactor:F2}");
            Debug.Log($"   Итого: ${finalPrice}");
            
            return finalPrice;
        }
        
        /// <summary>
        /// Купить автомобиль
        /// </summary>
        public bool BuyCar(Data.VehicleData vehicle)
        {
            int price = CalculateCarPrice(vehicle);
            
            if (RemoveMoney(price, $"Покупка {vehicle.vehicleName}"))
            {
                Debug.Log($"✅ Куплен {vehicle.manufacturer} {vehicle.vehicleName} за ${price}");
                return true;
            }
            
            Debug.LogWarning($"❌ Недостаточно денег для покупки {vehicle.vehicleName}");
            return false;
        }
        
        /// <summary>
        /// Продать автомобиль
        /// </summary>
        public int SellCar(Data.VehicleData vehicle, float condition = 0.7f)
        {
            int price = CalculateCarPrice(vehicle);
            int sellPrice = Mathf.FloorToInt(price * condition * 0.5f); // 50% от цены с учётом износа
            
            AddMoney(sellPrice, $"Продажа {vehicle.vehicleName}");
            
            Debug.Log($"💰 Продан {vehicle.vehicleName} за ${sellPrice} (состояние: {condition*100:F0}%)");
            
            return sellPrice;
        }
        
        #endregion
        
        #region Part Prices
        
        /// <summary>
        /// Рассчитать цену запчасти
        /// </summary>
        public int CalculatePartPrice(Data.VehicleUpgrade part, bool isUsed = false)
        {
            if (part == null)
            {
                Debug.LogError("❌ Запчасть не назначена!");
                return 0;
            }
            
            // Базовая цена
            int basePrice = part.price;
            
            // Множитель редкости
            float rarityMultiplier = GetRarityMultiplier(part.rarity);
            
            // Цена с учётом редкости
            int finalPrice = Mathf.FloorToInt(basePrice * rarityMultiplier);
            
            // Скидка за б/у
            if (isUsed)
            {
                finalPrice = Mathf.FloorToInt(finalPrice * (1f - USED_PART_DISCOUNT));
            }
            
            return finalPrice;
        }
        
        /// <summary>
        /// Получить множитель редкости
        /// </summary>
        public float GetRarityMultiplier(Data.PartRarity rarity)
        {
            switch (rarity)
            {
                case Data.PartRarity.Common:      return 1.0f;
                case Data.PartRarity.Uncommon:    return 1.5f;
                case Data.PartRarity.Rare:        return 2.5f;
                case Data.PartRarity.Epic:        return 4.0f;
                case Data.PartRarity.Legendary:   return 6.0f;
                default: return 1.0f;
            }
        }
        
        /// <summary>
        /// Купить запчасть
        /// </summary>
        public bool BuyPart(Data.VehicleUpgrade part, bool isUsed = false)
        {
            int price = CalculatePartPrice(part, isUsed);
            string condition = isUsed ? "б/у" : "новая";
            
            if (RemoveMoney(price, $"Запчасть {part.partName} ({condition})"))
            {
                Debug.Log($"✅ Куплена запчасть {part.partName} ({condition}) за ${price}");
                return true;
            }
            
            return false;
        }
        
        /// <summary>
        /// Продать запчасть
        /// </summary>
        public int SellPart(Data.VehicleUpgrade part, bool isUsed = false)
        {
            int price = CalculatePartPrice(part, isUsed);
            int sellPrice = Mathf.FloorToInt(price * 0.7f); // 70% от цены продажи
            
            AddMoney(sellPrice, $"Продажа {part.partName}");
            
            return sellPrice;
        }
        
        #endregion
        
        #region Statistics
        
        /// <summary>
        /// Получить статистику экономики
        /// </summary>
        public string GetEconomyStats()
        {
            return $@"=== ЭКОНОМИКА ===
Деньги: ${currentMoney}
Всего заработано: ${totalEarned}
Всего потрачено: ${totalSpent}
Гонок завершено: {racesCompleted}
Средний заработок: ${(racesCompleted > 0 ? totalEarned / racesCompleted : 0)}$/гонку";
        }
        
        /// <summary>
        /// Рассчитать сколько гонок нужно для покупки авто
        /// </summary>
        public int CalculateRacesNeededForCar(Data.VehicleData vehicle)
        {
            int carPrice = CalculateCarPrice(vehicle);
            int avgReward = BASE_REWARD_QUARTER_MILE; // Средняя награда за гонку
            
            int racesNeeded = Mathf.CeilToInt((carPrice - currentMoney) / (float)avgReward);
            
            Debug.Log($"📊 Для покупки {vehicle.vehicleName} (${carPrice}):");
            Debug.Log($"   Есть: ${currentMoney}");
            Debug.Log($"   Нужно: ${carPrice - currentMoney}");
            Debug.Log($"   Гонок: {racesNeeded} (при среднем заработке ${avgReward}/гонку)");
            
            return Mathf.Max(0, racesNeeded);
        }
        
        #endregion
    }
}

using UnityEngine;
using UnityEngine.UI;
using System.Collections.Generic;
using DragRace.Core;
using DragRace.Economy;
using DragRace.Data;

namespace DragRace.UI
{
    /// <summary>
    /// UI Тюнинга - установка и сравнение запчастей
    /// </summary>
    public class TuningUI : MonoBehaviour
    {
        [Header("Панели")]
        [Tooltip("Основная панель тюнинга")]
        public GameObject tuningPanel;
        
        [Tooltip("Панель выбора слота")]
        public GameObject slotSelectionPanel;
        
        [Tooltip("Панель сравнения")]
        public GameObject comparisonPanel;
        
        [Header("Слоты запчастей")]
        [Tooltip("Список кнопок слотов")]
        public Button[] slotButtons;
        
        [Tooltip("Тексты названий слотов")]
        public Text[] slotNameTexts;
        
        [Header("Текущая запчасть")]
        [Tooltip("Название текущей запчасти")]
        public Text currentPartName;
        
        [Tooltip("Характеристики текущей")]
        public Text currentPartStats;
        
        [Header("Новая запчасть")]
        [Tooltip("Название новой запчасти")]
        public Text newPartName;
        
        [Tooltip("Характеристики новой")]
        public Text newPartStats;
        
        [Header("Сравнение")]
        [Tooltip("Текст сравнения")]
        public Text comparisonText;
        
        [Tooltip("Индикатор улучшения")]
        public Image upgradeIndicator;
        
        [Header("Кнопки")]
        [Tooltip("Кнопка установки")]
        public Button installButton;
        
        [Tooltip("Кнопка продажи")]
        public Button sellButton;
        
        [Tooltip("Кнопка назад")]
        public Button backButton;
        
        [Header("Данные")]
        [Tooltip("Текущий автомобиль")]
        public Data.VehicleData currentCar;
        
        [Tooltip("Установленные запчасти")]
        public List<Data.VehicleUpgrade> installedParts = new List<Data.VehicleUpgrade>();
        
        [Tooltip("Доступные запчасти в инвентаре")]
        public List<Data.VehicleUpgrade> inventoryParts = new List<Data.VehicleUpgrade>();
        
        // Состояние
        private Data.PartType selectedSlot = Data.PartType.Engine;
        private Data.VehicleUpgrade selectedPart;
        
        private void Awake()
        {
            InitializeTuning();
        }
        
        private void InitializeTuning()
        {
            Debug.Log("🔧 TuningUI инициализирован");
            
            // Подписка на кнопки слотов
            for (int i = 0; i < slotButtons.Length && i < slotNameTexts.Length; i++)
            {
                int index = i;
                slotButtons[i]?.onClick.AddListener(() => SelectSlot((Data.PartType)index));
            }
            
            // Подписка на кнопки действий
            installButton?.onClick.AddListener(OnInstallClicked);
            sellButton?.onClick.AddListener(OnSellClicked);
            backButton?.onClick.AddListener(OnBackClicked);
            
            // Загрузка инвентаря
            LoadInventory();
            
            // Обновление UI
            UpdateSlotsDisplay();
        }
        
        #region Slot Management
        
        private void SelectSlot(Data.PartType slotType)
        {
            selectedSlot = slotType;
            selectedPart = null;
            
            Debug.Log($"🔧 Выбран слот: {slotType}");
            
            UpdateSlotDisplay();
            ShowPartSelection();
        }
        
        private void UpdateSlotsDisplay()
        {
            for (int i = 0; i < slotButtons.Length && i < slotNameTexts.Length; i++)
            {
                Data.PartType slotType = (Data.PartType)i;
                slotNameTexts[i].text = slotType.ToString();
            }
        }
        
        private void UpdateSlotDisplay()
        {
            // Получение текущей запчасти в слоте
            Data.VehicleUpgrade currentPart = GetPartInSlot(selectedSlot);
            
            if (currentPart != null)
            {
                currentPartName.text = currentPart.partName;
                currentPartStats.text = GetStatsString(currentPart);
            }
            else
            {
                currentPartName.text = "Пусто";
                currentPartStats.text = "Нет запчасти";
            }
        }
        
        #endregion
        
        #region Inventory
        
        private void LoadInventory()
        {
            inventoryParts.Clear();
            
            var saveData = Core.SaveManager.Instance?.GetCurrentData();
            if (saveData != null && saveData.inventory != null)
            {
                // TODO: Загрузка запчастей из инвентаря
                Debug.Log($"📦 Загружено {inventoryParts.Count} запчастей");
            }
        }
        
        #endregion
        
        #region Part Selection
        
        private void ShowPartSelection()
        {
            // Получение запчастей для выбранного слота
            List<Data.VehicleUpgrade> availableParts = new List<Data.VehicleUpgrade>();
            
            foreach (var part in inventoryParts)
            {
                if (part.partType == selectedSlot)
                {
                    availableParts.Add(part);
                }
            }
            
            // TODO: Показать UI выбора запчасти
            Debug.Log($"🔍 Доступно запчастей: {availableParts.Count}");
        }
        
        private void SelectPart(Data.VehicleUpgrade part)
        {
            selectedPart = part;
            
            if (part != null)
            {
                newPartName.text = part.partName;
                newPartStats.text = GetStatsString(part);
                
                // Показ сравнения
                ShowComparison(part);
            }
        }
        
        #endregion
        
        #region Comparison
        
        private void ShowComparison(Data.VehicleUpgrade newPart)
        {
            Data.VehicleUpgrade currentPart = GetPartInSlot(selectedSlot);
            
            if (currentPart == null)
            {
                comparisonText.text = "Установка новой запчасти";
                upgradeIndicator.color = Color.green;
            }
            else
            {
                // Сравнение характеристик
                string comparison = CompareParts(currentPart, newPart);
                comparisonText.text = comparison;
                
                // Определение улучшения
                bool isUpgrade = IsBetterPart(currentPart, newPart);
                upgradeIndicator.color = isUpgrade ? Color.green : Color.red;
            }
        }
        
        private string CompareParts(Data.VehicleUpgrade current, Data.VehicleUpgrade newPart)
        {
            string result = "Сравнение:\n\n";
            
            if (current.powerChange != newPart.powerChange)
            {
                float diff = newPart.powerChange - current.powerChange;
                result += $"Мощность: {(diff > 0 ? "+" : "")}{diff:F0} л.с.\n";
            }
            
            if (current.torqueChange != newPart.torqueChange)
            {
                float diff = newPart.torqueChange - current.torqueChange;
                result += $"Крутящий момент: {(diff > 0 ? "+" : "")}{diff:F0} Нм\n";
            }
            
            if (current.weightChange != newPart.weightChange)
            {
                float diff = newPart.weightChange - current.weightChange;
                result += $"Вес: {(diff < 0 ? "-" : "+")}{Mathf.Abs(diff):F0} кг\n";
            }
            
            if (current.gripChange != newPart.gripChange)
            {
                float diff = newPart.gripChange - current.gripChange;
                result += $"Сцепление: {(diff > 0 ? "+" : "")}{diff:F2}\n";
            }
            
            return result;
        }
        
        private bool IsBetterPart(Data.VehicleUpgrade current, Data.VehicleUpgrade newPart)
        {
            // Простая эвристика: сумма положительных изменений
            float currentScore = current.powerChange + current.torqueChange - current.weightChange;
            float newScore = newPart.powerChange + newPart.torqueChange - newPart.weightChange;
            
            return newScore > currentScore;
        }
        
        #endregion
        
        #region Actions
        
        private void OnInstallClicked()
        {
            if (selectedPart != null)
            {
                // Установка запчасти
                InstallPart(selectedSlot, selectedPart);
                
                Debug.Log($"✅ Установлена запчасть: {selectedPart.partName}");
                
                // Обновление UI
                UpdateSlotDisplay();
                HideComparison();
            }
        }
        
        private void OnSellClicked()
        {
            Data.VehicleUpgrade currentPart = GetPartInSlot(selectedSlot);
            
            if (currentPart != null)
            {
                var economy = EconomyManager.Instance;
                if (economy != null)
                {
                    int sellPrice = economy.SellPart(currentPart);
                    
                    // Удаление запчасти
                    RemovePartFromSlot(selectedSlot);
                    
                    Debug.Log($"💰 Продана запчасть {currentPart.partName} за ${sellPrice}");
                    
                    UpdateSlotDisplay();
                }
            }
        }
        
        private void OnBackClicked()
        {
            gameObject.SetActive(false);
        }
        
        #endregion
        
        #region Helper Methods
        
        private Data.VehicleUpgrade GetPartInSlot(Data.PartType slot)
        {
            foreach (var part in installedParts)
            {
                if (part.partType == slot)
                {
                    return part;
                }
            }
            return null;
        }
        
        private void InstallPart(Data.PartType slot, Data.VehicleUpgrade part)
        {
            // Удаление старой запчасти из слота
            RemovePartFromSlot(slot);
            
            // Установка новой
            installedParts.Add(part);
            
            // Обновление данных автомобиля
            if (currentCar != null)
            {
                part.ApplyTo(ref currentCar.baseStats);
            }
        }
        
        private void RemovePartFromSlot(Data.PartType slot)
        {
            Data.VehicleUpgrade part = GetPartInSlot(slot);
            if (part != null)
            {
                installedParts.Remove(part);
            }
        }
        
        private string GetStatsString(Data.VehicleUpgrade part)
        {
            string stats = "";
            
            if (part.powerChange != 0)
                stats += $"+{part.powerChange} л.с. ";
            if (part.torqueChange != 0)
                stats += $"+{part.torqueChange} Нм ";
            if (part.weightChange != 0)
                stats += $"{(part.weightChange < 0 ? "" : "+")}{part.weightChange} кг ";
            if (part.gripChange != 0)
                stats += $"+{part.gripChange:F2} сцепление ";
            
            return string.IsNullOrEmpty(stats) ? "Без изменений" : stats;
        }
        
        private void HideComparison()
        {
            comparisonPanel.SetActive(false);
        }
        
        #endregion
        
        #region Public Methods
        
        /// <summary>
        /// Показать тюнинг
        /// </summary>
        public void ShowTuning()
        {
            gameObject.SetActive(true);
            LoadInventory();
            UpdateSlotsDisplay();
        }
        
        /// <summary>
        /// Установить текущий автомобиль
        /// </summary>
        public void SetCurrentCar(Data.VehicleData car)
        {
            currentCar = car;
            installedParts.Clear();
            Debug.Log($"🚗 Автомобиль для тюнинга: {car.vehicleName}");
        }
        
        #endregion
    }
}

using UnityEngine;
using UnityEngine.UI;
using DragRace.Core;
using DragRace.Data;
using System.Collections.Generic;

namespace DragRace.UI
{
    /// <summary>
    /// Тюнинг - установка запчастей
    /// </summary>
    public class TuningUI : MonoBehaviour
    {
        [Header("Вкладки")]
        public Button engineTab;
        public Button transmissionTab;
        public Button tiresTab;
        public Button nitroTab;
        
        [Header("Панели")]
        public GameObject enginePanel;
        public GameObject transmissionPanel;
        public GameObject tiresPanel;
        public GameObject nitroPanel;
        
        [Header("Списки запчастей")]
        public Transform partsListContainer;
        public GameObject partListItemPrefab;
        
        [Header("Информация о детали")]
        public Text partNameText;
        public Text partDescriptionText;
        public Text partPriceText;
        
        [Header("Сравнение характеристик")]
        public StatComparison powerComparison;
        public StatComparison torqueComparison;
        public StatComparison weightComparison;
        public StatComparison gripComparison;
        
        [Header("Кнопки")]
        public Button installButton;
        public Button sellButton;
        public Button backButton;
        
        [Header("Текущие установленные")]
        public Text currentEngineText;
        public Text currentTransmissionText;
        public Text currentTiresText;
        
        private PartType currentTab;
        private VehicleData currentVehicle;
        private VehiclePart selectedPart;
        private List<VehiclePart> availableParts;
        
        private void Start()
        {
            currentVehicle = GameManager.Instance.GetCurrentVehicle();
            currentTab = PartType.Engine;
            
            SubscribeToEvents();
            LoadAvailableParts();
            UpdateCurrentPartsDisplay();
        }
        
        private void OnDestroy()
        {
            UnsubscribeFromEvents();
        }
        
        private void SubscribeToEvents()
        {
            if (engineTab != null)
                engineTab.onClick.AddListener(() => SwitchTab(PartType.Engine));
            
            if (transmissionTab != null)
                transmissionTab.onClick.AddListener(() => SwitchTab(PartType.Transmission));
            
            if (tiresTab != null)
                tiresTab.onClick.AddListener(() => SwitchTab(PartType.Tires));
            
            if (nitroTab != null)
                nitroTab.onClick.AddListener(() => SwitchTab(PartType.Nitro));
            
            if (installButton != null)
                installButton.onClick.AddListener(OnInstallClicked);
            
            if (sellButton != null)
                sellButton.onClick.AddListener(OnSellClicked);
            
            if (backButton != null)
                backButton.onClick.AddListener(OnBackClicked);
        }
        
        private void UnsubscribeFromEvents()
        {
            if (engineTab != null)
                engineTab.onClick.RemoveListener(() => SwitchTab(PartType.Engine));
            
            if (transmissionTab != null)
                transmissionTab.onClick.RemoveListener(() => SwitchTab(PartType.Transmission));
            
            if (tiresTab != null)
                tiresTab.onClick.RemoveListener(() => SwitchTab(PartType.Tires));
            
            if (nitroTab != null)
                nitroTab.onClick.RemoveListener(() => SwitchTab(PartType.Nitro));
            
            if (installButton != null)
                installButton.onClick.RemoveListener(OnInstallClicked);
            
            if (sellButton != null)
                sellButton.onClick.RemoveListener(OnSellClicked);
            
            if (backButton != null)
                backButton.onClick.RemoveListener(OnBackClicked);
        }
        
        #region Вкладки
        
        private void SwitchTab(PartType type)
        {
            currentTab = type;
            
            enginePanel.SetActive(type == PartType.Engine);
            transmissionPanel.SetActive(type == PartType.Transmission);
            tiresPanel.SetActive(type == PartType.Tires);
            nitroPanel.SetActive(type == PartType.Nitro);
            
            LoadAvailableParts();
        }
        
        #endregion
        
        #region Загрузка запчастей
        
        private void LoadAvailableParts()
        {
            availableParts = GameManager.Instance.partsDatabase?.GetAllPartsByType(currentTab);
            
            if (partsListContainer == null || partListItemPrefab == null)
                return;
            
            // Очистка
            foreach (Transform child in partsListContainer)
                Destroy(child.gameObject);
            
            // Создание элементов
            if (availableParts == null) return;
            
            foreach (var part in availableParts)
            {
                GameObject item = Instantiate(partListItemPrefab, partsListContainer);
                
                var listItem = item.GetComponent<PartListItem>();
                if (listItem != null)
                {
                    listItem.Initialize(part);
                    listItem.OnClicked += () => OnPartSelected(part);
                    listItem.OnHover += (isHover) =>
                    {
                        if (isHover) ShowPartComparison(part);
                    };
                }
            }
        }
        
        #endregion
        
        #region Выбор детали
        
        private void OnPartSelected(VehiclePart part)
        {
            selectedPart = part;
            DisplayPartInfo(part);
            ShowPartComparison(part);
        }
        
        private void DisplayPartInfo(VehiclePart part)
        {
            if (partNameText != null)
                partNameText.text = part.partName;
            
            if (partDescriptionText != null)
                partDescriptionText.text = part.GetDescription();
            
            if (partPriceText != null)
                partPriceText.text = $"{part.buyPrice:F0} $";
        }
        
        private void ShowPartComparison(VehiclePart part)
        {
            var currentStats = GetPartStats(currentVehicle, currentTab);
            var newStats = part.GetStatsBonus();
            
            if (powerComparison != null)
                powerComparison.SetValues(currentStats.power, newStats.power);
            
            if (torqueComparison != null)
                torqueComparison.SetValues(currentStats.torque, newStats.torque);
            
            if (weightComparison != null)
                weightComparison.SetValues(currentStats.weight, newStats.weight);
            
            if (gripComparison != null)
                gripComparison.SetValues(currentStats.grip, newStats.grip);
        }
        
        private VehicleStats GetPartStats(VehicleData vehicle, PartType type)
        {
            var stats = new VehicleStats();
            
            // Получаем текущие бонусы от установленных частей
            // TODO: Реализовать получение данных от установленных частей
            
            return stats;
        }
        
        #endregion
        
        #region Действия
        
        private void OnInstallClicked()
        {
            if (selectedPart == null) return;
            
            // Проверка денег
            if (!GameManager.Instance.HasMoney(selectedPart.buyPrice))
            {
                Debug.LogWarning("Недостаточно денег!");
                return;
            }
            
            // Покупка и установка
            GameManager.Instance.SpendMoney(selectedPart.buyPrice);
            
            // Установка части на автомобиль
            InstallPart(selectedPart);
            
            // Обновление
            UpdateCurrentPartsDisplay();
            LoadAvailableParts();
        }
        
        private void InstallPart(VehiclePart part)
        {
            switch (part.partType)
            {
                case PartType.Engine:
                    currentVehicle.engineId = part.partId;
                    break;
                case PartType.Transmission:
                    currentVehicle.transmissionId = part.partId;
                    break;
                case PartType.Tires:
                    currentVehicle.tiresId = part.partId;
                    break;
                case PartType.Nitro:
                    // Установка нитро
                    break;
            }
            
            // Пересчёт характеристик
            RecalculateVehicleStats();
        }
        
        private void RecalculateVehicleStats()
        {
            // Сброс к базовым
            currentVehicle.currentStats = new VehicleStats
            {
                power = currentVehicle.baseStats.power,
                torque = currentVehicle.baseStats.torque,
                weight = currentVehicle.baseStats.weight,
                grip = currentVehicle.baseStats.grip,
                aerodynamics = currentVehicle.baseStats.aerodynamics
            };
            
            // Добавление бонусов от частей
            // TODO: Добавить бонусы от установленных частей
        }
        
        private void OnSellClicked()
        {
            if (selectedPart == null) return;
            
            float sellPrice = selectedPart.sellPrice;
            GameManager.Instance.AddMoney(sellPrice);
            
            // Удаление из инвентаря
            // TODO: Реализовать удаление
        }
        
        private void OnBackClicked()
        {
            GameManager.Instance.ChangeState(GameState.GameMenu);
        }
        
        #endregion
        
        #region Отображение
        
        private void UpdateCurrentPartsDisplay()
        {
            if (currentEngineText != null)
                currentEngineText.text = GetPartName(currentVehicle.engineId, PartType.Engine);
            
            if (currentTransmissionText != null)
                currentTransmissionText.text = GetPartName(currentVehicle.transmissionId, PartType.Transmission);
            
            if (currentTiresText != null)
                currentTiresText.text = GetPartName(currentVehicle.tiresId, PartType.Tires);
        }
        
        private string GetPartName(string partId, PartType type)
        {
            if (string.IsNullOrEmpty(partId))
                return "Стоковая";
            
            var part = GameManager.Instance.partsDatabase?.GetAllPartsByType(type)
                .Find(p => p.partId == partId);
            
            return part?.partName ?? "Неизвестно";
        }
        
        #endregion
    }
    
    /// <summary>
    /// Элемент списка запчастей
    /// </summary>
    public class PartListItem : MonoBehaviour
    {
        public Text partNameText;
        public Text partRarityText;
        public Text partPriceText;
        public Image rarityBackground;
        public Button selectButton;
        
        public System.Action OnClicked;
        public System.Action<bool> OnHover;
        
        public void Initialize(VehiclePart part)
        {
            if (partNameText != null)
                partNameText.text = part.partName;
            
            if (partPriceText != null)
                partPriceText.text = $"{part.buyPrice:F0} $";
            
            if (partRarityText != null)
                partRarityText.text = part.rarity.ToString();
            
            if (selectButton != null)
                selectButton.onClick.AddListener(() => OnClicked?.Invoke());
        }
        
        private void OnMouseEnter()
        {
            OnHover?.Invoke(true);
        }
        
        private void OnMouseExit()
        {
            OnHover?.Invoke(false);
        }
    }
    
    /// <summary>
    /// Сравнение характеристик
    /// </summary>
    public class StatComparison : MonoBehaviour
    {
        public Text labelText;
        public Text currentValueText;
        public Text newValueText;
        public Image currentValueBar;
        public Image newValueBar;
        
        public void SetValues(float current, float newValue)
        {
            if (currentValueText != null)
                currentValueText.text = current.ToString("F1");
            
            if (newValueText != null)
            {
                newValueText.text = newValue.ToString("F1");
                
                float diff = newValue - current;
                if (diff > 0)
                    newValueText.color = Color.green;
                else if (diff < 0)
                    newValueText.color = Color.red;
                else
                    newValueText.color = Color.white;
            }
        }
    }
}

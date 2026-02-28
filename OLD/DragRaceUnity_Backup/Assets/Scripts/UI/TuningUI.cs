using UnityEngine;
using UnityEngine.UI;
using ProbMenu.Core;
using ProbMenu.Data;
using ProbMenu.Racing;
using System.Collections.Generic;
using Logger = ProbMenu.Core.Logger;

namespace ProbMenu.UI
{
    /// <summary>
    /// UI Тюнинга
    /// Установка апгрейдов, сравнение характеристик
    /// </summary>
    public class TuningUI : MonoBehaviour
    {
        [Header("Ссылки")]
        [SerializeField] private CareerManager careerManager;
        [SerializeField] private CarData currentCar;

        [Header("UI Элементы")]
        [SerializeField] private Text upgradeNameText;
        [SerializeField] private Text upgradeDescriptionText;
        [SerializeField] private Text upgradePriceText;
        [SerializeField] private Image upgradeIcon;

        [Header("Сравнение характеристик")]
        [SerializeField] private Slider powerCompareSlider;
        [SerializeField] private Slider torqueCompareSlider;
        [SerializeField] private Slider weightCompareSlider;
        [SerializeField] private Text powerBeforeText;
        [SerializeField] private Text powerAfterText;
        [SerializeField] private Text torqueBeforeText;
        [SerializeField] private Text torqueAfterText;

        [Header("Кнопки")]
        [SerializeField] private Button buyButton;
        [SerializeField] private Button installButton;
        [SerializeField] private Button backButton;

        [Header("Список апгрейдов")]
        [SerializeField] private Transform upgradeListContent;
        [SerializeField] private GameObject upgradeListItemPrefab;

        private List<VehicleUpgrade> availableUpgrades = new List<VehicleUpgrade>();
        private VehicleUpgrade selectedUpgrade;
        private List<string> ownedUpgrades = new List<string>();

        private void Start()
        {
            Logger.I("TuningUI initialized");

            if (careerManager == null)
            {
                careerManager = FindObjectOfType<CareerManager>();
            }

            LoadUpgrades();
            UpdateUI();
            SetupButtons();
        }

        #region Initialization

        private void LoadUpgrades()
        {
            availableUpgrades = new List<VehicleUpgrade>(Resources.LoadAll<VehicleUpgrade>("Upgrades"));

            if (availableUpgrades.Count == 0)
            {
                Logger.W("No upgrades found! Creating test data...");
                CreateTestUpgrades();
            }

            Logger.I($"Loaded {availableUpgrades.Count} upgrades");
        }

        private void CreateTestUpgrades()
        {
            var turbo = ScriptableObject.CreateInstance<VehicleUpgrade>();
            turbo.upgradeName = "Turbo Kit Stage 1";
            turbo.description = "Увеличивает мощность на 20%";
            turbo.type = UpgradeType.Turbo;
            turbo.price = 5000;
            turbo.rarity = 3;
            turbo.powerBonus = 0.2f;

            var exhaust = ScriptableObject.CreateInstance<VehicleUpgrade>();
            exhaust.upgradeName = "Sport Exhaust";
            exhaust.description = "Увеличивает крутящий момент на 10%";
            exhaust.type = UpgradeType.Exhaust;
            exhaust.price = 2000;
            exhaust.rarity = 2;
            exhaust.torqueBonus = 0.1f;

            var tires = ScriptableObject.CreateInstance<VehicleUpgrade>();
            tires.upgradeName = "Drag Slicks";
            tires.description = "Улучшает сцепление на 15%";
            tires.type = UpgradeType.Tires;
            tires.price = 1500;
            tires.rarity = 2;
            tires.gripBonus = 0.15f;

            availableUpgrades.AddRange(new[] { turbo, exhaust, tires });
        }

        private void SetupButtons()
        {
            if (buyButton != null)
                buyButton.onClick.AddListener(OnBuyUpgrade);

            if (installButton != null)
                installButton.onClick.AddListener(OnInstallUpgrade);

            if (backButton != null)
                backButton.onClick.AddListener(OnBack);
        }

        #endregion

        #region UI Updates

        private void UpdateUI()
        {
            if (selectedUpgrade == null) return;

            if (upgradeNameText != null)
                upgradeNameText.text = selectedUpgrade.upgradeName;

            if (upgradeDescriptionText != null)
                upgradeDescriptionText.text = selectedUpgrade.description;

            if (upgradePriceText != null)
                upgradePriceText.text = $"${selectedUpgrade.price:N0}";

            // Обновление сравнения
            UpdateComparison();
        }

        private void UpdateComparison()
        {
            if (currentCar == null) return;

            float currentPower = currentCar.engineData.maxPower;
            float currentTorque = currentCar.engineData.maxTorque;
            float currentWeight = currentCar.weight;

            float newPower = currentPower * (1 + selectedUpgrade.powerBonus);
            float newTorque = currentTorque * (1 + selectedUpgrade.torqueBonus);
            float newWeight = currentWeight - selectedUpgrade.weightReduction;

            if (powerBeforeText != null) powerBeforeText.text = $"{currentPower:F0} hp";
            if (powerAfterText != null) powerAfterText.text = $"{newPower:F0} hp";
            if (torqueBeforeText != null) torqueBeforeText.text = $"{currentTorque:F0} Nm";
            if (torqueAfterText != null) torqueAfterText.text = $"{newTorque:F0} Nm";

            UpdateSlider(powerCompareSlider, currentPower, newPower, 0, 1000);
            UpdateSlider(torqueCompareSlider, currentTorque, newTorque, 0, 1000);
            UpdateSlider(weightCompareSlider, currentWeight, newWeight, 2000, 500, true);
        }

        private void UpdateSlider(Slider slider, float before, float after, float min, float max, bool inverse = false)
        {
            if (slider == null) return;

            slider.minValue = 0;
            slider.maxValue = 1;

            float beforeNorm = Mathf.InverseLerp(min, max, before);
            float afterNorm = Mathf.InverseLerp(min, max, after);

            if (inverse)
            {
                beforeNorm = 1 - beforeNorm;
                afterNorm = 1 - afterNorm;
            }

            slider.value = afterNorm;
        }

        #endregion

        #region Button Handlers

        private void OnBuyUpgrade()
        {
            if (selectedUpgrade == null) return;

            if (careerManager.SpendMoney(selectedUpgrade.price))
            {
                ownedUpgrades.Add(selectedUpgrade.upgradeName);
                Logger.I($"Purchased: {selectedUpgrade.upgradeName}");
                UpdateUI();
            }
            else
            {
                Logger.W("Not enough money!");
            }
        }

        private void OnInstallUpgrade()
        {
            if (selectedUpgrade == null) return;

            if (!ownedUpgrades.Contains(selectedUpgrade.upgradeName))
            {
                Logger.W("Upgrade not owned!");
                return;
            }

            ApplyUpgrade(selectedUpgrade);
            Logger.I($"Installed: {selectedUpgrade.upgradeName}");
        }

        private void ApplyUpgrade(VehicleUpgrade upgrade)
        {
            if (currentCar == null) return;

            currentCar.engineData.maxPower *= (1 + upgrade.powerBonus);
            currentCar.engineData.maxTorque *= (1 + upgrade.torqueBonus);
            currentCar.weight -= upgrade.weightReduction;

            Logger.I($"Upgrades applied to {currentCar.carName}");
        }

        private void OnBack()
        {
            Logger.I("Back to Garage");
            Core.GameManager.Instance.ChangeState(Core.GameManager.GameState.GameMenu);
            Core.GameManager.Instance.LoadScene("GameMenu");
        }

        #endregion

        #region Selection

        public void SelectUpgrade(VehicleUpgrade upgrade)
        {
            selectedUpgrade = upgrade;
            UpdateUI();
        }

        #endregion

        #region Debug

        private void OnGUI()
        {
            if (!Application.isEditor) return;

            GUILayout.BeginArea(new Rect(10, 10, 400, 300));
            GUILayout.Label("=== TUNING ===");

            if (selectedUpgrade != null)
            {
                GUILayout.Label($"Name: {selectedUpgrade.upgradeName}");
                GUILayout.Label($"Price: ${selectedUpgrade.price}");
                GUILayout.Label($"Power: +{selectedUpgrade.powerBonus * 100:F0}%");
                GUILayout.Label($"Torque: +{selectedUpgrade.torqueBonus * 100:F0}%");
            }

            GUILayout.Label($"Owned: {string.Join(", ", ownedUpgrades)}");

            GUILayout.EndArea();
        }

        #endregion
    }
}

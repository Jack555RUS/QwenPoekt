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
    /// UI Магазина
    /// Покупка автомобилей и апгрейдов
    /// </summary>
    public class ShopUI : MonoBehaviour
    {
        [Header("Ссылки")]
        [SerializeField] private CareerManager careerManager;

        [Header("Вкладки")]
        [SerializeField] private Button carsTabButton;
        [SerializeField] private Button upgradesTabButton;
        [SerializeField] private GameObject carsPanel;
        [SerializeField] private GameObject upgradesPanel;

        [Header("UI Автомобилей")]
        [SerializeField] private Text carNameText;
        [SerializeField] private Text carClassText;
        [SerializeField] private Text carPriceText;
        [SerializeField] private Image carImage;
        [SerializeField] private Button buyCarButton;

        [Header("UI Апгрейдов")]
        [SerializeField] private Text upgradeNameText;
        [SerializeField] private Text upgradePriceText;
        [SerializeField] private Button buyUpgradeButton;

        [Header("Кнопки навигации")]
        [SerializeField] private Button backButton;
        [SerializeField] private Button nextButton;
        [SerializeField] private Button previousButton;

        private List<CarData> availableCars = new List<CarData>();
        private List<VehicleUpgrade> availableUpgrades = new List<VehicleUpgrade>();
        private int selectedCarIndex = 0;
        private int selectedUpgradeIndex = 0;
        private bool showingCars = true;

        private void Start()
        {
            Logger.I("ShopUI initialized");

            if (careerManager == null)
            {
                careerManager = FindObjectOfType<CareerManager>();
            }

            LoadItems();
            UpdateUI();
            SetupButtons();
        }

        #region Initialization

        private void LoadItems()
        {
            // Загрузка автомобилей
            availableCars = new List<CarData>(Resources.LoadAll<CarData>("Cars"));
            if (availableCars.Count == 0)
            {
                CreateTestCars();
            }

            // Загрузка апгрейдов
            availableUpgrades = new List<VehicleUpgrade>(Resources.LoadAll<VehicleUpgrade>("Upgrades"));
            if (availableUpgrades.Count == 0)
            {
                CreateTestUpgrades();
            }

            Logger.I($"Shop loaded: {availableCars.Count} cars, {availableUpgrades.Count} upgrades");
        }

        private void CreateTestCars()
        {
            var car1 = ScriptableObject.CreateInstance<CarData>();
            car1.carName = "Street Racer";
            car1.carClass = CarClass.C;
            car1.price = 25000;
            car1.engineData = new EngineData { maxPower = 300f, maxTorque = 350f };
            car1.weight = 1400f;

            var car2 = ScriptableObject.CreateInstance<CarData>();
            car2.carName = "Pro Dragster";
            car2.carClass = CarClass.B;
            car2.price = 75000;
            car2.engineData = new EngineData { maxPower = 600f, maxTorque = 700f };
            car2.weight = 1200f;

            var car3 = ScriptableObject.CreateInstance<CarData>();
            car3.carName = "Legend GT";
            car3.carClass = CarClass.A;
            car3.price = 150000;
            car3.engineData = new EngineData { maxPower = 800f, maxTorque = 900f };
            car3.weight = 1500f;

            availableCars.AddRange(new[] { car1, car2, car3 });
        }

        private void CreateTestUpgrades()
        {
            var turbo = ScriptableObject.CreateInstance<VehicleUpgrade>();
            turbo.upgradeName = "Turbo Stage 2";
            turbo.price = 8000;
            turbo.powerBonus = 0.3f;

            var nitro = ScriptableObject.CreateInstance<VehicleUpgrade>();
            nitro.upgradeName = "Nitro System";
            nitro.price = 5000;
            nitro.powerBonus = 0.2f;

            availableUpgrades.AddRange(new[] { turbo, nitro });
        }

        private void SetupButtons()
        {
            if (carsTabButton != null)
                carsTabButton.onClick.AddListener(() => ShowCarsTab());

            if (upgradesTabButton != null)
                upgradesTabButton.onClick.AddListener(() => ShowUpgradesTab());

            if (buyCarButton != null)
                buyCarButton.onClick.AddListener(OnBuyCar);

            if (buyUpgradeButton != null)
                buyUpgradeButton.onClick.AddListener(OnBuyUpgrade);

            if (backButton != null)
                backButton.onClick.AddListener(OnBack);

            if (nextButton != null)
                nextButton.onClick.AddListener(OnNext);

            if (previousButton != null)
                previousButton.onClick.AddListener(OnPrevious);
        }

        #endregion

        #region UI Updates

        private void UpdateUI()
        {
            if (showingCars)
            {
                UpdateCarsUI();
            }
            else
            {
                UpdateUpgradesUI();
            }
        }

        private void UpdateCarsUI()
        {
            if (availableCars.Count == 0) return;

            CarData car = availableCars[selectedCarIndex];

            if (carNameText != null) carNameText.text = car.carName;
            if (carClassText != null) carClassText.text = $"Class: {car.carClass}";
            if (carPriceText != null) carPriceText.text = $"${car.price:N0}";

            // Проверка доступности
            if (buyCarButton != null)
            {
                buyCarButton.interactable = careerManager.GetMoney() >= car.price;
            }
        }

        private void UpdateUpgradesUI()
        {
            if (availableUpgrades.Count == 0) return;

            VehicleUpgrade upgrade = availableUpgrades[selectedUpgradeIndex];

            if (upgradeNameText != null) upgradeNameText.text = upgrade.upgradeName;
            if (upgradePriceText != null) upgradePriceText.text = $"${upgrade.price:N0}";

            // Проверка доступности
            if (buyUpgradeButton != null)
            {
                buyUpgradeButton.interactable = careerManager.GetMoney() >= upgrade.price;
            }
        }

        #endregion

        #region Tab Switching

        private void ShowCarsTab()
        {
            showingCars = true;
            carsPanel?.SetActive(true);
            upgradesPanel?.SetActive(false);
            UpdateCarsUI();
        }

        private void ShowUpgradesTab()
        {
            showingCars = false;
            carsPanel?.SetActive(false);
            upgradesPanel?.SetActive(true);
            UpdateUpgradesUI();
        }

        #endregion

        #region Button Handlers

        private void OnBuyCar()
        {
            if (availableCars.Count == 0) return;

            CarData car = availableCars[selectedCarIndex];

            if (careerManager.SpendMoney(car.price))
            {
                Logger.I($"Purchased car: {car.carName}");
                // TODO: Добавить в гараж игрока
            }
            else
            {
                Logger.W("Not enough money!");
            }
        }

        private void OnBuyUpgrade()
        {
            if (availableUpgrades.Count == 0) return;

            VehicleUpgrade upgrade = availableUpgrades[selectedUpgradeIndex];

            if (careerManager.SpendMoney(upgrade.price))
            {
                Logger.I($"Purchased upgrade: {upgrade.upgradeName}");
                // TODO: Добавить в инвентарь
            }
            else
            {
                Logger.W("Not enough money!");
            }
        }

        private void OnBack()
        {
            Logger.I("Back to GameMenu");
            Core.GameManager.Instance.ChangeState(Core.GameManager.GameState.GameMenu);
            Core.GameManager.Instance.LoadScene("GameMenu");
        }

        private void OnNext()
        {
            if (showingCars)
            {
                selectedCarIndex = (selectedCarIndex + 1) % availableCars.Count;
                UpdateCarsUI();
            }
            else
            {
                selectedUpgradeIndex = (selectedUpgradeIndex + 1) % availableUpgrades.Count;
                UpdateUpgradesUI();
            }
        }

        private void OnPrevious()
        {
            if (showingCars)
            {
                selectedCarIndex = (selectedCarIndex - 1 + availableCars.Count) % availableCars.Count;
                UpdateCarsUI();
            }
            else
            {
                selectedUpgradeIndex = (selectedUpgradeIndex - 1 + availableUpgrades.Count) % availableUpgrades.Count;
                UpdateUpgradesUI();
            }
        }

        #endregion

        #region Debug

        private void OnGUI()
        {
            if (!Application.isEditor) return;

            GUILayout.BeginArea(new Rect(10, 10, 400, 300));
            GUILayout.Label("=== SHOP ===");
            GUILayout.Label($"Money: ${careerManager?.GetMoney():N0}");

            if (showingCars)
            {
                GUILayout.Label($"=== CARS ({selectedCarIndex + 1}/{availableCars.Count}) ===");
                if (availableCars.Count > 0)
                {
                    CarData car = availableCars[selectedCarIndex];
                    GUILayout.Label($"{car.carName} - ${car.price:N0}");
                    GUILayout.Label($"Class: {car.carClass}");
                    GUILayout.Label($"Power: {car.engineData.maxPower} hp");
                }
            }
            else
            {
                GUILayout.Label($"=== UPGRADES ({selectedUpgradeIndex + 1}/{availableUpgrades.Count}) ===");
                if (availableUpgrades.Count > 0)
                {
                    VehicleUpgrade upg = availableUpgrades[selectedUpgradeIndex];
                    GUILayout.Label($"{upg.upgradeName} - ${upg.price:N0}");
                    GUILayout.Label($"Power: +{upg.powerBonus * 100:F0}%");
                }
            }

            GUILayout.EndArea();
        }

        #endregion
    }
}

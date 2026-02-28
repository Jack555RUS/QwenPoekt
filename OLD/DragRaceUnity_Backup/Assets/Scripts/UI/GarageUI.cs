using UnityEngine;
using UnityEngine.UI;
using ProbMenu.Core;
using ProbMenu.Data;
using ProbMenu.Racing;
using Logger = ProbMenu.Core.Logger;

namespace ProbMenu.UI
{
    /// <summary>
    /// UI Гаража
    /// Выбор автомобиля, просмотр характеристик
    /// </summary>
    public class GarageUI : MonoBehaviour
    {
        [Header("Ссылки")]
        [SerializeField] private CareerManager careerManager;

        [Header("UI Элементы")]
        [SerializeField] private Text carNameText;
        [SerializeField] private Text carClassText;
        [SerializeField] private Text carPriceText;
        [SerializeField] private Image carImage;

        [Header("Характеристики")]
        [SerializeField] private Slider powerSlider;
        [SerializeField] private Slider torqueSlider;
        [SerializeField] private Slider weightSlider;
        [SerializeField] private Slider gripSlider;

        [Header("Кнопки")]
        [SerializeField] private Button selectButton;
        [SerializeField] private Button upgradeButton;
        [SerializeField] private Button backButton;

        [Header("Список авто")]
        [SerializeField] private Transform carListContent;
        [SerializeField] private GameObject carListItemPrefab;

        private CarData[] availableCars;
        private int selectedIndex = 0;

        private void Start()
        {
            Logger.I("GarageUI initialized");

            if (careerManager == null)
            {
                careerManager = FindObjectOfType<CareerManager>();
            }

            LoadCars();
            UpdateUI();
            SetupButtons();
        }

        #region Initialization

        private void LoadCars()
        {
            // Загрузка данных автомобилей
            availableCars = Resources.LoadAll<CarData>("Cars");

            if (availableCars.Length == 0)
            {
                Logger.W("No car data found in Resources/Cars!");
                CreateTestCars();
            }

            Logger.I($"Loaded {availableCars.Length} cars");
        }

        private void CreateTestCars()
        {
            // Создаём тестовые данные
            var car1 = ScriptableObject.CreateInstance<CarData>();
            car1.carName = "Test Car 1";
            car1.carClass = CarClass.D;
            car1.price = 15000;
            car1.weight = 1400f;
            car1.dragCoefficient = 0.32f;
            car1.frontalArea = 2.1f;
            car1.engineData = new EngineData
            {
                maxPower = 200f,
                maxTorque = 250f,
                maxRpm = 7000
            };

            var car2 = ScriptableObject.CreateInstance<CarData>();
            car2.carName = "Test Car 2";
            car2.carClass = CarClass.C;
            car2.price = 35000;
            car2.weight = 1500f;
            car2.dragCoefficient = 0.30f;
            car2.frontalArea = 2.2f;
            car2.engineData = new EngineData
            {
                maxPower = 350f,
                maxTorque = 400f,
                maxRpm = 7500
            };

            availableCars = new[] { car1, car2 };
        }

        private void SetupButtons()
        {
            if (selectButton != null)
                selectButton.onClick.AddListener(OnSelectCar);

            if (upgradeButton != null)
                upgradeButton.onClick.AddListener(OnUpgradeCar);

            if (backButton != null)
                backButton.onClick.AddListener(OnBack);
        }

        #endregion

        #region UI Updates

        private void UpdateUI()
        {
            if (availableCars == null || availableCars.Length == 0) return;

            CarData selectedCar = availableCars[selectedIndex];

            if (carNameText != null)
                carNameText.text = selectedCar.carName;

            if (carClassText != null)
                carClassText.text = $"Class: {selectedCar.carClass}";

            if (carPriceText != null)
                carPriceText.text = $"${selectedCar.price:N0}";

            // Характеристики
            UpdateSlider(powerSlider, selectedCar.engineData.maxPower, 0, 1000);
            UpdateSlider(torqueSlider, selectedCar.engineData.maxTorque, 0, 1000);
            UpdateSlider(weightSlider, selectedCar.weight, 2000, 500, true);
            UpdateSlider(gripSlider, selectedCar.tireData?.gripLevel ?? 0.5f, 0, 1);
        }

        private void UpdateSlider(Slider slider, float value, float min, float max, bool inverse = false)
        {
            if (slider == null) return;

            float normalized = Mathf.InverseLerp(min, max, value);
            slider.value = inverse ? 1 - normalized : normalized;
        }

        #endregion

        #region Button Handlers

        private void OnSelectCar()
        {
            if (availableCars == null || availableCars.Length == 0) return;

            CarData selectedCar = availableCars[selectedIndex];
            Logger.I($"Selected car: {selectedCar.carName}");

            // TODO: Сохранить выбор в PlayerData
            // careerManager.GetPlayerData().currentCarId = selectedCar.GetInstanceID();
        }

        private void OnUpgradeCar()
        {
            Logger.I("Open upgrade menu...");
            // TODO: Открыть UI тюнинга
        }

        private void OnBack()
        {
            Logger.I("Back to GameMenu");
            Core.GameManager.Instance.ChangeState(Core.GameManager.GameState.GameMenu);
            Core.GameManager.Instance.LoadScene("GameMenu");
        }

        #endregion

        #region Navigation

        public void NextCar()
        {
            if (availableCars == null || availableCars.Length == 0) return;

            selectedIndex = (selectedIndex + 1) % availableCars.Length;
            UpdateUI();
        }

        public void PreviousCar()
        {
            if (availableCars == null || availableCars.Length == 0) return;

            selectedIndex = (selectedIndex - 1 + availableCars.Length) % availableCars.Length;
            UpdateUI();
        }

        #endregion

        #region Debug

        private void OnGUI()
        {
            if (!Application.isEditor) return;

            GUILayout.BeginArea(new Rect(10, 10, 300, 200));
            GUILayout.Label("=== GARAGE ===");

            if (availableCars != null && availableCars.Length > 0)
            {
                GUILayout.Label($"Car {selectedIndex + 1}/{availableCars.Length}");
                GUILayout.Label(availableCars[selectedIndex].carName);
            }

            if (GUILayout.Button("<")) PreviousCar();
            if (GUILayout.Button(">")) NextCar();

            GUILayout.EndArea();
        }

        #endregion
    }
}

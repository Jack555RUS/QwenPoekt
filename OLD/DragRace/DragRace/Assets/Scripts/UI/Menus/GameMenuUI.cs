using UnityEngine;
using UnityEngine.UI;
using DragRace.Core;

namespace DragRace.UI.Menus
{
    /// <summary>
    /// Меню игры (гараж, заезд, тюнинг, магазин)
    /// </summary>
    public class GameMenuUI : MonoBehaviour
    {
        [Header("Панели")]
        public GameObject mainPanel;
        public GameObject garagePanel;
        public GameObject tuningPanel;
        public GameObject shopPanel;
        public GameObject raceSelectPanel;
        
        [Header("Кнопки")]
        public Button raceButton;
        public Button garageButton;
        public Button tuningButton;
        public Button shopButton;
        public Button menuButton;
        
        [Header("Информация об автомобиле")]
        public Text carNameText;
        public Text carStatsText;
        public Image carImage;
        
        [Header("Выбор заезда")]
        public Button quarterMileButton;
        public Button halfMileButton;
        public Button fullMileButton;
        public Button testRunButton;
        
        private GameObject currentPanel;
        
        private void Awake()
        {
            SubscribeToEvents();
        }
        
        private void Start()
        {
            ShowPanel(mainPanel);
            UpdateCarInfo();
        }
        
        private void OnDestroy()
        {
            UnsubscribeFromEvents();
        }
        
        private void SubscribeToEvents()
        {
            if (raceButton != null)
                raceButton.onClick.AddListener(OnRaceClicked);
            
            if (garageButton != null)
                garageButton.onClick.AddListener(OnGarageClicked);
            
            if (tuningButton != null)
                tuningButton.onClick.AddListener(OnTuningClicked);
            
            if (shopButton != null)
                shopButton.onClick.AddListener(OnShopClicked);
            
            if (menuButton != null)
                menuButton.onClick.AddListener(OnMenuClicked);
            
            if (quarterMileButton != null)
                quarterMileButton.onClick.AddListener(() => StartRace(402f));
            
            if (halfMileButton != null)
                halfMileButton.onClick.AddListener(() => StartRace(804f));
            
            if (fullMileButton != null)
                fullMileButton.onClick.AddListener(() => StartRace(1609f));
            
            if (testRunButton != null)
                testRunButton.onClick.AddListener(() => StartRace(402f, true));
        }
        
        private void UnsubscribeFromEvents()
        {
            if (raceButton != null)
                raceButton.onClick.RemoveListener(OnRaceClicked);
            
            if (garageButton != null)
                garageButton.onClick.RemoveListener(OnGarageClicked);
            
            if (tuningButton != null)
                tuningButton.onClick.RemoveListener(OnTuningClicked);
            
            if (shopButton != null)
                shopButton.onClick.RemoveListener(OnShopClicked);
            
            if (menuButton != null)
                menuButton.onClick.RemoveListener(OnMenuClicked);
        }
        
        #region Обработчики
        
        private void OnRaceClicked()
        {
            ShowPanel(raceSelectPanel);
        }
        
        private void OnGarageClicked()
        {
            ShowPanel(garagePanel);
            UpdateCarInfo();
        }
        
        private void OnTuningClicked()
        {
            ShowPanel(tuningPanel);
        }
        
        private void OnShopClicked()
        {
            ShowPanel(shopPanel);
        }
        
        private void OnMenuClicked()
        {
            GameManager.Instance.ChangeState(GameState.MainMenu);
        }
        
        #endregion
        
        #region Заезд
        
        private void StartRace(float distance, bool isTest = false)
        {
            var raceDistance = new RaceDistance
            {
                name = GetDistanceName(distance),
                distanceMeters = distance,
                displayName = GetDistanceDisplayName(distance)
            };
            
            var raceType = isTest ? RaceType.Test : RaceType.Street;
            
            // Переход к сцене заезда
            GameManager.Instance.ChangeState(GameState.Racing);
        }
        
        private string GetDistanceName(float distance)
        {
            return distance switch
            {
                <= 402 => "QuarterMile",
                <= 804 => "HalfMile",
                _ => "FullMile"
            };
        }
        
        private string GetDistanceDisplayName(float distance)
        {
            return distance switch
            {
                <= 402 => "1/4 мили",
                <= 804 => "1/2 мили",
                _ => "1 миля"
            };
        }
        
        #endregion
        
        #region Отображение
        
        private void ShowPanel(GameObject panel)
        {
            if (currentPanel != null)
                currentPanel.SetActive(false);
            
            currentPanel = panel;
            
            if (panel != null)
                panel.SetActive(true);
        }
        
        private void UpdateCarInfo()
        {
            var vehicle = GameManager.Instance.GetCurrentVehicle();
            
            if (vehicle != null)
            {
                if (carNameText != null)
                    carNameText.text = $"{vehicle.manufacturer} {vehicle.vehicleName}";
                
                if (carStatsText != null)
                {
                    carStatsText.text = $@"
Мощность: {vehicle.currentStats.power:F0} л.с.
Крутящий момент: {vehicle.currentStats.torque:F0} Нм
Вес: {vehicle.currentStats.weight:F0} кг
Сцепление: {vehicle.currentStats.grip:F2}
                    ";
                }
            }
        }
        
        #endregion
        
        #region ESC
        
        private void Update()
        {
            if (Input.GetKeyDown(KeyCode.Escape))
            {
                if (currentPanel != mainPanel && currentPanel != null)
                {
                    ShowPanel(mainPanel);
                }
            }
        }
        
        #endregion
    }
}

using UnityEngine;
using UnityEngine.UI;
using DragRace.Core;
using DragRace.Data;

namespace DragRace.UI.Menus
{
    /// <summary>
    /// Меню игры (гараж, тюнинг, магазин, заезд)
    /// </summary>
    public class GameMenuUI : MonoBehaviour
    {
        [Header("Панели")]
        [SerializeField] private GameObject mainPanel;
        [SerializeField] private GameObject garagePanel;
        [SerializeField] private GameObject tuningPanel;
        [SerializeField] private GameObject shopPanel;
        [SerializeField] private GameObject raceSelectPanel;

        [Header("Кнопки")]
        [SerializeField] private Button raceButton;
        [SerializeField] private Button garageButton;
        [SerializeField] private Button tuningButton;
        [SerializeField] private Button shopButton;
        [SerializeField] private Button menuButton;

        [Header("Информация об автомобиле")]
        [SerializeField] private Text carNameText;
        [SerializeField] private Text carStatsText;
        [SerializeField] private Image carImage;

        [Header("Выбор заезда")]
        [SerializeField] private Button quarterMileButton;
        [SerializeField] private Button halfMileButton;
        [SerializeField] private Button fullMileButton;
        [SerializeField] private Button testRunButton;

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
            raceButton?.onClick.AddListener(OnRaceClicked);
            garageButton?.onClick.AddListener(OnGarageClicked);
            tuningButton?.onClick.AddListener(OnTuningClicked);
            shopButton?.onClick.AddListener(OnShopClicked);
            menuButton?.onClick.AddListener(OnMenuClicked);
            quarterMileButton?.onClick.AddListener(() => StartRace(402f));
            halfMileButton?.onClick.AddListener(() => StartRace(804f));
            fullMileButton?.onClick.AddListener(() => StartRace(1609f));
            testRunButton?.onClick.AddListener(() => StartRace(402f, true));
        }

        private void UnsubscribeFromEvents()
        {
            raceButton?.onClick.RemoveListener(OnRaceClicked);
            garageButton?.onClick.RemoveListener(OnGarageClicked);
            tuningButton?.onClick.RemoveListener(OnTuningClicked);
            shopButton?.onClick.RemoveListener(OnShopClicked);
            menuButton?.onClick.RemoveListener(OnMenuClicked);
        }

        #region Обработчики

        private void OnRaceClicked() => ShowPanel(raceSelectPanel);
        private void OnGarageClicked()
        {
            ShowPanel(garagePanel);
            UpdateCarInfo();
        }
        private void OnTuningClicked() => ShowPanel(tuningPanel);
        private void OnShopClicked() => ShowPanel(shopPanel);

        private void OnMenuClicked()
        {
            GameManager.Instance.ChangeState(GameState.MainMenu);
        }

        #endregion

        #region Заезд

        private void StartRace(float distance, bool isTest = false)
        {
            var raceType = isTest ? RaceType.Test : RaceType.Street;
            GameManager.Instance.ChangeState(GameState.Racing);
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
                carNameText.text = $"{vehicle.manufacturer} {vehicle.vehicleName}";
                carStatsText.text = $@"
Мощность: {vehicle.currentStats.power:F0} л.с.
Крутящий момент: {vehicle.currentStats.torque:F0} Нм
Вес: {vehicle.currentStats.weight:F0} кг
Сцепление: {vehicle.currentStats.grip:F2}
                ";
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

    public enum RaceType { Test, Street, Professional, Championship }
}

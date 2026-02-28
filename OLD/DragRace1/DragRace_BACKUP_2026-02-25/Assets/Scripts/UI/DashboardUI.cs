using UnityEngine;
using UnityEngine.UI;
using DragRace.Core;
using DragRace.Vehicles;
using DragRace.Racing;

namespace DragRace.UI
{
    /// <summary>
    /// Приборная панель во время заезда
    /// </summary>
    public class DashboardUI : MonoBehaviour
    {
        [Header("Тахометр")]
        [SerializeField] private Image rpmNeedle;
        [SerializeField] private float maxRpmAngle = 270f;
        [SerializeField] private float minRpmAngle = -90f;

        [Header("Спидометр")]
        [SerializeField] private Text speedText;
        [SerializeField] private Image speedNeedle;

        [Header("Передача")]
        [SerializeField] private Text gearText;

        [Header("Нитро")]
        [SerializeField] private Image nitroBar;
        [SerializeField] private GameObject nitroContainer;

        [Header("Дистанция")]
        [SerializeField] private Slider distanceSlider;
        [SerializeField] private Text distanceText;

        [Header("Время")]
        [SerializeField] private Text timerText;

        private VehiclePhysics playerVehicle;

        private void Start()
        {
            playerVehicle = FindFirstObjectByType<VehiclePhysics>();

            if (playerVehicle != null)
            {
                playerVehicle.OnVehicleStateChanged += OnVehicleStateUpdated;
                playerVehicle.OnGearChangedEvent += OnGearChanged;
            }

            if (RaceManager.Instance != null)
            {
                RaceManager.Instance.OnRaceStateChanged += OnRaceStateChanged;
            }
        }

        private void OnDestroy()
        {
            if (playerVehicle != null)
            {
                playerVehicle.OnVehicleStateChanged -= OnVehicleStateUpdated;
                playerVehicle.OnGearChangedEvent -= OnGearChanged;
            }

            if (RaceManager.Instance != null)
            {
                RaceManager.Instance.OnRaceStateChanged -= OnRaceStateChanged;
            }
        }

        private void Update()
        {
            if (playerVehicle != null && playerVehicle.enabled)
            {
                UpdateDashboard();
            }

            if (RaceManager.Instance != null && RaceManager.Instance.CurrentState == RaceState.Racing)
            {
                UpdateTimer();
            }
        }

        #region Обновление приборов

        private void UpdateDashboard()
        {
            UpdateRpmGauge();
            UpdateSpeedGauge();
            UpdateGear();
            UpdateNitro();
            UpdateDistance();
        }

        private void UpdateRpmGauge()
        {
            if (rpmNeedle == null || playerVehicle == null) return;

            float rpm = playerVehicle.currentRpm;
            float maxRpm = playerVehicle.engine?.maxRpm ?? 8000f;
            float rpmNormalized = rpm / maxRpm;

            float angle = Mathf.Lerp(minRpmAngle, maxRpmAngle, rpmNormalized);
            rpmNeedle.transform.rotation = Quaternion.Euler(0, 0, angle);

            if (playerVehicle.engine != null && rpm >= playerVehicle.engine.redlineRpm)
            {
                rpmNeedle.color = Color.red;
            }
            else
            {
                rpmNeedle.color = Color.white;
            }
        }

        private void UpdateSpeedGauge()
        {
            if (speedText == null || playerVehicle == null) return;

            float speedKmh = playerVehicle.GetSpeedKmh();
            speedText.text = $"{speedKmh:F0} км/ч";

            if (speedNeedle != null)
            {
                float maxSpeed = 400f;
                float speedNormalized = Mathf.Clamp01(speedKmh / maxSpeed);
                float angle = Mathf.Lerp(minRpmAngle, maxRpmAngle, speedNormalized);
                speedNeedle.transform.rotation = Quaternion.Euler(0, 0, angle);
            }
        }

        private void UpdateGear()
        {
            if (gearText == null || playerVehicle == null) return;

            int gear = playerVehicle.currentGear;
            gearText.text = gear == 0 ? "N" : gear.ToString();
        }

        private void UpdateNitro()
        {
            if (nitroContainer == null || playerVehicle == null) return;

            if (playerVehicle.nitroSystem == null)
            {
                nitroContainer.SetActive(false);
                return;
            }

            nitroContainer.SetActive(true);

            if (nitroBar != null)
            {
                nitroBar.fillAmount = playerVehicle.nitroCharge;
            }
        }

        private void UpdateDistance()
        {
            if (distanceSlider == null || playerVehicle == null) return;

            distanceSlider.value = playerVehicle.GetProgress();

            if (distanceText != null)
            {
                float distance = playerVehicle.GetDistanceMeters();
                distanceText.text = $"{distance:F1} м";
            }
        }

        private void UpdateTimer()
        {
            if (timerText == null || RaceManager.Instance == null) return;

            float time = RaceManager.Instance.RaceTime;
            timerText.text = $"{time:F3} с";
        }

        #endregion

        #region События

        private void OnVehicleStateUpdated(VehiclePhysics vehicle) { }

        private void OnGearChanged(int newGear)
        {
            if (gearText != null)
            {
                gearText.text = newGear == 0 ? "N" : newGear.ToString();
            }
        }

        private void OnRaceStateChanged(RaceState state)
        {
            switch (state)
            {
                case RaceState.Finished:
                    ShowFinishMessage();
                    break;
            }
        }

        #endregion

        #region Сообщения

        private void ShowFinishMessage()
        {
            if (RaceManager.Instance != null)
            {
                bool isWin = RaceManager.Instance.currentRaceResult?.isWin ?? false;
                Debug.Log(isWin ? "ПОБЕДА!" : "ПОРАЖЕНИЕ");
            }
        }

        #endregion
    }
}

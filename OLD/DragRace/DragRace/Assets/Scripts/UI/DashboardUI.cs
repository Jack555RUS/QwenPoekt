using UnityEngine;
using UnityEngine.UI;
using DragRace.Vehicles;
using DragRace.Racing;
using DragRace.Core;

namespace DragRace.UI
{
    /// <summary>
    /// Приборная панель во время заезда
    /// </summary>
    public class DashboardUI : MonoBehaviour
    {
        [Header("Тахометр")]
        public Image rpmNeedle;
        public float maxRpmAngle = 270f;
        public float minRpmAngle = -90f;
        
        [Header("Спидометр")]
        public Text speedText;
        public Image speedNeedle;
        public float maxSpeedAngle = 270f;
        public float minSpeedAngle = -90f;
        
        [Header("Передача")]
        public Text gearText;
        
        [Header("Нитро")]
        public Image nitroBar;
        public GameObject nitroContainer;
        
        [Header("Дистанция")]
        public Slider distanceSlider;
        public Text distanceText;
        
        [Header("Время")]
        public Text timerText;
        
        [Header("Светофор")]
        public GameObject trafficLightContainer;
        public Image redLight;
        public Image yellowLight;
        public Image greenLight;
        
        [Header("Сообщения")]
        public Text messageText;
        public GameObject messageContainer;
        
        private VehiclePhysics playerVehicle;
        
        private void Start()
        {
            playerVehicle = FindObjectOfType<VehiclePhysics>();
            
            if (playerVehicle != null)
            {
                playerVehicle.OnVehicleStateChanged += OnVehicleStateUpdated;
                playerVehicle.OnGearChanged += OnGearChanged;
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
                playerVehicle.OnGearChanged -= OnGearChanged;
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
            // Тахометр
            UpdateRpmGauge();
            
            // Спидометр
            UpdateSpeedGauge();
            
            // Передача
            UpdateGear();
            
            // Нитро
            UpdateNitro();
            
            // Дистанция
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
            
            // Цвет на отсечке
            if (rpm >= playerVehicle.engine?.redlineRpm)
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
                float maxSpeed = 400f; // Максимальная скорость для шкалы
                float speedNormalized = Mathf.Clamp01(speedKmh / maxSpeed);
                
                float angle = Mathf.Lerp(minSpeedAngle, maxSpeedAngle, speedNormalized);
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
        
        private void OnVehicleStateUpdated(VehiclePhysics vehicle)
        {
            // Обновление в реальном времени
        }
        
        private void OnGearChanged(int newGear)
        {
            // Анимация или эффект при переключении
            if (messageContainer != null && messageText != null)
            {
                messageText.text = newGear == 0 ? "Нейтраль" : $"{newGear}";
                messageContainer.SetActive(true);
                
                CancelInvoke(nameof(HideMessage));
                Invoke(nameof(HideMessage), 0.5f);
            }
        }
        
        private void OnRaceStateChanged(RaceState state)
        {
            switch (state)
            {
                case RaceState.Preparing:
                    ShowTrafficLights();
                    break;
                case RaceState.Racing:
                    HideTrafficLights();
                    break;
                case RaceState.Finished:
                    ShowFinishMessage();
                    break;
            }
        }
        
        #endregion
        
        #region Светофор
        
        private void ShowTrafficLights()
        {
            if (trafficLightContainer != null)
                trafficLightContainer.SetActive(true);
        }
        
        private void HideTrafficLights()
        {
            if (trafficLightContainer != null)
                trafficLightContainer.SetActive(false);
        }
        
        public void SetTrafficLight(TrafficLightState state)
        {
            if (redLight != null) redLight.enabled = state == TrafficLightState.Red;
            if (yellowLight != null) yellowLight.enabled = state == TrafficLightState.Yellow;
            if (greenLight != null) greenLight.enabled = state == TrafficLightState.Green;
        }
        
        #endregion
        
        #region Сообщения
        
        private void HideMessage()
        {
            if (messageContainer != null)
                messageContainer.SetActive(false);
        }
        
        private void ShowFinishMessage()
        {
            if (messageContainer != null && messageText != null)
            {
                bool isWin = RaceManager.Instance.currentRaceResult?.isWin ?? false;
                messageText.text = isWin ? "ПОБЕДА!" : "ПОРАЖЕНИЕ";
                messageText.color = isWin ? Color.green : Color.red;
                messageContainer.SetActive(true);
            }
        }
        
        #endregion
    }
    
    public enum TrafficLightState
    {
        Off,
        Red,
        Yellow,
        Green
    }
}

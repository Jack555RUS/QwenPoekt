using UnityEngine;
using UnityEngine.UI;
using ProbMenu.Core;
using ProbMenu.Physics;
using Logger = ProbMenu.Core.Logger;

namespace ProbMenu.UI
{
    /// <summary>
    /// Приборная панель автомобиля
    /// Спидометр, тахометр, передача, нитро
    /// </summary>
    public class DashboardUI : MonoBehaviour
    {
        [Header("Ссылки")]
        [SerializeField] private CarPhysics carPhysics;
        
        [Header("Текст")]
        [SerializeField] private Text speedText;
        [SerializeField] private Text rpmText;
        [SerializeField] private Text gearText;
        [SerializeField] private Text nitroText;
        
        [Header("Слайдеры")]
        [SerializeField] private Slider rpmSlider;
        [SerializeField] private Slider nitroSlider;
        
        [Header("Стрелки")]
        [SerializeField] private RectTransform speedNeedle;
        [SerializeField] private RectTransform rpmNeedle;
        
        [Header("Настройки")]
        [SerializeField] private float maxSpeed = 350f;     // км/ч
        [SerializeField] private float maxRpm = 8000f;      // об/мин
        
        [Header("Лампочки")]
        [SerializeField] private GameObject checkEngineLight;
        [SerializeField] private GameObject nitroReadyLight;
        
        private void Start()
        {
            Logger.AssertNotNull(carPhysics, "CarPhysics");
            
            if (carPhysics == null)
            {
                Logger.W("CarPhysics not found, trying to find in scene...");
                carPhysics = FindObjectOfType<CarPhysics>();
            }
            
            Logger.I("DashboardUI initialized");
        }
        
        private void Update()
        {
            if (carPhysics == null) return;
            
            UpdateSpeedometer();
            UpdateTachometer();
            UpdateGear();
            UpdateNitro();
            CheckWarnings();
        }
        
        #region Speedometer
        
        private void UpdateSpeedometer()
        {
            float speed = carPhysics.GetSpeedKmh();
            
            if (speedText != null)
            {
                speedText.text = $"{speed:F0}";
            }
            
            if (speedNeedle != null)
            {
                float angle = (speed / maxSpeed) * 270f - 135f; // -135 to +135 degrees
                speedNeedle.localRotation = Quaternion.Euler(0, 0, angle);
            }
        }
        
        #endregion
        
        #region Tachometer
        
        private void UpdateTachometer()
        {
            float rpm = carPhysics.GetRpm();
            
            if (rpmText != null)
            {
                rpmText.text = $"{rpm:F0}";
            }
            
            if (rpmSlider != null)
            {
                rpmSlider.value = rpm / maxRpm;
            }
            
            if (rpmNeedle != null)
            {
                float angle = (rpm / maxRpm) * 270f - 135f;
                rpmNeedle.localRotation = Quaternion.Euler(0, 0, angle);
            }
            
            // Красная зона
            if (rpm > maxRpm * 0.9f)
            {
                if (rpmText != null)
                    rpmText.color = Color.red;
            }
            else
            {
                if (rpmText != null)
                    rpmText.color = Color.white;
            }
        }
        
        #endregion
        
        #region Gear
        
        private void UpdateGear()
        {
            int gear = carPhysics.GetGear();
            
            if (gearText != null)
            {
                gearText.text = gear.ToString();
            }
        }
        
        #endregion
        
        #region Nitro
        
        private void UpdateNitro()
        {
            float nitro = carPhysics.GetNitroAmount();
            
            if (nitroText != null)
            {
                nitroText.text = $"{nitro:F0}%";
            }
            
            if (nitroSlider != null)
            {
                nitroSlider.value = nitro / 100f;
            }
            
            // Лампочка готовности
            if (nitroReadyLight != null)
            {
                nitroReadyLight.SetActive(nitro > 50f);
            }
        }
        
        #endregion
        
        #region Warnings
        
        private void CheckWarnings()
        {
            // Проверка двигателя
            if (checkEngineLight != null && carPhysics != null)
            {
                float engineTemp = carPhysics.GetEngineTemp();
                checkEngineLight.SetActive(engineTemp > 100f);
            }
        }
        
        #endregion
        
        #region Helpers
        
        public void SetCarPhysics(CarPhysics physics)
        {
            carPhysics = physics;
            Logger.AssertNotNull(carPhysics, "CarPhysics");
        }
        
        public void Reset()
        {
            if (speedText != null) speedText.text = "0";
            if (rpmText != null) rpmText.text = "0";
            if (gearText != null) gearText.text = "N";
            if (nitroText != null) nitroText.text = "100%";
            
            if (speedNeedle != null) speedNeedle.localRotation = Quaternion.Euler(0, 0, -135f);
            if (rpmNeedle != null) rpmNeedle.localRotation = Quaternion.Euler(0, 0, -135f);
            
            if (rpmSlider != null) rpmSlider.value = 0;
            if (nitroSlider != null) nitroSlider.value = 1;
        }
        
        #endregion
        
        #region Debug
        
        private void OnGUI()
        {
            if (!Application.isEditor) return;
            
            if (carPhysics == null) return;
            
            GUILayout.BeginArea(new Rect(10, 530, 400, 100));
            GUILayout.Label("=== DASHBOARD ===");
            GUILayout.Label($"Speed: {carPhysics.GetSpeedKmh():F1} km/h");
            GUILayout.Label($"RPM: {carPhysics.GetRpm():F0}");
            GUILayout.Label($"Gear: {carPhysics.GetGear()}");
            GUILayout.Label($"Nitro: {carPhysics.GetNitroAmount():F1}%");
            GUILayout.EndArea();
        }
        
        #endregion
    }
}

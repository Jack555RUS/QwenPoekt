using UnityEngine;
using ProbMenu.Core;
using ProbMenu.Data;
using Logger = ProbMenu.Core.Logger;

namespace ProbMenu.Physics
{
    /// <summary>
    /// Физика автомобиля
    /// Реалистичная модель: двигатель, КПП, шины, аэродинамика
    /// </summary>
    public class CarPhysics : MonoBehaviour
    {
        [Header("Данные автомобиля")]
        [SerializeField] private CarData carData;
        
        [Header("Текущее состояние")]
        [SerializeField] private float currentSpeed;        // м/с
        [SerializeField] private float currentRpm;          // об/мин
        [SerializeField] private int currentGear = 1;       // текущая передача
        [SerializeField] private float distanceTraveled;    // пройденная дистанция (м)
        
        [Header("Ввод")]
        [SerializeField] private bool isGasPressed;
        [SerializeField] private bool isBrakePressed;
        [SerializeField] private bool isNitroPressed;
        [SerializeField] private bool isShiftUpPressed;
        [SerializeField] private bool isShiftDownPressed;
        
        [Header("Параметры")]
        [SerializeField] private float dragArea;            // лобовая площадь (м²)
        [SerializeField] private float rollingResistance;   // коэффициент качения
        [SerializeField] private float finalDriveRatio;     // главная передача
        
        [Header("Состояние")]
        private bool isEngineRunning;
        private float engineTemperature;
        private float tireTemperature;
        private float nitroAmount = 100f;
        
        [Header("События")]
        public System.Action<float> OnSpeedChanged;
        public System.Action<int> OnGearChanged;
        public System.Action<float> OnRpmChanged;
        public System.Action OnRaceFinished;
        
        // Константы
        private const float AIR_DENSITY = 1.225f;          // кг/м³
        private const float GRAVITY = 9.81f;               // м/с²
        private const float MAX_RPM = 8000f;               // макс. обороты
        private const float IDLE_RPM = 1000f;              // холостой ход
        private const float NITRO_BONUS = 1.3f;            // бонус нитро (30%)
        
        private void Start()
        {
            InitializeCar();
            Logger.I($"CarPhysics initialized: {carData?.carName ?? "Unknown"}");
        }
        
        private void Update()
        {
            if (!isEngineRunning) return;
            
            HandleInput();
            UpdateEngine();
            UpdateTransmission();
            UpdatePhysics();
            UpdateTemperature();
            CheckFinish();
        }
        
        #region Initialization
        
        private void InitializeCar()
        {
            Logger.AssertNotNull(carData, "CarData is null!");
            
            if (carData == null)
            {
                Logger.W("CarData not assigned, using defaults");
                CreateDefaultCarData();
                return;
            }
            
            // Инициализация параметров
            dragArea = carData.dragCoefficient * carData.frontalArea;
            rollingResistance = 0.015f; // Стандартные шины
            
            Logger.I($"Car initialized: {carData.carName}");
            Logger.I($"Weight: {carData.weight}kg, Power: {carData.engineData.maxPower}hp");
        }
        
        private void CreateDefaultCarData()
        {
            carData = ScriptableObject.CreateInstance<CarData>();
            carData.carName = "Default Car";
            carData.weight = 1500f;
            carData.dragCoefficient = 0.3f;
            carData.frontalArea = 2.2f;
            
            carData.engineData = new EngineData
            {
                maxPower = 300f,
                maxPowerRpm = 6500,
                maxTorque = 400f,
                maxTorqueRpm = 4000,
                maxRpm = 8000,
                idleRpm = 1000
            };
            
            carData.transmissionData = new TransmissionData
            {
                type = TransmissionType.Manual,
                gearsCount = 6,
                gearRatios = new float[] { 3.5f, 2.5f, 1.8f, 1.4f, 1.0f, 0.8f },
                finalDrive = 3.5f
            };
        }
        
        #endregion
        
        #region Input Handling
        
        private void HandleInput()
        {
            // Получаем ввод из InputManager
            var inputManager = Input.InputManager.Instance;
            
            if (inputManager != null)
            {
                isGasPressed = inputManager.IsGasPressed();
                isBrakePressed = UnityEngine.Input.GetKey(KeyCode.Space) || UnityEngine.Input.GetKey(KeyCode.S);
                isNitroPressed = inputManager.IsNitroPressed();
                
                if (inputManager.IsShiftUpPressed())
                    ShiftUp();
                
                if (inputManager.IsShiftDownPressed())
                    ShiftDown();
            }
            else
            {
                // Fallback для тестов
                isGasPressed = UnityEngine.Input.GetKey(KeyCode.W) || UnityEngine.Input.GetKey(KeyCode.UpArrow);
                isBrakePressed = UnityEngine.Input.GetKey(KeyCode.Space);
                isNitroPressed = UnityEngine.Input.GetKey(KeyCode.LeftShift);
                
                if (UnityEngine.Input.GetKeyDown(KeyCode.D) || UnityEngine.Input.GetKeyDown(KeyCode.RightArrow))
                    ShiftUp();
                
                if (UnityEngine.Input.GetKeyDown(KeyCode.A) || UnityEngine.Input.GetKeyDown(KeyCode.LeftArrow))
                    ShiftDown();
            }
        }
        
        #endregion
        
        #region Engine
        
        private void UpdateEngine()
        {
            // Расчёт оборотов двигателя
            if (isGasPressed)
            {
                currentRpm += 150f * Time.deltaTime * (1f + (isNitroPressed && nitroAmount > 0 ? 0.5f : 0f));
            }
            else
            {
                currentRpm -= 100f * Time.deltaTime;
            }
            
            // Ограничения RPM
            currentRpm = Mathf.Clamp(currentRpm, IDLE_RPM, MAX_RPM);
            
            // Расчёт мощности от RPM (упрощённая кривая)
            float powerCurve = GetPowerCurve(currentRpm);
            float currentPower = carData.engineData.maxPower * powerCurve;
            
            // Нитро бонус
            if (isNitroPressed && nitroAmount > 0)
            {
                currentPower *= NITRO_BONUS;
                nitroAmount -= 30f * Time.deltaTime;
                nitroAmount = Mathf.Max(0, nitroAmount);
            }
            
            Logger.AssertRange(currentRpm, IDLE_RPM, MAX_RPM, "Engine RPM");
            
            OnRpmChanged?.Invoke(currentRpm);
        }
        
        /// <summary>
        /// Кривая мощности от RPM (упрощённая)
        /// </summary>
        private float GetPowerCurve(float rpm)
        {
            float normalizedRpm = rpm / MAX_RPM;
            
            // Параболическая кривая: пик на 70-80% RPM
            float peak = 0.75f;
            float power = 1f - Mathf.Pow(normalizedRpm - peak, 2) * 2f;
            
            return Mathf.Clamp01(power);
        }
        
        #endregion
        
        #region Transmission
        
        private void UpdateTransmission()
        {
            // Автоматическое переключение (если нужно)
            if (carData.transmissionData.type == TransmissionType.Automatic)
            {
                if (currentRpm > 6500 && currentGear < carData.transmissionData.gearsCount)
                    ShiftUp();
                else if (currentRpm < 3000 && currentGear > 1)
                    ShiftDown();
            }
        }
        
        public void ShiftUp()
        {
            if (currentGear < carData.transmissionData.gearsCount)
            {
                currentGear++;
                currentRpm *= 0.7f; // Падение оборотов при переключении
                Logger.D($"Shift UP: Gear {currentGear}");
                OnGearChanged?.Invoke(currentGear);
            }
        }
        
        public void ShiftDown()
        {
            if (currentGear > 1)
            {
                currentGear--;
                currentRpm *= 1.3f; // Рост оборотов при переключении
                Logger.D($"Shift DOWN: Gear {currentGear}");
                OnGearChanged?.Invoke(currentGear);
            }
        }
        
        private float GetTotalGearRatio()
        {
            float gearRatio = carData.transmissionData.gearRatios[currentGear - 1];
            return gearRatio * carData.transmissionData.finalDrive;
        }
        
        #endregion
        
        #region Physics
        
        private void UpdatePhysics()
        {
            // Сила от двигателя
            float gearRatio = GetTotalGearRatio();
            float engineTorque = carData.engineData.maxTorque * GetPowerCurve(currentRpm);
            float wheelTorque = engineTorque * gearRatio;
            float wheelForce = wheelTorque / 0.3f; // Радиус колеса ~0.3м
            
            // Сила сопротивления воздуха
            float dragForce = 0.5f * AIR_DENSITY * dragArea * 0.3f * currentSpeed * currentSpeed;
            
            // Сила сопротивления качению
            float rollingForce = carData.weight * GRAVITY * rollingResistance;
            
            // Сила торможения
            float brakeForce = isBrakePressed ? 5000f : 0f;
            
            // Итоговая сила
            float totalForce = wheelForce - dragForce - rollingForce - brakeForce;
            
            // Ускорение (F = ma)
            float acceleration = totalForce / carData.weight;
            
            // Обновление скорости
            currentSpeed += acceleration * Time.deltaTime;
            currentSpeed = Mathf.Max(0, currentSpeed);
            
            // Обновление дистанции
            distanceTraveled += currentSpeed * Time.deltaTime;
            
            Logger.Assert(currentSpeed >= 0, "Negative speed!");
            
            OnSpeedChanged?.Invoke(currentSpeed);
        }
        
        #endregion
        
        #region Temperature
        
        private void UpdateTemperature()
        {
            // Нагрев двигателя
            if (isGasPressed)
            {
                engineTemperature += 0.5f * Time.deltaTime;
            }
            else
            {
                engineTemperature -= 0.3f * Time.deltaTime;
            }
            
            engineTemperature = Mathf.Clamp(engineTemperature, 20f, 120f);
            
            // Нагрев шин
            tireTemperature += currentSpeed * 0.01f * Time.deltaTime;
            tireTemperature = Mathf.Clamp(tireTemperature, 20f, 100f);
        }
        
        #endregion
        
        #region Race Management
        
        private void CheckFinish()
        {
            // Проверка финиша (дистанция 402м = 1/4 мили)
            if (distanceTraveled >= 402f)
            {
                Logger.I($"🏁 RACE FINISHED! Time: {GetRaceTime():F2}s");
                OnRaceFinished?.Invoke();
            }
        }
        
        public float GetRaceTime()
        {
            // TODO: Сохранять время старта
            return Time.time;
        }
        
        #endregion
        
        #region Getters
        
        public float GetSpeed() => currentSpeed;
        public float GetSpeedKmh() => currentSpeed * 3.6f;
        public float GetRpm() => currentRpm;
        public int GetGear() => currentGear;
        public float GetDistance() => distanceTraveled;
        public float GetNitroAmount() => nitroAmount;
        public float GetEngineTemp() => engineTemperature;
        public float GetTireTemp() => tireTemperature;
        
        public void SetCarData(CarData data)
        {
            carData = data;
            Logger.AssertNotNull(carData, "CarData");
            InitializeCar();
        }
        
        public void StartEngine()
        {
            isEngineRunning = true;
            currentRpm = IDLE_RPM;
            Logger.I("Engine started");
        }
        
        public void StopEngine()
        {
            isEngineRunning = false;
            currentRpm = 0;
            Logger.I("Engine stopped");
        }
        
        public void Reset()
        {
            currentSpeed = 0;
            currentRpm = IDLE_RPM;
            currentGear = 1;
            distanceTraveled = 0;
            nitroAmount = 100f;
            engineTemperature = 20f;
            tireTemperature = 20f;
            Logger.I("Car reset");
        }
        
        #endregion
        
        #region Debug
        
        private void OnGUI()
        {
            if (!Application.isEditor) return;
            
            GUILayout.BeginArea(new Rect(10, 220, 300, 300));
            GUILayout.Label("=== CAR PHYSICS ===");
            GUILayout.Label($"Speed: {GetSpeedKmh():F1} km/h");
            GUILayout.Label($"RPM: {currentRpm:F0}");
            GUILayout.Label($"Gear: {currentGear}");
            GUILayout.Label($"Distance: {distanceTraveled:F1} m");
            GUILayout.Label($"Nitro: {nitroAmount:F1}%");
            GUILayout.Label($"Engine Temp: {engineTemperature:F1}°C");
            GUILayout.Label($"Tire Temp: {tireTemperature:F1}°C");
            GUILayout.EndArea();
        }
        
        #endregion
    }
}

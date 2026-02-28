using UnityEngine;

namespace DragRace.Vehicles
{
    /// <summary>
    /// Физика автомобиля для драг-рейсинга
    /// Реализует реалистичное ускорение с учётом:
    /// - Мощности двигателя
    /// - Передаточных чисел
    /// - Аэродинамического сопротивления
    /// - Сопротивления качению
    /// - Сцепления шин
    /// </summary>
    public class CarPhysics : MonoBehaviour
    {
        #region Parameters
        
        [Header("Основные данные")]
        [Tooltip("Данные автомобиля")]
        public Data.VehicleData vehicleData;
        
        [Header("Текущее состояние")]
        [Tooltip("Текущая скорость (м/с)")]
        public float currentSpeed;
        
        [Tooltip("Текущие обороты двигателя (RPM)")]
        public float currentRpm;
        
        [Tooltip("Текущая передача")]
        public int currentGear = 0; // 0 = neutral
        
        [Tooltip("Пройденная дистанция (м)")]
        public float distanceTraveled;
        
        [Tooltip("Время заезда")]
        public float raceTime;
        
        [Header("Параметры симуляции")]
        [Tooltip("Плотность воздуха (кг/м³)")]
        public float airDensity = 1.225f;
        
        [Tooltip("Коэффициент сопротивления качению")]
        public float rollingResistanceCoeff = 0.015f;
        
        [Tooltip("Ускорение свободного падения (м/с²)")]
        public float gravity = 9.81f;
        
        [Header("Состояние")]
        [Tooltip("Нажата ли педаль газа")]
        public bool isThrottlePressed;
        
        [Tooltip("Используется ли нитро")]
        public bool isNitroActive;
        
        [Tooltip("Автоматическое переключение передач")]
        public bool autoShift = true;
        
        [Tooltip("Обороты для автоматического переключения вверх")]
        public float autoShiftUpRpm = 7000f;
        
        [Tooltip("Обороты для автоматического переключения вниз")]
        public float autoShiftDownRpm = 3000f;
        
        #endregion
        
        #region Events
        
        public delegate void PhysicsUpdateHandler(CarPhysics physics);
        public event PhysicsUpdateHandler OnPhysicsUpdated;
        
        public delegate void GearChangedHandler(int newGear, float rpm);
        public event GearChangedHandler OnGearChanged;
        
        public delegate void RaceFinishedHandler(CarPhysics physics, float time, float speed);
        public event RaceFinishedHandler OnRaceFinished;
        
        #endregion
        
        #region State
        
        private Data.VehicleStats currentStats;
        private float[] gearRatios;
        private float finalDriveRatio;
        private bool isRacing = false;
        private float raceDistance = 402f; // 1/4 мили по умолчанию
        private bool hasFinished = false;
        
        // Для нитро
        private float nitroDuration = 5f; // секунд
        private float currentNitroCharge = 100f; // процентов
        
        #endregion
        
        #region Properties
        
        public bool IsRacing => isRacing;
        public bool HasFinished => hasFinished;
        public float CurrentSpeedKmh => currentSpeed * 3.6f;
        public float CurrentSpeedMph => currentSpeed * 2.237f;
        public float ThrottlePosition { get; private set; }
        public float NitroCharge => currentNitroCharge;
        public Data.VehicleStats CurrentStats => currentStats;
        
        #endregion
        
        #region Unity Methods
        
        private void Awake()
        {
            InitializeVehicle();
        }
        
        private void Update()
        {
            if (!isRacing || hasFinished) return;
            
            UpdateRaceTime();
            UpdatePhysics();
            CheckGearShift();
            CheckRaceFinish();
            
            OnPhysicsUpdated?.Invoke(this);
        }
        
        #endregion
        
        #region Initialization
        
        /// <summary>
        /// Инициализация автомобиля
        /// </summary>
        public void InitializeVehicle()
        {
            if (vehicleData == null)
            {
                Debug.LogError("❌ VehicleData не назначен!");
                return;
            }
            
            currentStats = vehicleData.GetCurrentStats();
            gearRatios = vehicleData.gearRatios;
            finalDriveRatio = vehicleData.baseStats.finalDriveRatio;
            
            ResetState();
            
            Debug.Log($"✅ {vehicleData.manufacturer} {vehicleData.vehicleName} инициализирован");
            Debug.Log($"   Мощность: {currentStats.power} л.с.");
            Debug.Log($"   Вес: {currentStats.weight} кг");
        }
        
        /// <summary>
        /// Сброс состояния
        /// </summary>
        public void ResetState()
        {
            currentSpeed = 0f;
            currentRpm = vehicleData.powerCurve.idleRpm;
            currentGear = 0;
            distanceTraveled = 0f;
            raceTime = 0f;
            hasFinished = false;
            isRacing = false;
            currentNitroCharge = 100f;
            ThrottlePosition = 0f;
        }
        
        #endregion
        
        #region Race Control
        
        /// <summary>
        /// Начать заезд
        /// </summary>
        public void StartRace(float distance)
        {
            ResetState();
            raceDistance = distance;
            isRacing = true;
            
            Debug.Log($"🏁 Заезд начался: {distance}м");
        }
        
        /// <summary>
        /// Обновление времени заезда
        /// </summary>
        private void UpdateRaceTime()
        {
            raceTime += Time.deltaTime;
        }
        
        /// <summary>
        /// Проверка финиша
        /// </summary>
        private void CheckRaceFinish()
        {
            if (distanceTraveled >= raceDistance && !hasFinished)
            {
                FinishRace();
            }
        }
        
        /// <summary>
        /// Финиш заезда
        /// </summary>
        private void FinishRace()
        {
            hasFinished = true;
            isRacing = false;
            
            Debug.Log($"✅ ФИНИШ! Время: {raceTime:F3}с, Скорость: {CurrentSpeedKmh:F1} км/ч");
            
            OnRaceFinished?.Invoke(this, raceTime, currentSpeed);
        }
        
        #endregion
        
        #region Physics
        
        /// <summary>
        /// Обновление физики
        /// </summary>
        private void UpdatePhysics()
        {
            // Получаем ввод (0-1)
            float throttle = isThrottlePressed ? 1f : 0f;
            ThrottlePosition = throttle;
            
            // Расчёт силы тяги
            float tractionForce = CalculateTractionForce(throttle);
            
            // Расчёт сил сопротивления
            float dragForce = CalculateDragForce();
            float rollingForce = CalculateRollingResistance();
            
            // Суммарная сила
            float netForce = tractionForce - dragForce - rollingForce;
            
            // Ускорение (F = ma)
            float mass = currentStats.weight;
            float acceleration = netForce / mass;
            
            // Обновление скорости
            currentSpeed += acceleration * Time.deltaTime;
            currentSpeed = Mathf.Max(currentSpeed, 0f); // Не может быть отрицательной
            
            // Обновление дистанции
            distanceTraveled += currentSpeed * Time.deltaTime;
            
            // Обновление оборотов
            UpdateRpm();
        }
        
        /// <summary>
        /// Расчёт силы тяги
        /// </summary>
        private float CalculateTractionForce(float throttle)
        {
            if (currentGear == 0 || throttle <= 0f) return 0f;
            
            // Получаем крутящий момент на текущих оборотах
            float engineTorque = vehicleData.powerCurve.GetTorqueAtRpm(
                currentRpm, 
                currentStats.torque
            );
            
            // Добавляем нитро
            if (isNitroActive && currentNitroCharge > 0f)
            {
                engineTorque *= 1.3f; // +30% момента с нитро
                currentNitroCharge -= Time.deltaTime * (100f / nitroDuration);
                currentNitroCharge = Mathf.Max(currentNitroCharge, 0f);
            }
            
            // Общий коэффициент передачи
            float totalRatio = gearRatios[currentGear - 1] * finalDriveRatio;
            
            // Сила тяги на колёсах
            float wheelRadius = 0.3f; // Примерный радиус колеса (м)
            float tractionForce = (engineTorque * totalRatio) / wheelRadius;
            
            // Ограничение сцеплением
            float maxTraction = currentStats.grip * currentStats.weight * gravity * throttle;
            tractionForce = Mathf.Min(tractionForce, maxTraction);
            
            return tractionForce;
        }
        
        /// <summary>
        /// Расчёт аэродинамического сопротивления
        /// </summary>
        private float CalculateDragForce()
        {
            // Fd = 0.5 * ρ * v² * Cd * A
            float dragForce = 0.5f * airDensity * 
                             currentSpeed * currentSpeed * 
                             currentStats.dragCoefficient * 
                             currentStats.frontalArea;
            
            return dragForce;
        }
        
        /// <summary>
        /// Расчёт сопротивления качению
        /// </summary>
        private float CalculateRollingResistance()
        {
            // Fr = Crr * m * g
            float rollingForce = rollingResistanceCoeff * 
                                currentStats.weight * 
                                gravity;
            
            return rollingForce;
        }
        
        /// <summary>
        /// Обновление оборотов двигателя
        /// </summary>
        private void UpdateRpm()
        {
            if (currentGear == 0)
            {
                // Нейтраль - обороты зависят от газа
                float targetRpm = vehicleData.powerCurve.idleRpm + 
                                 (ThrottlePosition * (vehicleData.powerCurve.redlineRpm - vehicleData.powerCurve.idleRpm));
                currentRpm = Mathf.Lerp(currentRpm, targetRpm, Time.deltaTime * 5f);
                return;
            }
            
            // Расчёт оборотов от скорости
            float wheelRadius = 0.3f;
            float wheelRps = currentSpeed / (2f * Mathf.PI * wheelRadius);
            float totalRatio = gearRatios[currentGear - 1] * finalDriveRatio;
            
            float calculatedRpm = wheelRps * 60f * totalRatio;
            
            // Минимальные обороты - холостой ход
            currentRpm = Mathf.Max(calculatedRpm, vehicleData.powerCurve.idleRpm);
            
            // Ограничение отсечкой
            if (currentRpm > vehicleData.powerCurve.redlineRpm)
            {
                currentRpm = vehicleData.powerCurve.redlineRpm;
            }
        }
        
        /// <summary>
        /// Проверка переключения передач
        /// </summary>
        private void CheckGearShift()
        {
            if (!autoShift || currentGear == 0) return;
            
            // Переключение вверх
            if (currentRpm >= autoShiftUpRpm && currentGear < gearRatios.Length)
            {
                ShiftUp();
            }
            // Переключение вниз
            else if (currentRpm <= autoShiftDownRpm && currentGear > 1)
            {
                ShiftDown();
            }
        }
        
        #endregion
        
        #region Gear Control
        
        /// <summary>
        /// Переключение вверх
        /// </summary>
        public void ShiftUp()
        {
            if (currentGear < gearRatios.Length)
            {
                currentGear++;
                OnGearChanged?.Invoke(currentGear, currentRpm);
                Debug.Log($"⬆️ Передача: {currentGear}");
            }
        }
        
        /// <summary>
        /// Переключение вниз
        /// </summary>
        public void ShiftDown()
        {
            if (currentGear > 1)
            {
                currentGear--;
                OnGearChanged?.Invoke(currentGear, currentRpm);
                Debug.Log($"⬇️ Передача: {currentGear}");
            }
        }
        
        /// <summary>
        /// Установить передачу
        /// </summary>
        public void SetGear(int gear)
        {
            if (gear >= 0 && gear <= gearRatios.Length)
            {
                currentGear = gear;
                OnGearChanged?.Invoke(currentGear, currentRpm);
            }
        }
        
        #endregion
        
        #region Nitro
        
        /// <summary>
        /// Активировать нитро
        /// </summary>
        public void ActivateNitro()
        {
            if (currentNitroCharge > 0f)
            {
                isNitroActive = true;
                Debug.Log("🔵 Нитро активировано!");
            }
        }
        
        /// <summary>
        /// Деактивировать нитро
        /// </summary>
        public void DeactivateNitro()
        {
            isNitroActive = false;
        }
        
        /// <summary>
        /// Перезарядить нитро
        /// </summary>
        public void RechargeNitro()
        {
            currentNitroCharge = 100f;
        }
        
        #endregion
        
        #region Debug
        
        /// <summary>
        /// Отладочная информация
        /// </summary>
        public string GetDebugInfo()
        {
            return $@"Скорость: {CurrentSpeedKmh:F1} км/ч
Обороты: {currentRpm:F0} RPM
Передача: {currentGear}
Дистанция: {distanceTraveled:F1}м
Время: {raceTime:F2}с
Нитро: {currentNitroCharge:F0}%";
        }
        
        #endregion
    }
}

using UnityEngine;
using DragRace.Data;
using DragRace.Core;

namespace DragRace.Vehicles
{
    /// <summary>
    /// Физика автомобиля для драг-рейсинга
    /// </summary>
    public class VehiclePhysics : MonoBehaviour
    {
        [Header("Ссылки на данные")]
        public VehicleData vehicleData;
        public Engine engine;
        public Transmission transmission;
        public Tires tires;
        public NitroSystem nitroSystem;
        
        [Header("Текущее состояние")]
        public float currentSpeed; // м/с
        public float currentRpm;
        public int currentGear; // 0 = нейтраль
        public float distanceTraveled; // метры
        public float nitroCharge; // 0-1
        
        [Header("Параметры")]
        public float airDensity = 1.225f; // кг/м³
        public float rollingResistance = 0.015f;
        public float gravity = 9.81f;
        
        // События
        public delegate void VehicleStateHandler(VehiclePhysics vehicle);
        public event VehicleStateHandler OnVehicleStateChanged;
        public event OnGearChanged OnGearChanged;
        public event OnRaceFinish OnRaceFinished;
        
        private bool isRacing;
        private float raceDistance;
        
        private void Update()
        {
            if (!isRacing) return;
            
            UpdatePhysics();
            CheckRaceFinish();
            
            OnVehicleStateChanged?.Invoke(this);
        }
        
        #region Физика
        
        private void UpdatePhysics()
        {
            // Получаем вход от игрока
            float throttle = DragRace.InputSystem.InputManager.Instance?.AccelerateInput ?? 0f;
            
            // Расчёт силы тяги
            float tractionForce = CalculateTractionForce(throttle);
            
            // Сопротивления
            float dragForce = CalculateDragForce();
            float rollingForce = CalculateRollingResistance();
            
            // Итоговая сила
            float netForce = tractionForce - dragForce - rollingForce;
            
            // Ускорение (F = ma)
            float mass = vehicleData.currentStats.weight;
            float acceleration = netForce / mass;
            
            // Обновляем скорость
            currentSpeed += acceleration * Time.deltaTime;
            currentSpeed = Mathf.Max(currentSpeed, 0f); // Не меньше 0
            
            // Обновляем дистанцию
            distanceTraveled += currentSpeed * Time.deltaTime;
            
            // Обновляем обороты двигателя
            UpdateRPM();
        }
        
        private float CalculateTractionForce(float throttle)
        {
            if (currentGear <= 0 || currentGear > transmission.gearCount)
                return 0f;
            
            // Мощность двигателя на текущих оборотах
            float enginePower = engine.GetPowerAtRpm(currentRpm);
            float engineTorque = engine.GetTorqueAtRpm(currentRpm);
            
            // Буст от нитро
            if (nitroSystem != null && nitroCharge > 0 && throttle >= 1f)
            {
                enginePower += nitroSystem.powerBoost;
                engineTorque *= 1.3f;
            }
            
            // Крутящий момент на колёсах
            float wheelTorque = transmission.GetWheelTorque(engineTorque, currentGear);
            
            // Сила тяги (F = T / r, где r - радиус колеса ~0.3м)
            float wheelRadius = 0.3f;
            float tractionForce = wheelTorque / wheelRadius;
            
            // Ограничение по сцеплению
            float maxTraction = vehicleData.currentStats.grip * vehicleData.currentStats.weight * gravity;
            tractionForce = Mathf.Min(tractionForce * throttle, maxTraction);
            
            return tractionForce;
        }
        
        private float CalculateDragForce()
        {
            // Fd = 0.5 * ρ * v² * Cd * A
            float dragCoefficient = 1f - vehicleData.currentStats.aerodynamics;
            float frontalArea = 2.0f; // м² (примерно)
            
            return 0.5f * airDensity * currentSpeed * currentSpeed * dragCoefficient * frontalArea;
        }
        
        private float CalculateRollingResistance()
        {
            // Frr = Crr * m * g
            return rollingResistance * vehicleData.currentStats.weight * gravity;
        }
        
        private void UpdateRPM()
        {
            if (currentGear <= 0)
            {
                // На нейтрали обороты плавно падают до холостых
                currentRpm = Mathf.Lerp(currentRpm, engine.idleRpm, Time.deltaTime * 5f);
                return;
            }
            
            // Обороты от скорости и передачи
            float wheelRadius = 0.3f;
            float wheelRps = currentSpeed / (2 * Mathf.PI * wheelRadius);
            float gearRatio = transmission.gearRatios[currentGear - 1];
            float finalDrive = transmission.finalDriveRatio;
            
            currentRpm = wheelRps * gearRatio * finalDrive * 60f;
            
            // Ограничения
            currentRpm = Mathf.Clamp(currentRpm, engine.idleRpm, engine.maxRpm);
            
            // Отсечка
            if (currentRpm >= engine.redlineRpm)
            {
                // Потеря мощности на отсечке
            }
        }
        
        #endregion
        
        #region Управление
        
        public void StartRace(float distance)
        {
            isRacing = true;
            raceDistance = distance;
            currentSpeed = 0f;
            currentRpm = engine.idleRpm;
            currentGear = 0; // Нейтраль
            distanceTraveled = 0f;
            
            if (nitroSystem != null)
                nitroCharge = 1f;
        }
        
        public void StopRace()
        {
            isRacing = false;
        }
        
        public void ShiftUp()
        {
            if (currentGear < transmission.gearCount)
            {
                currentGear++;
                OnGearChanged?.Invoke(currentGear);
            }
        }
        
        public void ShiftDown()
        {
            if (currentGear > 0)
            {
                currentGear--;
                OnGearChanged?.Invoke(currentGear);
            }
        }
        
        public void ActivateNitro()
        {
            if (nitroSystem != null && nitroCharge > 0)
            {
                // Нитро активируется автоматически при нажатии газа
            }
        }
        
        public void LaunchControl()
        {
            // Система контроля старта
            if (currentGear == 0 && currentSpeed < 1f)
            {
                currentGear = 1;
                currentRpm = engine.redlineRpm * 0.8f;
                OnGearChanged?.Invoke(currentGear);
            }
        }
        
        #endregion
        
        #region Проверки
        
        private void CheckRaceFinish()
        {
            if (distanceTraveled >= raceDistance)
            {
                OnRaceFinished?.Invoke(this, distanceTraveled, currentSpeed);
                StopRace();
            }
        }
        
        #endregion
        
        #region Геттеры
        
        public float GetSpeedKmh() => currentSpeed * 3.6f;
        public float GetSpeedMph() => currentSpeed * 2.237f;
        public float GetDistanceMeters() => distanceTraveled;
        public float GetProgress() => raceDistance > 0 ? distanceTraveled / raceDistance : 0f;
        
        #endregion
    }
    
    public delegate void OnGearChanged(int newGear);
    public delegate void OnRaceFinish(VehiclePhysics vehicle, float distance, float finalSpeed);
}

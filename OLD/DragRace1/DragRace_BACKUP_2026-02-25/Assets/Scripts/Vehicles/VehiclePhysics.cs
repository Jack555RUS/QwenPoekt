using UnityEngine;
using DragRace.Data;

namespace DragRace.Vehicles
{
    /// <summary>
    /// Физика автомобиля
    /// </summary>
    public class VehiclePhysics : MonoBehaviour
    {
        [Header("Данные")]
        public VehicleData vehicleData;
        public Engine engine;
        public Transmission transmission;
        public Tires tires;
        public NitroSystem nitroSystem;
        
        [Header("Текущее состояние")]
        public float currentSpeed;
        public float currentRpm;
        public int currentGear;
        public float distanceTraveled;
        public float nitroCharge;
        
        [Header("Параметры")]
        public float airDensity = 1.225f;
        public float rollingResistance = 0.015f;
        public float gravity = 9.81f;
        
        public delegate void VehicleStateHandler(VehiclePhysics vehicle);
        public event VehicleStateHandler OnVehicleStateChanged;
        public delegate void OnGearChanged(int newGear);
        public event OnGearChanged OnGearChangedEvent;
        
        private bool isRacing;
        private float raceDistance;
        
        private void Update()
        {
            if (!isRacing) return;
            
            UpdatePhysics();
            CheckRaceFinish();
            OnVehicleStateChanged?.Invoke(this);
        }
        
        private void UpdatePhysics()
        {
            float throttle = DragRace.InputSystem.InputManager.Instance?.AccelerateInput ?? 0f;
            float tractionForce = CalculateTractionForce(throttle);
            float dragForce = CalculateDragForce();
            float rollingForce = CalculateRollingResistance();
            
            float netForce = tractionForce - dragForce - rollingForce;
            float mass = vehicleData?.currentStats.weight ?? 1000f;
            float acceleration = netForce / mass;
            
            currentSpeed += acceleration * Time.deltaTime;
            currentSpeed = Mathf.Max(currentSpeed, 0f);
            distanceTraveled += currentSpeed * Time.deltaTime;
            UpdateRPM();
        }
        
        private float CalculateTractionForce(float throttle)
        {
            if (currentGear <= 0) return 0f;
            
            float power = vehicleData?.currentStats.power ?? 100f;
            float torque = vehicleData?.currentStats.torque ?? 150f;
            float grip = vehicleData?.currentStats.grip ?? 0.7f;
            float mass = vehicleData?.currentStats.weight ?? 1000f;
            
            float wheelTorque = torque * (1f + currentGear * 0.5f);
            float tractionForce = wheelTorque / 0.3f;
            float maxTraction = grip * mass * gravity;
            
            return Mathf.Min(tractionForce * throttle, maxTraction);
        }
        
        private float CalculateDragForce()
        {
            float aero = vehicleData?.currentStats.aerodynamics ?? 0.3f;
            return 0.5f * airDensity * currentSpeed * currentSpeed * (1f - aero) * 2f;
        }
        
        private float CalculateRollingResistance()
        {
            float mass = vehicleData?.currentStats.weight ?? 1000f;
            return rollingResistance * mass * gravity;
        }
        
        private void UpdateRPM()
        {
            if (currentGear <= 0)
            {
                currentRpm = Mathf.Lerp(currentRpm, engine?.idleRpm ?? 800f, Time.deltaTime * 5f);
                return;
            }
            
            float wheelRadius = 0.3f;
            float wheelRps = currentSpeed / (2 * Mathf.PI * wheelRadius);
            float gearRatio = 1f + currentGear * 0.5f;
            float finalDrive = 4f;
            
            currentRpm = wheelRps * gearRatio * finalDrive * 60f;
            currentRpm = Mathf.Clamp(currentRpm, engine?.idleRpm ?? 800f, engine?.maxRpm ?? 8000f);
        }
        
        public void StartRace(float distance)
        {
            isRacing = true;
            raceDistance = distance;
            currentSpeed = 0f;
            currentRpm = engine?.idleRpm ?? 800f;
            currentGear = 0;
            distanceTraveled = 0f;
            nitroCharge = nitroSystem != null ? 1f : 0f;
        }
        
        public void StopRace() => isRacing = false;
        
        public void ShiftUp()
        {
            if (currentGear < 6)
            {
                currentGear++;
                OnGearChangedEvent?.Invoke(currentGear);
            }
        }
        
        public void ShiftDown()
        {
            if (currentGear > 0)
            {
                currentGear--;
                OnGearChangedEvent?.Invoke(currentGear);
            }
        }
        
        public void LaunchControl()
        {
            if (currentGear == 0 && currentSpeed < 1f)
            {
                currentGear = 1;
                currentRpm = (engine?.redlineRpm ?? 7000f) * 0.8f;
                OnGearChangedEvent?.Invoke(currentGear);
            }
        }
        
        public void ActivateNitro()
        {
            if (nitroSystem != null && nitroCharge > 0)
            {
                // Нитро активируется
            }
        }
        
        private void CheckRaceFinish()
        {
            if (distanceTraveled >= raceDistance)
            {
                StopRace();
            }
        }
        
        public float GetSpeedKmh() => currentSpeed * 3.6f;
        public float GetProgress() => raceDistance > 0 ? distanceTraveled / raceDistance : 0f;
        public float GetDistanceMeters() => distanceTraveled;
    }
}

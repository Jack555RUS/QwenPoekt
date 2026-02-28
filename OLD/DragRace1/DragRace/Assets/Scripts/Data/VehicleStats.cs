using UnityEngine;

namespace DragRace.Data
{
    /// <summary>
    /// Базовые характеристики автомобиля
    /// </summary>
    [System.Serializable]
    public class VehicleStats
    {
        [Header("Основные характеристики")]
        [Tooltip("Мощность двигателя (л.с.)")]
        public float power = 300f;
        
        [Tooltip("Крутящий момент (Нм)")]
        public float torque = 400f;
        
        [Tooltip("Вес автомобиля (кг)")]
        public float weight = 1500f;
        
        [Tooltip("Коэффициент сцепления шин")]
        public float grip = 0.85f;
        
        [Tooltip("Коэффициент лобового сопротивления")]
        public float dragCoefficient = 0.32f;
        
        [Tooltip("Площадь фронтальной проекции (м²)")]
        public float frontalArea = 2.2f;
        
        [Tooltip("Передаточное число главной пары")]
        public float finalDriveRatio = 3.5f;
        
        [Header("Производные (вычисляются автоматически)")]
        public float powerToWeight => power / (weight / 1000f); // л.с. на тонну
        public float torqueToWeight => torque / weight; // Нм на кг
    }

    /// <summary>
    /// Кривая мощности двигателя
    /// </summary>
    [System.Serializable]
    public class PowerCurve
    {
        [Tooltip("Обороты максимального крутящего момента")]
        public float maxTorqueRpm = 4000f;
        
        [Tooltip("Обороты максимальной мощности")]
        public float maxPowerRpm = 6500f;
        
        [Tooltip("Предельные обороты (отсечка)")]
        public float redlineRpm = 7500f;
        
        [Tooltip("Минимальные рабочие обороты")]
        public float idleRpm = 800f;
        
        /// <summary>
        /// Получить крутящий момент на текущих оборотах
        /// </summary>
        public float GetTorqueAtRpm(float rpm, float baseTorque)
        {
            if (rpm < idleRpm) return baseTorque * 0.5f;
            if (rpm > redlineRpm) return baseTorque * 0.3f;
            
            // Простая кривая: пик на maxTorqueRpm, спад после maxPowerRpm
            float normalizedRpm = (rpm - idleRpm) / (redlineRpm - idleRpm);
            float peakPosition = (maxTorqueRpm - idleRpm) / (redlineRpm - idleRpm);
            
            float torqueMultiplier;
            if (normalizedRpm < peakPosition)
            {
                // Рост до пика
                torqueMultiplier = 0.5f + 0.5f * (normalizedRpm / peakPosition);
            }
            else if (normalizedRpm < (maxPowerRpm - idleRpm) / (redlineRpm - idleRpm))
            {
                // Плато
                torqueMultiplier = 1.0f;
            }
            else
            {
                // Спад после пика
                float declineStart = (maxPowerRpm - idleRpm) / (redlineRpm - idleRpm);
                float decline = (normalizedRpm - declineStart) / (1f - declineStart);
                torqueMultiplier = 1.0f - 0.4f * decline;
            }
            
            return baseTorque * torqueMultiplier;
        }
        
        /// <summary>
        /// Получить мощность на текущих оборотах (л.с.)
        /// </summary>
        public float GetPowerAtRpm(float rpm, float basePower)
        {
            // Мощность = (Крутящий момент × Обороты) / 5252 (для л.с.)
            float torque = GetTorqueAtRpm(rpm, basePower * 5252f / maxPowerRpm);
            return (torque * rpm) / 5252f;
        }
    }
}

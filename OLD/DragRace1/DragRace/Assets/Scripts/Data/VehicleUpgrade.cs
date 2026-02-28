using UnityEngine;

namespace DragRace.Data
{
    /// <summary>
    /// Запчасть с конкретными улучшениями
    /// </summary>
    [CreateAssetMenu(fileName = "NewUpgrade", menuName = "DragRace/Parts/Upgrade")]
    public class VehicleUpgrade : VehiclePart
    {
        [Header("Изменения характеристик")]
        [Tooltip("Изменение мощности (л.с.)")]
        public float powerChange = 0f;
        
        [Tooltip("Изменение крутящего момента (Нм)")]
        public float torqueChange = 0f;
        
        [Tooltip("Изменение веса (кг) - отрицательное = облегчение")]
        public float weightChange = 0f;
        
        [Tooltip("Изменение сцепления")]
        public float gripChange = 0f;
        
        [Tooltip("Изменение аэродинамики")]
        public float dragChange = 0f;
        
        [Header("Специальные эффекты")]
        public bool increasesRedline = false;
        public float redlineIncrease = 500f;
        
        public override void ApplyTo(ref VehicleStats stats)
        {
            stats.power += powerChange;
            stats.torque += torqueChange;
            stats.weight += weightChange;
            stats.grip += gripChange;
            stats.dragCoefficient += dragChange;
            
            // Ограничения
            stats.power = Mathf.Max(stats.power, 50f);
            stats.torque = Mathf.Max(stats.torque, 50f);
            stats.weight = Mathf.Max(stats.weight, 500f);
            stats.grip = Mathf.Clamp(stats.grip, 0.5f, 1.5f);
            stats.dragCoefficient = Mathf.Clamp(stats.dragCoefficient, 0.2f, 0.5f);
        }
        
        /// <summary>
        /// Получить описание изменений
        /// </summary>
        public string GetChangesDescription()
        {
            string desc = "";
            
            if (powerChange != 0)
                desc += $"+{powerChange} л.с. ";
            if (torqueChange != 0)
                desc += $"+{torqueChange} Нм ";
            if (weightChange != 0)
                desc += $"{(weightChange < 0 ? "" : "+")}{weightChange} кг ";
            if (gripChange != 0)
                desc += $"+{gripChange:F2} сцепление ";
            if (dragChange != 0)
                desc += $"{(dragChange < 0 ? "↓" : "↑")} аэродинамика ";
                
            return string.IsNullOrEmpty(desc) ? "Без изменений" : desc;
        }
    }
}

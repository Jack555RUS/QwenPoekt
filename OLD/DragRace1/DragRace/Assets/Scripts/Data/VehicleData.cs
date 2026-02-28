using UnityEngine;

namespace DragRace.Data
{
    /// <summary>
    /// ScriptableObject для данных автомобиля
    /// </summary>
    [CreateAssetMenu(fileName = "NewCar", menuName = "DragRace/Vehicle")]
    public class VehicleData : ScriptableObject
    {
        [Header("Основная информация")]
        [Tooltip("Производитель")]
        public string manufacturer = "Generic Motors";
        
        [Tooltip("Название модели")]
        public string vehicleName = "Sports Car";
        
        [Tooltip("Описание")]
        [TextArea(3, 5)]
        public string description = "A balanced sports car.";
        
        [Header("Тип автомобиля")]
        public VehicleClass vehicleClass;
        
        [Header("Внешний вид")]
        public Sprite carSprite;
        public Color carColor = Color.white;
        
        [Header("Характеристики")]
        public VehicleStats baseStats = new VehicleStats();
        public PowerCurve powerCurve = new PowerCurve();
        
        [Header("Трансмиссия")]
        public TransmissionType transmissionType;
        public int gearCount = 6;
        public float[] gearRatios = new float[] { 3.5f, 2.5f, 1.9f, 1.5f, 1.2f, 1.0f };
        
        [Header("Экономика")]
        [Tooltip("Базовая цена ($)")]
        public int basePrice = 50000;
        
        [Tooltip("Стоимость улучшения (%)")]
        public float upgradeCostMultiplier = 0.1f;
        
        [Header("Уникальный ID")]
        public string vehicleId;
        
        private void OnValidate()
        {
            // Генерация уникального ID если пуст
            if (string.IsNullOrEmpty(vehicleId))
            {
                vehicleId = System.Guid.NewGuid().ToString();
            }
            
            // Проверка передаточных чисел
            if (gearRatios == null || gearRatios.Length != gearCount)
            {
                gearRatios = new float[gearCount];
                for (int i = 0; i < gearCount; i++)
                {
                    gearRatios[i] = 3.5f / (i + 1);
                }
            }
        }
        
        /// <summary>
        /// Получить текущие характеристики (с учётом улучшений)
        /// </summary>
        public VehicleStats GetCurrentStats(VehicleUpgrade[] upgrades = null)
        {
            VehicleStats current = new VehicleStats
            {
                power = baseStats.power,
                torque = baseStats.torque,
                weight = baseStats.weight,
                grip = baseStats.grip,
                dragCoefficient = baseStats.dragCoefficient,
                frontalArea = baseStats.frontalArea,
                finalDriveRatio = baseStats.finalDriveRatio
            };
            
            if (upgrades != null)
            {
                foreach (var upgrade in upgrades)
                {
                    upgrade.ApplyTo(ref current);
                }
            }
            
            return current;
        }
    }
    
    /// <summary>
    /// Класс автомобиля (влияет на характеристики)
    /// </summary>
    public enum VehicleClass
    {
        Street,      // Уличные гонки
        Sport,       // Спортивные
        Muscle,      // Маслкары
        Import,      // Импортные
        Supercar,    // Суперкары
        Dragster     // Драгстеры
    }
    
    /// <summary>
    /// Тип трансмиссии
    /// </summary>
    public enum TransmissionType
    {
        Manual,      // Механика
        Automatic,   // Автомат
        DSG,         // Робот с двойным сцеплением
        CVT          // Вариатор
    }
}

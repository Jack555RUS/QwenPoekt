using UnityEngine;

namespace DragRace.Data
{
    /// <summary>
    /// Базовый класс для запчастей
    /// </summary>
    public abstract class VehiclePart : ScriptableObject
    {
        [Header("Основное")]
        public string partName;
        public string manufacturer;
        public string description;
        
        [Header("Тип запчасти")]
        public PartType partType;
        
        [Header("Редкость")]
        public PartRarity rarity;
        
        [Header("Экономика")]
        public int price;
        public int sellPrice;
        
        [Header("Внешний вид")]
        public Sprite partSprite;
        
        [Header("Уникальный ID")]
        public string partId;
        
        private void OnValidate()
        {
            if (string.IsNullOrEmpty(partId))
            {
                partId = System.Guid.NewGuid().ToString();
            }
            
            if (sellPrice == 0)
            {
                sellPrice = Mathf.FloorToInt(price * 0.7f); // 70% от цены покупки
            }
        }
        
        /// <summary>
        /// Применить улучшения к характеристикам
        /// </summary>
        public abstract void ApplyTo(ref VehicleStats stats);
    }
    
    /// <summary>
    /// Тип запчасти
    /// </summary>
    public enum PartType
    {
        Engine,
        Transmission,
        Tires,
        Nitro,
        ECU,
        Exhaust,
        Turbo,
        Suspension,
        Brakes,
        WeightReduction
    }
    
    /// <summary>
    /// Редкость запчасти
    /// </summary>
    public enum PartRarity
    {
        Common,      // Обычная (белая)
        Uncommon,    // Необычная (зелёная)
        Rare,        // Редкая (синяя)
        Epic,        // Эпическая (фиолетовая)
        Legendary    // Легендарная (оранжевая)
    }
}

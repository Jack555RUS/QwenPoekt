using System.Collections.Generic;
using UnityEngine;

namespace DragRace.Data
{
    /// <summary>
    /// База данных автомобилей
    /// </summary>
    [CreateAssetMenu(fileName = "CarDatabase", menuName = "DragRace/Car Database")]
    public class CarDatabase : ScriptableObject
    {
        public List<CarModel> carModels;
        
        public CarModel GetCarById(string id)
        {
            return carModels.Find(c => c.id == id);
        }
        
        public List<CarModel> GetCarsByManufacturer(string manufacturer)
        {
            return carModels.FindAll(c => c.manufacturer == manufacturer);
        }
        
        public List<CarModel> GetCarsByPriceRange(float min, float max)
        {
            return carModels.FindAll(c => c.basePrice >= min && c.basePrice <= max);
        }
    }
    
    [System.Serializable]
    public class CarModel
    {
        public string id;
        public string displayName;
        public string manufacturer;
        public string modelName;
        public int year;
        public string category; // Street, Sport, Supercar, etc.
        
        // Базовые характеристики
        public VehicleStats baseStats;
        
        // Цена
        public float basePrice;
        
        // Доступные комплектации
        public List<CarTrim> availableTrims;
        
        // Визуал
        public Sprite sideView;
        public Sprite frontView;
        public Color[] availableColors;
        
        // Размеры для отображения
        public float displayLength = 4.5f;
        public float displayHeight = 1.4f;
    }
    
    [System.Serializable]
    public class CarTrim
    {
        public string trimId;
        public string trimName;
        public float priceMultiplier;
        
        // Стандартные части
        public Engine stockEngine;
        public Transmission stockTransmission;
        public Tires stockTires;
        
        public VehicleStats GetStats()
        {
            var stats = new VehicleStats();
            
            if (stockEngine != null)
            {
                var bonus = stockEngine.GetStatsBonus();
                stats.power += bonus.power;
                stats.torque += bonus.torque;
                stats.weight += bonus.weight;
            }
            
            if (stockTransmission != null)
            {
                var bonus = stockTransmission.GetStatsBonus();
                stats.weight += bonus.weight;
            }
            
            if (stockTires != null)
            {
                var bonus = stockTires.GetStatsBonus();
                stats.grip += bonus.grip;
                stats.weight += bonus.weight;
            }
            
            return stats;
        }
    }
    
    /// <summary>
    /// База данных запчастей
    /// </summary>
    [CreateAssetMenu(fileName = "PartsDatabase", menuName = "DragRace/Parts Database")]
    public class PartsDatabase : ScriptableObject
    {
        public List<Engine> engines;
        public List<Transmission> transmissions;
        public List<Tires> tires;
        public List<NitroSystem> nitroSystems;
        
        public Engine GetEngineById(string id)
        {
            return engines.Find(e => e.partId == id);
        }
        
        public Transmission GetTransmissionById(string id)
        {
            return transmissions.Find(t => t.partId == id);
        }
        
        public Tires GetTiresById(string id)
        {
            return tires.Find(t => t.partId == id);
        }
        
        public List<VehiclePart> GetAllPartsByType(PartType type)
        {
            return type switch
            {
                PartType.Engine => new List<VehiclePart>(engines),
                PartType.Transmission => new List<VehiclePart>(transmissions),
                PartType.Tires => new List<VehiclePart>(tires),
                PartType.Nitro => new List<VehiclePart>(nitroSystems),
                _ => new List<VehiclePart>()
            };
        }
    }
}

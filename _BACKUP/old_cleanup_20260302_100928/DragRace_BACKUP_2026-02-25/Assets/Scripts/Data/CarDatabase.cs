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
            if (carModels == null) return null;
            return carModels.Find(c => c.id == id);
        }
        
        public List<CarModel> GetCarsByManufacturer(string manufacturer)
        {
            if (carModels == null) return new List<CarModel>();
            return carModels.FindAll(c => c.manufacturer == manufacturer);
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
        public string category;
        public VehicleStats baseStats;
        public float basePrice;
        public List<CarTrim> availableTrims;
        public Color[] availableColors;
        public Sprite sideView;
        public float displayLength = 4.5f;
        public float displayHeight = 1.4f;
    }
    
    [System.Serializable]
    public class CarTrim
    {
        public string trimId;
        public string trimName;
        public float priceMultiplier;
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
            if (engines == null) return null;
            return engines.Find(e => e.partId == id);
        }
        
        public Transmission GetTransmissionById(string id)
        {
            if (transmissions == null) return null;
            return transmissions.Find(t => t.partId == id);
        }
        
        public Tires GetTiresById(string id)
        {
            if (tires == null) return null;
            return tires.Find(t => t.partId == id);
        }
        
        public List<VehiclePart> GetAllPartsByType(PartType type)
        {
            var result = new List<VehiclePart>();
            
            if (type == PartType.Engine && engines != null)
                result.AddRange(engines.ConvertAll(e => e as VehiclePart));
            else if (type == PartType.Transmission && transmissions != null)
                result.AddRange(transmissions.ConvertAll(t => t as VehiclePart));
            else if (type == PartType.Tires && tires != null)
                result.AddRange(tires.ConvertAll(t => t as VehiclePart));
            else if (type == PartType.Nitro && nitroSystems != null)
                result.AddRange(nitroSystems.ConvertAll(n => n as VehiclePart));
            
            return result;
        }
    }
}

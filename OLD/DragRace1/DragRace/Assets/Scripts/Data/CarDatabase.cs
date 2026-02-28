using UnityEngine;
using System.Collections.Generic;

namespace DragRace.Data
{
    /// <summary>
    /// База данных всех автомобилей в игре
    /// </summary>
    [CreateAssetMenu(fileName = "CarDatabase", menuName = "DragRace/Database/Car Database")]
    public class CarDatabase : ScriptableObject
    {
        [Header("Список автомобилей")]
        public List<VehicleData> allCars = new List<VehicleData>();
        
        /// <summary>
        /// Получить автомобиль по ID
        /// </summary>
        public VehicleData GetCarById(string id)
        {
            foreach (var car in allCars)
            {
                if (car.vehicleId == id)
                    return car;
            }
            return null;
        }
        
        /// <summary>
        /// Получить все автомобили класса
        /// </summary>
        public List<VehicleData> GetCarsByClass(VehicleClass vehicleClass)
        {
            List<VehicleData> result = new List<VehicleData>();
            foreach (var car in allCars)
            {
                if (car.vehicleClass == vehicleClass)
                    result.Add(car);
            }
            return result;
        }
        
        /// <summary>
        /// Получить доступные автомобили для уровня карьеры
        /// </summary>
        public List<VehicleData> GetCarsForTier(int tier)
        {
            List<VehicleData> result = new List<VehicleData>();
            
            foreach (var car in allCars)
            {
                int carTier = GetCarTier(car);
                if (carTier <= tier + 1) // Показываем текущий + следующий уровень
                    result.Add(car);
            }
            
            return result;
        }
        
        /// <summary>
        /// Определить уровень автомобиля по характеристикам
        /// </summary>
        public int GetCarTier(VehicleData car)
        {
            float powerToWeight = car.baseStats.powerToWeight;
            
            if (powerToWeight < 100f) return 0;      // Tier 1: < 100 л.с./т
            if (powerToWeight < 200f) return 1;      // Tier 2: 100-200
            if (powerToWeight < 350f) return 2;      // Tier 3: 200-350
            if (powerToWeight < 500f) return 3;      // Tier 4: 350-500
            return 4;                                 // Tier 5: > 500
        }
        
        /// <summary>
        /// Получить стартовый автомобиль
        /// </summary>
        public VehicleData GetStarterCar()
        {
            // Ищем самый слабый автомобиль
            VehicleData starter = null;
            float lowestPower = float.MaxValue;
            
            foreach (var car in allCars)
            {
                if (car.baseStats.power < lowestPower)
                {
                    lowestPower = car.baseStats.power;
                    starter = car;
                }
            }
            
            return starter;
        }
    }
}

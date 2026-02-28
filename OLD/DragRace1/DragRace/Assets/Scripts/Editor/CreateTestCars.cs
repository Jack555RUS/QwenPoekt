using UnityEngine;
using UnityEditor;
using DragRace.Data;

namespace DragRace.Editor
{
    /// <summary>
    /// Инструмент для создания тестовых автомобилей
    /// </summary>
    public class CreateTestCars : EditorWindow
    {
        [MenuItem("DragRace/Data/Create Test Cars")]
        public static void CreateTestCarsData()
        {
            string folder = "Assets/Resources/Vehicles";
            
            if (!AssetDatabase.IsValidFolder(folder))
            {
                AssetDatabase.CreateFolder("Assets/Resources", "Vehicles");
            }
            
            // Стартовый автомобиль
            CreateStarterCar(folder);
            
            // Tier 1
            CreateTier1Car(folder);
            
            // Tier 2
            CreateTier2Car(folder);
            
            // Tier 3
            CreateTier3Car(folder);
            
            // Tier 4
            CreateTier4Car(folder);
            
            // Tier 5 (Boss)
            CreateTier5Car(folder);
            
            AssetDatabase.SaveAssets();
            AssetDatabase.Refresh();
            
            Debug.Log("✅ Создано 6 тестовых автомобилей в Assets/Resources/Vehicles/");
        }
        
        private static VehicleData CreateCar(string folder, string name, string manufacturer, 
            VehicleClass vehicleClass, float power, float torque, int price)
        {
            VehicleData car = ScriptableObject.CreateInstance<VehicleData>();
            car.manufacturer = manufacturer;
            car.vehicleName = name;
            car.vehicleClass = vehicleClass;
            car.baseStats.power = power;
            car.baseStats.torque = torque;
            car.baseStats.weight = 1000f + (power / 2f); // Простая формула
            car.baseStats.grip = 0.7f + (vehicleClass == VehicleClass.Supercar ? 0.2f : 0f);
            car.basePrice = price;
            car.description = $"{manufacturer} {name} - {power} л.с.";
            
            AssetDatabase.CreateAsset(car, $"Assets/Resources/Vehicles/{manufacturer}_{name}.asset");
            return car;
        }
        
        private static void CreateStarterCar(string folder)
        {
            var car = CreateCar(folder, "Civic", "Honda", VehicleClass.Import, 150f, 180f, 20000);
            car.gearCount = 5;
            Debug.Log($"✅ Создан стартовый автомобиль: {car.manufacturer} {car.vehicleName}");
        }
        
        private static void CreateTier1Car(string folder)
        {
            var car = CreateCar(folder, "Mustang GT", "Ford", VehicleClass.Muscle, 300f, 420f, 45000);
            Debug.Log($"✅ Создан Tier 1: {car.manufacturer} {car.vehicleName}");
        }
        
        private static void CreateTier2Car(string folder)
        {
            var car = CreateCar(folder, "Supra", "Toyota", VehicleClass.Import, 400f, 500f, 65000);
            Debug.Log($"✅ Создан Tier 2: {car.manufacturer} {car.vehicleName}");
        }
        
        private static void CreateTier3Car(string folder)
        {
            var car = CreateCar(folder, "Corvette Z06", "Chevrolet", VehicleClass.Sport, 550f, 650f, 95000);
            Debug.Log($"✅ Создан Tier 3: {car.manufacturer} {car.vehicleName}");
        }
        
        private static void CreateTier4Car(string folder)
        {
            var car = CreateCar(folder, "911 Turbo S", "Porsche", VehicleClass.Supercar, 650f, 750f, 140000);
            Debug.Log($"✅ Создан Tier 4: {car.manufacturer} {car.vehicleName}");
        }
        
        private static void CreateTier5Car(string folder)
        {
            var car = CreateCar(folder, "Bugatti Veyron", "Bugatti", VehicleClass.Supercar, 1000f, 1200f, 200000);
            Debug.Log($"✅ Создан Tier 5 (Boss): {car.manufacturer} {car.vehicleName}");
        }
    }
}

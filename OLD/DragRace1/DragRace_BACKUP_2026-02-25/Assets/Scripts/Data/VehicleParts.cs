using System;
using System.Collections.Generic;
using UnityEngine;

namespace DragRace.Data
{
    /// <summary>
    /// Типы запчастей
    /// </summary>
    [Serializable]
    public enum PartType
    {
        Engine,
        Transmission,
        Tires,
        Exhaust,
        Turbo,
        Suspension,
        Brakes,
        Nitro
    }
    
    /// <summary>
    /// Редкость запчастей
    /// </summary>
    [Serializable]
    public enum PartRarity
    {
        Common,
        Uncommon,
        Rare,
        Epic,
        Legendary
    }
    
    /// <summary>
    /// Базовый класс для всех частей автомобиля
    /// </summary>
    [Serializable]
    public abstract class VehiclePart
    {
        public string partId;
        public string partName;
        public string description;
        public PartType partType;
        public PartRarity rarity;
        public float powerBonus;
        public float torqueBonus;
        public float weightChange;
        public float gripBonus;
        public float buyPrice;
        public float sellPrice;
        public Sprite icon;
        
        public abstract VehicleStats GetStatsBonus();
        public abstract string GetDescription();
    }
    
    /// <summary>
    /// Двигатель
    /// </summary>
    [Serializable]
    public class Engine : VehiclePart
    {
        public float displacement;
        public int cylinders;
        public string configuration;
        public AnimationCurve powerCurve;
        public AnimationCurve torqueCurve;
        public float maxRpm;
        public float idleRpm;
        public float redlineRpm;
        
        public Engine()
        {
            partType = PartType.Engine;
            powerCurve = new AnimationCurve();
            torqueCurve = new AnimationCurve();
        }
        
        public override VehicleStats GetStatsBonus()
        {
            return new VehicleStats
            {
                power = powerBonus,
                torque = torqueBonus,
                weight = weightChange
            };
        }
        
        public override string GetDescription()
        {
            return $"{partName} - {displacement}L {configuration}, {powerBonus} л.с.";
        }
        
        public float GetPowerAtRpm(float rpm)
        {
            return powerCurve != null ? powerCurve.Evaluate(rpm / maxRpm) * powerBonus : powerBonus;
        }
    }
    
    /// <summary>
    /// Коробка передач
    /// </summary>
    [Serializable]
    public class Transmission : VehiclePart
    {
        public TransmissionType transmissionType;
        public int gearCount;
        public float[] gearRatios;
        public float finalDriveRatio;
        public float shiftTime;
        
        public Transmission()
        {
            partType = PartType.Transmission;
            gearRatios = new float[6];
        }
        
        public override VehicleStats GetStatsBonus()
        {
            return new VehicleStats
            {
                weight = weightChange,
                grip = gripBonus
            };
        }
        
        public override string GetDescription()
        {
            return $"{partName} - {transmissionType}, {gearCount} передач";
        }
        
        public float GetWheelTorque(float engineTorque, int gear)
        {
            if (gear < 1 || gear > gearCount || gearRatios == null) return 0f;
            return engineTorque * gearRatios[Mathf.Min(gear - 1, gearRatios.Length - 1)] * finalDriveRatio;
        }
    }
    
    [Serializable]
    public enum TransmissionType
    {
        Manual,
        Automatic,
        DSG,
        PDK,
        CVT
    }
    
    /// <summary>
    /// Шины
    /// </summary>
    [Serializable]
    public class Tires : VehiclePart
    {
        public int width;
        public int aspectRatio;
        public int rimDiameter;
        public TireCompound compound;
        public float wearLevel;
        
        public Tires()
        {
            partType = PartType.Tires;
            wearLevel = 100f;
        }
        
        public override VehicleStats GetStatsBonus()
        {
            return new VehicleStats
            {
                grip = gripBonus,
                weight = weightChange
            };
        }
        
        public override string GetDescription()
        {
            return $"{partName} - {width}/{aspectRatio}R{rimDiameter}";
        }
    }
    
    [Serializable]
    public enum TireCompound
    {
        Street,
        Sport,
        SemiSlick,
        Slick,
        Drag,
        Wet
    }
    
    /// <summary>
    /// Нитро система
    /// </summary>
    [Serializable]
    public class NitroSystem : VehiclePart
    {
        public float capacity;
        public float currentCharge;
        public float powerBoost;
        public float duration;
        
        public NitroSystem()
        {
            partType = PartType.Nitro;
        }
        
        public override VehicleStats GetStatsBonus()
        {
            return new VehicleStats { power = powerBoost };
        }
        
        public override string GetDescription()
        {
            return $"{partName} - {capacity}L, +{powerBoost} л.с.";
        }
    }
}

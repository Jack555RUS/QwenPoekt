using System;
using System.Collections.Generic;
using UnityEngine;

namespace DragRace.Data
{
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
        
        // Характеристики
        public float powerBonus;
        public float torqueBonus;
        public float weightChange;
        public float gripBonus;
        
        // Экономика
        public float buyPrice;
        public float sellPrice;
        
        // Визуальное представление
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
        public float displacement; // объём в литрах
        public int cylinders;
        public string configuration; // V8, I4, etc.
        
        // Кривая мощности (обороты -> мощность)
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
            return $"{partName} - {displacement}L {configuration}, {powerBonus} л.с., {torqueBonus} Нм";
        }
        
        public float GetPowerAtRpm(float rpm)
        {
            return powerCurve.Evaluate(rpm / maxRpm) * powerBonus;
        }
        
        public float GetTorqueAtRpm(float rpm)
        {
            return torqueCurve.Evaluate(rpm / maxRpm) * torqueBonus;
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
        
        // Для автоматов
        public float shiftTime; // время переключения
        public float launchControlThreshold;
        
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
            string typeStr = transmissionType switch
            {
                TransmissionType.Manual => "Механика",
                TransmissionType.Automatic => "Автомат",
                TransmissionType.DSG => "DSG",
                TransmissionType.PDK => "PDK",
                TransmissionType.CVT => "CVT",
                _ => transmissionType.ToString()
            };
            return $"{partName} - {typeStr}, {gearCount} передач";
        }
        
        public float GetWheelTorque(float engineTorque, int gear)
        {
            if (gear < 1 || gear > gearCount) return 0f;
            return engineTorque * gearRatios[gear - 1] * finalDriveRatio;
        }
    }
    
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
        public int width; // мм
        public int aspectRatio; // профиль
        public int rimDiameter; // дюймы
        
        public TireCompound compound;
        public float wearLevel; // 0-100%
        
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
            return $"{partName} - {width}/{aspectRatio}R{rimDiameter}, {compound}";
        }
        
        public float GetEffectiveGrip()
        {
            return gripBonus * (wearLevel / 100f);
        }
    }
    
    public enum TireCompound
    {
        Street,         // Уличные
        Sport,          // Спортивные
        SemiSlick,      // Полуслики
        Slick,          // Слики
        Drag,           // Драг-слики
        Wet             // Дождевые
    }
    
    /// <summary>
    /// Система нитро
    /// </summary>
    [Serializable]
    public class NitroSystem : VehiclePart
    {
        public float capacity; // объём баллона
        public float currentCharge;
        public float powerBoost;
        public float duration; // длительность в секундах
        
        public NitroSystem()
        {
            partType = PartType.Nitro;
        }
        
        public override VehicleStats GetStatsBonus()
        {
            return new VehicleStats
            {
                power = powerBoost
            };
        }
        
        public override string GetDescription()
        {
            return $"{partName} - {capacity}L, +{powerBoost} л.с.";
        }
    }
}

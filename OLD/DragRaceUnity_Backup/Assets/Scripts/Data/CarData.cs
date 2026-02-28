using UnityEngine;
using System;

namespace ProbMenu.Data
{
    /// <summary>
    /// Данные автомобиля (ScriptableObject)
    /// </summary>
    [CreateAssetMenu(fileName = "NewCar", menuName = "DragRace/Car Data")]
    public class CarData : ScriptableObject
    {
        [Header("Основная информация")]
        public string carName;
        public string manufacturer;
        public CarClass carClass;
        public int price;
        public Sprite carSprite;

        [Header("Двигатель")]
        public EngineData engineData;

        [Header("Трансмиссия")]
        public TransmissionData transmissionData;

        [Header("Шины")]
        public TireData tireData;

        [Header("Аэродинамика")]
        public float dragCoefficient; // Коэффициент сопротивления
        public float frontalArea;     // Площадь лобового стекла (м²)

        [Header("Характеристики")]
        public float weight;          // Вес (кг)
        public float length;          // Длина (м)
        
        [Header("Прогрессия")]
        public int unlockLevel;       // Уровень открытия
    }

    /// <summary>
    /// Класс автомобиля
    /// </summary>
    public enum CarClass
    {
        D,      // Бюджетные
        C,      // Средние
        B,      // Спортивные
        A,      // Премиум
        S       // Экзотические
    }

    /// <summary>
    /// Данные двигателя
    /// </summary>
    [Serializable]
    public class EngineData
    {
        [Header("Основные параметры")]
        public string engineName;
        public float displacement;    // Объём (л)
        public int cylinders;         // Количество цилиндров
        public EngineType type;       // Тип двигателя

        [Header("Мощность")]
        public float maxPower;        // Максимальная мощность (л.с.)
        public int maxPowerRpm;       // Обороты макс. мощности
        public float maxTorque;       // Макс. крутящий момент (Нм)
        public int maxTorqueRpm;      // Обороты макс. момента

        [Header("График мощности")]
        public AnimationCurve powerCurve;  // Кривая мощности от RPM
        public AnimationCurve torqueCurve; // Кривая момента от RPM

        [Header("Ограничения")]
        public int maxRpm;            // Предельные обороты
        public int idleRpm;           // Обороты холостого хода
    }

    /// <summary>
    /// Тип двигателя
    /// </summary>
    public enum EngineType
    {
        Inline4,      // Рядный 4-цилиндровый
        Inline6,      // Рядный 6-цилиндровый
        V6,           // V-образный 6
        V8,           // V-образный 8
        V10,          // V-образный 10
        V12,          // V-образный 12
        Rotary,       // Роторный
        Electric      // Электрический
    }

    /// <summary>
    /// Данные трансмиссии
    /// </summary>
    [Serializable]
    public class TransmissionData
    {
        [Header("Основные параметры")]
        public string transmissionName;
        public TransmissionType type;
        public int gearsCount;

        [Header("Передаточные числа")]
        public float[] gearRatios;
        public float finalDrive;      // Главная передача

        [Header("Режимы (для автомата)")]
        public bool hasDriveMode;
        public bool hasSportMode;
        public bool hasManualMode;

        [Header("Переключения")]
        public float shiftTime;       // Время переключения (с)
        public int shiftPointRpm;     // Обороты переключения
    }

    /// <summary>
    /// Тип трансмиссии
    /// </summary>
    public enum TransmissionType
    {
        Manual,     // Механика
        Automatic,  // Автомат
        DSG,        // Робот с двумя сцеплениями
        PDK,        // Porsche Doppelkupplung
        CVT         // Вариатор
    }

    /// <summary>
    /// Данные шин
    /// </summary>
    [Serializable]
    public class TireData
    {
        [Header("Размерность")]
        public int width;           // Ширина (мм)
        public int aspectRatio;     // Профиль (%)
        public int rimDiameter;     // Диаметр диска (дюймы)

        [Header("Характеристики")]
        public TireCompound compound;
        public float gripLevel;     // Уровень сцепления (0-1)
        public float wearRate;      // Скорость износа

        [Header("Контакт")]
        public float contactArea;   // Площадь контакта (см²)
    }

    /// <summary>
    /// Состав шин
    /// </summary>
    public enum TireCompound
    {
        Hard,       // Жёсткие (долговечные)
        Medium,     // Средние
        Soft,       // Мягкие (цепкие)
        Racing,     // Гоночные
        Drag        // Драг-слики
    }

    /// <summary>
    /// Апгрейд для автомобиля
    /// </summary>
    [CreateAssetMenu(fileName = "NewUpgrade", menuName = "DragRace/Upgrade")]
    public class VehicleUpgrade : ScriptableObject
    {
        public string upgradeName;
        public string description;
        public UpgradeType type;
        public int price;
        public int rarity; // 1-5

        [Header("Улучшения")]
        public float powerBonus;      // Бонус к мощности (%)
        public float torqueBonus;     // Бонус к моменту (%)
        public float weightReduction; // Снижение веса (кг)
        public float gripBonus;       // Бонус к сцеплению (%)
    }

    /// <summary>
    /// Тип апгрейда
    /// </summary>
    public enum UpgradeType
    {
        Engine,
        Transmission,
        Tires,
        Exhaust,
        Turbo,
        Nitro,
        Weight,
        Aerodynamics
    }
}

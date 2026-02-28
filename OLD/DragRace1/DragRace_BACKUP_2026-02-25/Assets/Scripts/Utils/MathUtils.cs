using UnityEngine;
using System;

namespace DragRace.Utils
{
    /// <summary>
    /// Вспомогательные математические функции
    /// </summary>
    public static class MathUtils
    {
        /// <summary>
        /// Линейная интерполяция с easing
        /// </summary>
        public static float EaseInOut(float from, float to, float t)
        {
            t = Mathf.Clamp01(t);
            return from + (to - from) * (t * t * (3 - 2 * t));
        }
        
        /// <summary>
        /// Преобразование м/с в км/ч
        /// </summary>
        public static float MpsToKmh(float mps) => mps * 3.6f;
        
        /// <summary>
        /// Преобразование км/ч в м/с
        /// </summary>
        public static float KmhToMps(float kmh) => kmh / 3.6f;
        
        /// <summary>
        /// Преобразование м/с в mph
        /// </summary>
        public static float MpsToMph(float mps) => mps * 2.237f;
        
        /// <summary>
        /// Форматирование времени в MM:SS.ms
        /// </summary>
        public static string FormatTime(float seconds)
        {
            int minutes = (int)(seconds / 60);
            int secs = (int)(seconds % 60);
            int ms = (int)((seconds % 1) * 100);
            
            return $"{minutes:D2}:{secs:D2}:{ms:D2}";
        }
        
        /// <summary>
        /// Форматирование расстояния
        /// </summary>
        public static string FormatDistance(float meters)
        {
            if (meters >= 1000)
                return $"{meters / 1000:F2} км";
            return $"{meters:F1} м";
        }
        
        /// <summary>
        /// Ограничение значения в диапазоне
        /// </summary>
        public static float Clamp(float value, float min, float max)
        {
            return Mathf.Max(min, Mathf.Min(max, value));
        }
        
        /// <summary>
        /// Маппинг значения из одного диапазона в другой
        /// </summary>
        public static float Map(float value, float fromMin, float fromMax, float toMin, float toMax)
        {
            return toMin + (value - fromMin) * (toMax - toMin) / (fromMax - fromMin);
        }
        
        /// <summary>
        /// Вычисление передаточного отношения
        /// </summary>
        public static float CalculateGearRatio(float engineRpm, float wheelRadius, float speed, float finalDrive)
        {
            if (speed <= 0) return 0;
            
            float wheelRps = speed / (2 * Mathf.PI * wheelRadius);
            return (engineRpm / 60f) / wheelRps / finalDrive;
        }
        
        /// <summary>
        /// Расчёт мощности от крутящего момента и оборотов
        /// </summary>
        public static float CalculatePowerFromTorque(float torque, float rpm)
        {
            // P = T × ω, где ω = 2π × RPM / 60
            return torque * (2 * Mathf.PI * rpm / 60f) / 745.7f; // в л.с.
        }
        
        /// <summary>
        /// Расчёт крутящего момента от мощности и оборотов
        /// </summary>
        public static float CalculateTorqueFromPower(float power, float rpm)
        {
            // T = P / ω
            return (power * 745.7f) / (2 * Mathf.PI * rpm / 60f); // в Нм
        }
    }
    
    /// <summary>
    /// Вспомогательные функции для работы с цветом
    /// </summary>
    public static class ColorUtils
    {
        /// <summary>
        /// Интерполяция цвета по значению (красный -> жёлтый -> зелёный)
        /// </summary>
        public static Color ValueToColor(float value, float min, float max)
        {
            float normalized = Mathf.InverseLerp(min, max, value);
            
            if (normalized < 0.5f)
            {
                return Color.Lerp(Color.red, Color.yellow, normalized * 2);
            }
            else
            {
                return Color.Lerp(Color.yellow, Color.green, (normalized - 0.5f) * 2);
            }
        }
        
        /// <summary>
        /// Цвет по редкости
        /// </summary>
        public static Color RarityColor(DragRace.Data.PartRarity rarity)
        {
            return rarity switch
            {
                DragRace.Data.PartRarity.Common => Color.white,
                DragRace.Data.PartRarity.Uncommon => new Color(0.2f, 0.8f, 0.2f),
                DragRace.Data.PartRarity.Rare => new Color(0.2f, 0.6f, 1f),
                DragRace.Data.PartRarity.Epic => new Color(0.8f, 0.2f, 1f),
                DragRace.Data.PartRarity.Legendary => new Color(1f, 0.8f, 0.2f),
                _ => Color.white
            };
        }
    }
    
    /// <summary>
    /// Вспомогательные функции для строки
    /// </summary>
    public static class StringUtils
    {
        /// <summary>
        /// Форматирование числа с разделителями
        /// </summary>
        public static string FormatNumber(float number)
        {
            if (number >= 1000000)
                return $"{number / 1000000:F1}M";
            if (number >= 1000)
                return $"{number / 1000:F1}K";
            return $"{number:F0}";
        }
        
        /// <summary>
        /// Сокращение имени с инициалами
        /// </summary>
        public static string Abbreviate(string name, int maxLength)
        {
            if (string.IsNullOrEmpty(name) || name.Length <= maxLength)
                return name;
            
            return name.Substring(0, maxLength - 2) + "..";
        }
    }
}

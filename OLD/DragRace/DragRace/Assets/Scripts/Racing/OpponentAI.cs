using UnityEngine;
using DragRace.Data;
using DragRace.Core;

namespace DragRace.Racing
{
    /// <summary>
    /// ИИ соперника с rubber-banding
    /// </summary>
    public class OpponentAI : MonoBehaviour
    {
        [Header("Ссылки")]
        public VehiclePhysics opponentVehicle;
        
        [Header("Настройки ИИ")]
        [Range(0.1f, 0.5f)]
        public float baseReactionTime = 0.3f;
        [Range(0.1f, 0.5f)]
        public float baseShiftSpeed = 0.2f;
        [Range(6000f, 8000f)]
        public float shiftRpmThreshold = 7000f;
        
        [Header("Rubber-banding")]
        [Tooltip("Насколько ИИ становится быстрее когда отстаёт")]
        [Range(0f, 0.5f)]
        public float rubberBandStrength = 0.2f;
        [Tooltip("Максимальный бонус от rubber-banding")]
        [Range(0f, 1f)]
        public float maxRubberBandBonus = 0.3f;
        [Tooltip("Минимальная дистанция для активации rubber-banding")]
        [Range(0f, 50f)]
        public float rubberBandActivationDistance = 10f;
        
        [Header("Сложность")]
        public DifficultyLevel difficulty = DifficultyLevel.Medium;
        
        // Модификаторы сложности
        private float difficultyReactionMod;
        private float difficultyPowerMod;
        private float difficultyShiftMod;
        
        // Состояние
        private bool isRacing;
        private float raceStartTime;
        private bool hasLaunched;
        
        private void Start()
        {
            InitializeDifficultyModifiers();
            
            if (opponentVehicle == null)
                opponentVehicle = GetComponent<VehiclePhysics>();
        }
        
        private void Update()
        {
            if (!isRacing || opponentVehicle == null || !opponentVehicle.enabled)
                return;
            
            UpdateAI();
        }
        
        private void InitializeDifficultyModifiers()
        {
            switch (difficulty)
            {
                case DifficultyLevel.Easy:
                    difficultyReactionMod = 1.5f; // Медленнее реакция
                    difficultyPowerMod = 0.8f; // Меньше мощности
                    difficultyShiftMod = 1.3f; // Медленнее переключение
                    break;
                    
                case DifficultyLevel.Medium:
                    difficultyReactionMod = 1.0f;
                    difficultyPowerMod = 1.0f;
                    difficultyShiftMod = 1.0f;
                    break;
                    
                case DifficultyLevel.Hard:
                    difficultyReactionMod = 0.7f; // Быстрее реакция
                    difficultyPowerMod = 1.15f; // Больше мощности
                    difficultyShiftMod = 0.8f; // Быстрее переключение
                    break;
                    
                case DifficultyLevel.Expert:
                    difficultyReactionMod = 0.5f;
                    difficultyPowerMod = 1.25f;
                    difficultyShiftMod = 0.6f;
                    break;
            }
        }
        
        private void UpdateAI()
        {
            // Старт
            if (!hasLaunched)
            {
                HandleStart();
            }
            else
            {
                HandleRacing();
            }
        }
        
        private void HandleStart()
        {
            float timeSinceStart = Time.time - raceStartTime;
            float effectiveReactionTime = baseReactionTime * difficultyReactionMod;
            
            // Проверка на фальстарт (иногда ИИ может фальстартить)
            if (timeSinceStart >= effectiveReactionTime)
            {
                opponentVehicle.LaunchControl();
                hasLaunched = true;
            }
        }
        
        private void HandleRacing()
        {
            // Переключение передач
            if (opponentVehicle.currentRpm >= shiftRpmThreshold)
            {
                float effectiveShiftSpeed = baseShiftSpeed * difficultyShiftMod;
                
                // ИИ переключается быстрее когда отстаёт (rubber-banding)
                float rubberBandBonus = CalculateRubberBandBonus();
                float actualShiftSpeed = effectiveShiftSpeed * (1f - rubberBandBonus);
                
                // Небольшая рандомизация времени переключения
                if (Random.value < Time.deltaTime / Mathf.Max(actualShiftSpeed, 0.01f))
                {
                    opponentVehicle.ShiftUp();
                }
            }
            
            // Использование нитро (когда отстаёт)
            if (ShouldUseNitro())
            {
                opponentVehicle.ActivateNitro();
            }
        }
        
        /// <summary>
        /// Расчёт rubber-banding бонуса
        /// </summary>
        private float CalculateRubberBandBonus()
        {
            if (GameManager.Instance == null || GameManager.Instance.GameData == null)
                return 0f;
            
            var playerVehicle = GameManager.Instance.GetCurrentVehicle();
            if (playerVehicle == null) return 0f;
            
            // Расчёт отставания
            float playerDistance = 0f; // TODO: Получить дистанцию игрока
            float opponentDistance = opponentVehicle.GetDistanceMeters();
            float distanceDiff = playerDistance - opponentDistance;
            
            // Если ИИ отстаёт, активируем rubber-banding
            if (distanceDiff > rubberBandActivationDistance)
            {
                float normalizedGap = Mathf.Clamp01(distanceDiff / 50f); // 50м = полный бонус
                float bonus = normalizedGap * rubberBandStrength * maxRubberBandBonus;
                
                return Mathf.Clamp(bonus, 0f, maxRubberBandBonus);
            }
            
            return 0f;
        }
        
        /// <summary>
        /// Проверка использования нитро
        /// </summary>
        private bool ShouldUseNitro()
        {
            // ИИ использует нитро когда:
            // 1. Отстаёт больше чем на X метров
            // 2. Скорость выше определённой
            // 3. Есть заряд нитро
            
            float rubberBandBonus = CalculateRubberBandBonus();
            
            // Чем больше отстаёт, тем выше шанс использования нитро
            float useChance = rubberBandBonus * 2f; // до 60% шанса
            
            return Random.value < useChance && opponentVehicle.currentSpeed > 50f;
        }
        
        /// <summary>
        /// Применение rubber-banding к характеристикам
        /// </summary>
        public void ApplyRubberBandToStats(VehicleStats stats)
        {
            float bonus = CalculateRubberBandBonus();
            
            // Увеличиваем мощность и сцепление когда ИИ отстаёт
            stats.power *= (1f + bonus * 0.5f);
            stats.grip *= (1f + bonus * 0.3f);
            stats.torque *= (1f + bonus * 0.4f);
        }
        
        public void StartRace()
        {
            isRacing = true;
            raceStartTime = Time.time;
            hasLaunched = false;
        }
        
        public void StopRace()
        {
            isRacing = false;
            hasLaunched = false;
        }
        
        public void SetDifficulty(DifficultyLevel level)
        {
            difficulty = level;
            InitializeDifficultyModifiers();
        }
    }
    
    public enum DifficultyLevel
    {
        Easy,
        Medium,
        Hard,
        Expert
    }
}

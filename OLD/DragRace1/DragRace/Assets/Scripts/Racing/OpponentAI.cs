using UnityEngine;

namespace DragRace.Racing
{
    /// <summary>
    /// ИИ соперника с системой rubber-banding
    /// Rubber-banding динамически подстраивает сложность под игрока:
    /// - Если игрок отстаёт - ИИ замедляется
    /// - Если игрок лидирует - ИИ ускоряется
    /// </summary>
    public class OpponentAI : MonoBehaviour
    {
        #region Parameters
        
        [Header("Данные автомобиля")]
        [Tooltip("Данные автомобиля соперника")]
        public Data.VehicleData vehicleData;
        
        [Header("Базовые характеристики ИИ")]
        [Tooltip("Время реакции на старт (секунды)")]
        [Range(0.1f, 1.0f)]
        public float reactionTime = 0.5f;
        
        [Tooltip("Скорость переключения передач (0-1)")]
        [Range(0.5f, 1.0f)]
        public float shiftSpeed = 0.8f;
        
        [Tooltip("Агрессивность (влияет на rubber-banding)")]
        [Range(0.1f, 1.0f)]
        public float aggressiveness = 0.7f;
        
        [Header("Rubber-banding")]
        [Tooltip("Включить rubber-banding")]
        public bool enableRubberBanding = true;
        
        [Tooltip("Максимальная коррекция скорости (%)")]
        [Range(0.1f, 0.5f)]
        public float maxRubberBandCorrection = 0.3f;
        
        [Tooltip("Дистанция для активации rubber-banding (м)")]
        public float rubberBandDistance = 10f;
        
        [Tooltip("Задержка перед активацией rubber-banding (сек)")]
        public float rubberBandDelay = 2f;
        
        [Header("Сложность")]
        [Tooltip("Уровень сложности (1-5)")]
        [Range(1, 5)]
        public int difficultyLevel = 3;
        
        #endregion
        
        #region Events
        
        public delegate void AIStateHandler(OpponentAI ai);
        public event AIStateHandler OnAIUpdated;
        public event AIStateHandler OnAIFinished;
        
        #endregion
        
        #region State
        
        private Vehicles.CarPhysics carPhysics;
        private bool hasStarted = false;
        private bool hasFinished = false;
        private float startDelayTimer = 0f;
        private float rubberBandTimer = 0f;
        private float currentRubberBandFactor = 0f;
        
        // Для расчёта отставания
        private float playerDistance = 0f;
        private float aiDistance = 0f;
        private float distanceDifference = 0f;
        
        #endregion
        
        #region Properties
        
        public bool HasStarted => hasStarted;
        public bool HasFinished => hasFinished;
        public float ReactionTime => reactionTime;
        public float CurrentRubberBandFactor => currentRubberBandFactor;
        public float DistanceDifference => distanceDifference;
        
        #endregion
        
        #region Unity Methods
        
        private void Awake()
        {
            InitializeAI();
        }
        
        private void Update()
        {
            if (!hasStarted || hasFinished) return;
            
            UpdateRubberBanding();
            ApplyAIControl();
            
            OnAIUpdated?.Invoke(this);
        }
        
        #endregion
        
        #region Initialization
        
        /// <summary>
        /// Инициализация ИИ
        /// </summary>
        public void InitializeAI()
        {
            carPhysics = GetComponent<Vehicles.CarPhysics>();
            
            if (carPhysics == null)
            {
                carPhysics = gameObject.AddComponent<Vehicles.CarPhysics>();
            }
            
            if (vehicleData != null)
            {
                carPhysics.vehicleData = vehicleData;
                carPhysics.InitializeVehicle();
            }
            
            // Настройка сложности
            ApplyDifficultySettings();
            
            ResetState();
            
            Debug.Log($"🤖 ИИ инициализирован: {vehicleData?.vehicleName ?? "Unknown"}");
            Debug.Log($"   Сложность: {difficultyLevel}/5");
            Debug.Log($"   Реакция: {reactionTime:F2}с");
        }
        
        /// <summary>
        /// Применение настроек сложности
        /// </summary>
        private void ApplyDifficultySettings()
        {
            switch (difficultyLevel)
            {
                case 1: // Easy
                    reactionTime = 0.7f;
                    shiftSpeed = 0.6f;
                    aggressiveness = 0.4f;
                    break;
                    
                case 2: // Medium-Easy
                    reactionTime = 0.6f;
                    shiftSpeed = 0.7f;
                    aggressiveness = 0.5f;
                    break;
                    
                case 3: // Medium
                    reactionTime = 0.5f;
                    shiftSpeed = 0.8f;
                    aggressiveness = 0.6f;
                    break;
                    
                case 4: // Medium-Hard
                    reactionTime = 0.4f;
                    shiftSpeed = 0.85f;
                    aggressiveness = 0.75f;
                    break;
                    
                case 5: // Hard
                    reactionTime = 0.3f;
                    shiftSpeed = 0.9f;
                    aggressiveness = 0.85f;
                    break;
            }
        }
        
        /// <summary>
        /// Сброс состояния
        /// </summary>
        public void ResetState()
        {
            hasStarted = false;
            hasFinished = false;
            startDelayTimer = 0f;
            rubberBandTimer = 0f;
            currentRubberBandFactor = 0f;
            playerDistance = 0f;
            aiDistance = 0f;
            distanceDifference = 0f;
            
            if (carPhysics != null)
            {
                carPhysics.ResetState();
            }
        }
        
        #endregion
        
        #region Race Control
        
        /// <summary>
        /// Начать заезд
        /// </summary>
        public void StartRace(float distance)
        {
            ResetState();
            
            if (carPhysics != null)
            {
                carPhysics.StartRace(distance);
            }
            
            // Задержка перед стартом (реакция ИИ)
            startDelayTimer = reactionTime;
            
            Debug.Log($"🤖 ИИ готовится к старту (реакция: {reactionTime:F2}с)");
        }
        
        /// <summary>
        /// Обновление позиции игрока (для rubber-banding)
        /// </summary>
        public void UpdatePlayerPosition(float playerDist)
        {
            playerDistance = playerDist;
        }
        
        /// <summary>
        /// Обновление rubber-banding
        /// </summary>
        private void UpdateRubberBanding()
        {
            if (!enableRubberBanding)
            {
                currentRubberBandFactor = 0f;
                return;
            }
            
            // Обновляем дистанцию ИИ
            if (carPhysics != null)
            {
                aiDistance = carPhysics.distanceTraveled;
            }
            
            // Расчёт разницы
            distanceDifference = playerDistance - aiDistance;
            
            // Таймер задержки
            if (Mathf.Abs(distanceDifference) > rubberBandDistance)
            {
                rubberBandTimer += Time.deltaTime;
                
                if (rubberBandTimer >= rubberBandDelay)
                {
                    CalculateRubberBandFactor();
                }
            }
            else
            {
                rubberBandTimer = 0f;
                currentRubberBandFactor = Mathf.Lerp(currentRubberBandFactor, 0f, Time.deltaTime * 2f);
            }
        }
        
        /// <summary>
        /// Расчёт коэффициента rubber-banding
        /// </summary>
        private void CalculateRubberBandFactor()
        {
            // Если ИИ отстаёт - ускоряем его
            if (distanceDifference > 0)
            {
                // ИИ отстаёт от игрока
                float deficitRatio = Mathf.Min(distanceDifference / 100f, 1f);
                currentRubberBandFactor = deficitRatio * maxRubberBandCorrection * aggressiveness;
                currentRubberBandFactor = Mathf.Clamp(currentRubberBandFactor, 0f, maxRubberBandCorrection);
            }
            // Если ИИ лидирует - замедляем его
            else if (distanceDifference < 0)
            {
                // ИИ опережает игрока
                float leadRatio = Mathf.Min(Mathf.Abs(distanceDifference) / 100f, 1f);
                currentRubberBandFactor = -leadRatio * maxRubberBandCorrection * aggressiveness;
                currentRubberBandFactor = Mathf.Clamp(currentRubberBandFactor, -maxRubberBandCorrection, 0f);
            }
            
            if (Mathf.Abs(currentRubberBandFactor) > 0.01f)
            {
                Debug.Log($"🔧 Rubber-banding: {currentRubberBandFactor:F2} (diff: {distanceDifference:F1}м)");
            }
        }
        
        /// <summary>
        /// Применение управления ИИ
        /// </summary>
        private void ApplyAIControl()
        {
            // Проверка задержки старта
            if (!hasStarted)
            {
                startDelayTimer -= Time.deltaTime;
                
                if (startDelayTimer <= 0f)
                {
                    hasStarted = true;
                    carPhysics.isThrottlePressed = true;
                    Debug.Log("🤖 ИИ стартовал!");
                }
                return;
            }
            
            // Газ
            carPhysics.isThrottlePressed = true;
            
            // Нитро (если агрессивно едет)
            if (aggressiveness > 0.7f && carPhysics.CurrentSpeedKmh > 100f)
            {
                float nitroChance = (aggressiveness - 0.7f) * 3f; // 0-0.45
                if (Random.value < nitroChance && carPhysics.NitroCharge > 50f)
                {
                    carPhysics.ActivateNitro();
                }
            }
            
            // Переключение передач с учётом rubber-banding
            float shiftThreshold = GetShiftThreshold();
            
            if (carPhysics.currentRpm >= shiftThreshold && carPhysics.currentGear < carPhysics.vehicleData.gearRatios.Length)
            {
                // Задержка переключения (имитация скорости реакции)
                float shiftDelay = (1f - shiftSpeed) * 0.3f; // 0.06-0.12с
                Invoke(nameof(ShiftUp), shiftDelay);
            }
        }
        
        /// <summary>
        /// Получить обороты для переключения
        /// </summary>
        private float GetShiftThreshold()
        {
            // Базовые обороты переключения
            float baseShift = 6500f;
            
            // Коррекция от rubber-banding
            float rubberBandShift = currentRubberBandFactor * 1000f;
            
            return baseShift + rubberBandShift;
        }
        
        /// <summary>
        /// Переключение вверх
        /// </summary>
        private void ShiftUp()
        {
            if (carPhysics != null && !hasFinished)
            {
                carPhysics.ShiftUp();
            }
        }
        
        /// <summary>
        /// Проверка финиша
        /// </summary>
        private void CheckFinish()
        {
            if (carPhysics != null && carPhysics.HasFinished && !hasFinished)
            {
                hasFinished = true;
                Debug.Log($"🏁 ИИ финишировал! Время: {carPhysics.raceTime:F3}с");
                OnAIFinished?.Invoke(this);
            }
        }
        
        #endregion
        
        #region Rubber-banding Helpers
        
        /// <summary>
        /// Получить бонус к мощности от rubber-banding
        /// </summary>
        public float GetPowerBonus()
        {
            if (currentRubberBandFactor > 0f)
            {
                return currentRubberBandFactor * 100f; // до +30 л.с.
            }
            return 0f;
        }
        
        /// <summary>
        /// Получить штраф к мощности от rubber-banding
        /// </summary>
        public float GetPowerPenalty()
        {
            if (currentRubberBandFactor < 0f)
            {
                return currentRubberBandFactor * 100f; // до -30 л.с.
            }
            return 0f;
        }
        
        #endregion
        
        #region Debug
        
        /// <summary>
        /// Отладочная информация
        /// </summary>
        public string GetDebugInfo()
        {
            string status = hasStarted ? (hasFinished ? "Финиш" : "Гонка") : "Старт";
            string rubberBand = enableRubberBanding ? 
                $"{currentRubberBandFactor:+0.00;-0.00}" : "Off";
            
            return $@"ИИ: {status}
Отставание: {distanceDifference:+0.0;-0.0}м
Rubber-band: {rubberBand}
Передача: {carPhysics?.currentGear ?? 0}";
        }
        
        #endregion
    }
}

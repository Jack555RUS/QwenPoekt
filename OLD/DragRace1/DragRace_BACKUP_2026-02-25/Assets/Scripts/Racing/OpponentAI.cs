using UnityEngine;
using DragRace.Vehicles;

namespace DragRace.Racing
{
    /// <summary>
    /// ИИ соперника с rubber-banding
    /// </summary>
    public class OpponentAI : MonoBehaviour
    {
        public VehiclePhysics opponentVehicle;
        
        [Header("Настройки ИИ")]
        [Range(0.1f, 0.5f)] public float baseReactionTime = 0.3f;
        [Range(0.1f, 0.5f)] public float baseShiftSpeed = 0.2f;
        [Range(6000f, 8000f)] public float shiftRpmThreshold = 7000f;
        
        [Header("Rubber-banding")]
        [Range(0f, 0.5f)] public float rubberBandStrength = 0.2f;
        [Range(0f, 1f)] public float maxRubberBandBonus = 0.3f;
        [Range(0f, 50f)] public float rubberBandActivationDistance = 10f;
        
        [Header("Сложность")]
        public DifficultyLevel difficulty = DifficultyLevel.Medium;
        
        private bool isRacing;
        private float raceStartTime;
        private bool hasLaunched;
        private float difficultyReactionMod;
        
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
                    difficultyReactionMod = 1.5f;
                    break;
                case DifficultyLevel.Medium:
                    difficultyReactionMod = 1.0f;
                    break;
                case DifficultyLevel.Hard:
                    difficultyReactionMod = 0.7f;
                    break;
                case DifficultyLevel.Expert:
                    difficultyReactionMod = 0.5f;
                    break;
            }
        }
        
        private void UpdateAI()
        {
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
            
            if (timeSinceStart >= effectiveReactionTime)
            {
                opponentVehicle.LaunchControl();
                hasLaunched = true;
            }
        }
        
        private void HandleRacing()
        {
            if (opponentVehicle.currentRpm >= shiftRpmThreshold)
            {
                float rubberBandBonus = CalculateRubberBandBonus();
                float effectiveShiftSpeed = baseShiftSpeed * (1f - rubberBandBonus);
                
                if (Random.value < Time.deltaTime / Mathf.Max(effectiveShiftSpeed, 0.01f))
                {
                    opponentVehicle.ShiftUp();
                }
            }
        }
        
        private float CalculateRubberBandBonus()
        {
            // Простая реализация rubber-banding
            float distanceDiff = 10f; // Заглушка
            
            if (distanceDiff > rubberBandActivationDistance)
            {
                float normalizedGap = Mathf.Clamp01(distanceDiff / 50f);
                return Mathf.Clamp(normalizedGap * rubberBandStrength, 0f, maxRubberBandBonus);
            }
            
            return 0f;
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
    
    public enum DifficultyLevel { Easy, Medium, Hard, Expert }
}

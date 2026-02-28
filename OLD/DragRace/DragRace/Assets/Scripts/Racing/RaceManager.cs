using System.Collections;
using UnityEngine;
using DragRace.Core;
using DragRace.Data;
using DragRace.Vehicles;

namespace DragRace.Racing
{
    /// <summary>
    /// Менеджер заезда
    /// </summary>
    public class RaceManager : MonoBehaviour
    {
        public static RaceManager Instance { get; private set; }
        
        [Header("Настройки заезда")]
        public RaceDistance raceDistance;
        public RaceType raceType;
        public CareerRace careerRace;
        
        [Header("Ссылки")]
        public VehiclePhysics playerVehicle;
        public VehiclePhysics opponentVehicle;
        public OpponentAI opponentAI;
        
        [Header("Светофор")]
        public TrafficLight trafficLight;
        
        // Состояние заезда
        public RaceState CurrentState { get; private set; }
        public float RaceTime { get; private set; }
        public bool IsPlayerFinished { get; private set; }
        public bool IsOpponentFinished { get; private set; }
        
        // Результаты
        public RaceResult currentRaceResult;
        
        // События
        public delegate void RaceStateHandler(RaceState state);
        public event RaceStateHandler OnRaceStateChanged;
        
        public delegate void RaceFinishedHandler(RaceResult result);
        public event RaceFinishedHandler OnRaceFinished;
        
        private void Awake()
        {
            if (Instance != null && Instance != this)
            {
                Destroy(gameObject);
                return;
            }
            
            Instance = this;
            DontDestroyOnLoad(gameObject);
        }
        
        private void Update()
        {
            if (CurrentState == RaceState.Racing)
            {
                RaceTime += Time.deltaTime;
                UpdateOpponentAI();
            }
        }
        
        #region Начало заезда
        
        public void StartRace(RaceDistance distance, RaceType type)
        {
            raceDistance = distance;
            raceType = type;
            
            // Инициализация автомобилей
            InitializeVehicles();
            
            // Сброс состояния
            CurrentState = RaceState.Preparing;
            RaceTime = 0f;
            IsPlayerFinished = false;
            IsOpponentFinished = false;
            
            OnRaceStateChanged?.Invoke(CurrentState);
            
            // Запуск последовательности старта
            StartCoroutine(StartSequence());
        }
        
        private void InitializeVehicles()
        {
            var gameData = GameManager.Instance.GameData;
            var currentVehicle = GameManager.Instance.GetCurrentVehicle();
            
            if (currentVehicle != null && playerVehicle != null)
            {
                playerVehicle.vehicleData = currentVehicle;
                // TODO: Загрузка частей автомобиля
            }
            
            // Настройка соперника
            if (opponentVehicle != null)
            {
                opponentVehicle.vehicleData = GenerateOpponentVehicle();
            }
            
            // Настройка ИИ соперника
            if (opponentAI != null)
            {
                SetupOpponentAI();
            }
        }
        
        private void SetupOpponentAI()
        {
            if (careerRace != null && CareerManager.Instance != null)
            {
                // Настройка ИИ на основе гонки карьеры
                var tier = CareerManager.Instance.careerData.GetCurrentTier();
                DifficultyLevel difficulty = GetDifficultyFromTier(tier);
                
                opponentAI.SetDifficulty(difficulty);
                
                // Применение rubber-banding
                var rubberBand = opponentAI.GetComponent<OpponentAI>();
                if (rubberBand != null)
                {
                    rubberBand.rubberBandStrength = 0.15f + (tier.difficulty * 0.05f);
                    rubberBand.maxRubberBandBonus = 0.2f + (tier.difficulty * 0.05f);
                }
            }
            else
            {
                // Быстрая гонка - средняя сложность
                opponentAI.SetDifficulty(DifficultyLevel.Medium);
            }
        }
        
        private DifficultyLevel GetDifficultyFromTier(CareerTier tier)
        {
            if (tier == null) return DifficultyLevel.Medium;
            
            return tier.difficulty switch
            {
                1 => DifficultyLevel.Easy,
                2 => DifficultyLevel.Medium,
                3 => DifficultyLevel.Hard,
                4 => DifficultyLevel.Expert,
                5 => DifficultyLevel.Expert,
                _ => DifficultyLevel.Medium
            };
        }
        
        private VehicleData GenerateOpponentVehicle()
        {
            // Генерация автомобиля соперника на основе уровня игрока
            var playerData = GameManager.Instance.GameData.playerData;
            
            var opponent = new VehicleData
            {
                vehicleName = "Opponent Car",
                baseStats = new VehicleStats
                {
                    power = playerData.level * 50 + 100,
                    torque = playerData.level * 30 + 150,
                    weight = 1200f,
                    grip = 0.7f + playerData.level * 0.01f
                }
            };
            
            opponent.currentStats = opponent.baseStats;
            return opponent;
        }
        
        private IEnumerator StartSequence()
        {
            // Подготовка
            yield return new WaitForSeconds(1f);
            
            // Светофор
            if (trafficLight != null)
            {
                trafficLight.StartSequence();
                
                // Ждём зелёного света
                while (!trafficLight.IsGreen)
                {
                    yield return null;
                }
            }
            
            // Старт!
            CurrentState = RaceState.Racing;
            OnRaceStateChanged?.Invoke(CurrentState);
            
            playerVehicle.StartRace(raceDistance.distanceMeters);
            opponentVehicle.StartRace(raceDistance.distanceMeters);
        }
        
        #endregion
        
        #region ИИ соперника
        
        private void UpdateOpponentAI()
        {
            if (opponentVehicle == null || !opponentVehicle.enabled)
                return;
            
            // Простая логика ИИ
            float reactionTime = 0.5f - GameManager.Instance.GameData.playerData.reactionTime * 0.1f;
            
            if (CurrentState == RaceState.Racing && opponentVehicle.currentGear == 0)
            {
                // Старт после реакции
                if (RaceTime >= reactionTime)
                {
                    opponentVehicle.LaunchControl();
                }
            }
            else if (opponentVehicle.currentGear > 0)
            {
                // Переключение передач по оборотам
                if (opponentVehicle.currentRpm >= opponentVehicle.engine.redlineRpm * 0.9f)
                {
                    opponentVehicle.ShiftUp();
                }
            }
        }
        
        #endregion
        
        #region Завершение заезда
        
        public void FinishRace(VehiclePhysics vehicle)
        {
            if (vehicle == playerVehicle)
            {
                IsPlayerFinished = true;
            }
            else if (vehicle == opponentVehicle)
            {
                IsOpponentFinished = true;
            }
            
            // Проверка завершения
            if (IsPlayerFinished && IsOpponentFinished)
            {
                CompleteRace();
            }
        }
        
        private void CompleteRace()
        {
            CurrentState = RaceState.Finished;
            OnRaceStateChanged?.Invoke(CurrentState);
            
            // Определение победителя
            bool isWin = playerVehicle.distanceTraveled >= opponentVehicle.distanceTraveled;
            
            // Расчёт наград
            float earnedMoney;
            float earnedXp;
            
            // Если это гонка карьеры
            if (careerRace != null && CareerManager.Instance != null)
            {
                earnedMoney = CareerManager.Instance.CalculatePrize(careerRace, currentRaceResult);
                earnedXp = CareerManager.Instance.CalculateXpReward(careerRace, currentRaceResult);
                
                // Обновление прогресса карьеры
                currentRaceResult.distanceName = careerRace.id;
                CareerManager.Instance.CompleteRace(currentRaceResult);
            }
            else
            {
                // Быстрая гонка
                earnedMoney = CalculateReward(raceDistance.distanceMeters, isWin);
                earnedXp = CalculateXp(raceDistance.distanceMeters, isWin);
            }
            
            // Создание результата
            currentRaceResult = new RaceResult
            {
                raceDate = System.DateTime.Now,
                distanceName = careerRace != null ? careerRace.id : raceDistance.name,
                distanceMeters = raceDistance.distanceMeters,
                time = RaceTime,
                topSpeed = Mathf.Max(playerVehicle.GetSpeedKmh(), opponentVehicle.GetSpeedKmh()),
                isWin = isWin,
                opponentName = careerRace != null ? careerRace.opponentName : "CPU Racer",
                earnedMoney = earnedMoney,
                earnedXp = earnedXp,
                usedVehicle = playerVehicle.vehicleData
            };
            
            // Награды
            if (isWin)
            {
                GameManager.Instance.AddMoney(earnedMoney);
                GameManager.Instance.AddExperience(earnedXp);
            }
            
            // Сохранение в историю
            GameManager.Instance.GameData.raceHistory.Add(currentRaceResult);
            
            OnRaceFinished?.Invoke(currentRaceResult);
        }
        
        private float CalculateReward(float distance, bool isWin)
        {
            float baseReward = distance switch
            {
                <= 201 => 100f,      // 1/8 мили
                <= 402 => 200f,      // 1/4 мили
                <= 804 => 400f,      // 1/2 мили
                _ => 800f            // 1 миля
            };
            
            return isWin ? baseReward : baseReward * 0.3f;
        }
        
        private float CalculateXp(float distance, bool isWin)
        {
            float baseXp = distance switch
            {
                <= 201 => 50f,
                <= 402 => 100f,
                <= 804 => 200f,
                _ => 400f
            };
            
            return isWin ? baseXp : baseXp * 0.5f;
        }
        
        #endregion
        
        #region Управление
        
        public void PauseRace()
        {
            if (CurrentState == RaceState.Racing)
            {
                CurrentState = RaceState.Paused;
                Time.timeScale = 0f;
                OnRaceStateChanged?.Invoke(CurrentState);
            }
        }
        
        public void ResumeRace()
        {
            if (CurrentState == RaceState.Paused)
            {
                CurrentState = RaceState.Racing;
                Time.timeScale = 1f;
                OnRaceStateChanged?.Invoke(CurrentState);
            }
        }
        
        public void QuitRace()
        {
            CurrentState = RaceState.Cancelled;
            Time.timeScale = 1f;
            OnRaceStateChanged?.Invoke(CurrentState);
            
            GameManager.Instance.ChangeState(GameState.GameMenu);
        }
        
        #endregion
    }
    
    public enum RaceState
    {
        Preparing,
        Countdown,
        Racing,
        Paused,
        Finished,
        Cancelled
    }
    
    public enum RaceType
    {
        Test,
        Street,
        Professional,
        Championship
    }
}
